import Foundation
import Vision
import CoreImage
import UIKit

extension OCRService {
    func preprocessImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let context = CIContext(options: nil)
        let ciImage = CIImage(cgImage: cgImage)
        
        var processedImage = ciImage
        
        if let exposureFilter = CIFilter(name: "CIExposureAdjust") {
            exposureFilter.setValue(processedImage, forKey: kCIInputImageKey)
            exposureFilter.setValue(0.5, forKey: kCIInputEVKey)
            if let output = exposureFilter.outputImage {
                processedImage = output
            }
        }
        
        if let contrastFilter = CIFilter(name: "CIColorControls") {
            contrastFilter.setValue(processedImage, forKey: kCIInputImageKey)
            contrastFilter.setValue(1.2, forKey: kCIInputContrastKey)
            if let output = contrastFilter.outputImage {
                processedImage = output
            }
        }
        
        if let grayscaleFilter = CIFilter(name: "CIPhotoEffectNoir") {
            grayscaleFilter.setValue(processedImage, forKey: kCIInputImageKey)
            if let output = grayscaleFilter.outputImage {
                processedImage = output
            }
        }
        
        guard let outputCGImage = context.createCGImage(processedImage, from: processedImage.extent) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
    
    func extractAmountsAdvanced(from text: String, confidence: Float) -> [(amount: Double, confidence: Float)] {
        var amounts: [(amount: Double, confidence: Float)] = []
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard trimmedLine.count > 3 else { continue }
            
            let patterns = [
                (#"(?i)(?:total|grand\s*total|amount|sum)\s*[:\-]?\s*[Rr][Ss]\.?\s*([0-9,]+\.?[0-9]*)"#, 1.0),
                (#"(?i)(?:total|grand\s*total|amount|sum)\s*[:\-]?\s*([0-9,]+\.?[0-9]*)"#, 0.9),
                (#"[Rr][Ss]\.?\s*([0-9,]+\.[0-9]{2})"#, 0.8),
                (#"[Ll][Kk][Rr]\s*([0-9,]+\.[0-9]{2})"#, 0.8),
                (#"\b([0-9,]+\.[0-9]{2})\s*$"#, 0.7),
                (#"\b([0-9,]{4,})\b"#, 0.6),
                (#"₨\s*([0-9,]+\.?[0-9]*)"#, 0.8),
                (#"\$\s*([0-9,]+\.?[0-9]*)"#, 0.7)
            ]
            
            for (pattern, patternConfidence) in patterns {
                let regex = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
                let matches = regex.matches(in: trimmedLine, options: [], range: NSRange(location: 0, length: trimmedLine.utf16.count))
                
                for match in matches {
                    if let range = Range(match.range(at: 1), in: trimmedLine) {
                        let amountString = String(trimmedLine[range]).replacingOccurrences(of: ",", with: "")
                        if let amount = Double(amountString) {
                            if amount >= 1 && amount <= 1_000_000 {
                                let finalConfidence = confidence * Float(patternConfidence)
                                amounts.append((amount: amount, confidence: finalConfidence))
                            }
                        }
                    }
                }
            }
        }
        
        return amounts
    }
    
    func categorizeExpenseAdvanced(from text: String) -> (category: String?, confidence: Float) {
        let lowercaseText = text.lowercased()
        let words = lowercaseText.components(separatedBy: .whitespacesAndNewlines)
        
        let categoryMappings: [(keywords: [String], category: String, baseConfidence: Float)] = [
            (["restaurant", "cafe", "food", "dining", "meal", "lunch", "dinner", "breakfast", "pizza", "burger", "coffee", "tea", "bakery", "hotel", "bar", "kfc", "mcdonalds", "subway", "dominos"], "Food & Dining", 0.9),
            (["taxi", "uber", "pickme", "fuel", "petrol", "diesel", "bus", "train", "transport", "parking", "toll", "ceypetco", "ioc"], "Transportation", 0.85),
            (["mall", "shop", "store", "market", "supermarket", "keells", "cargills", "arpico", "purchase", "buy", "shopping"], "Shopping", 0.8),
            (["electricity", "water", "phone", "internet", "bill", "utility", "ceb", "dialog", "mobitel", "hutch", "airtel"], "Utilities", 0.85),
            (["hospital", "pharmacy", "doctor", "medical", "clinic", "medicine", "osusala", "health", "prescription"], "Healthcare", 0.85),
            (["cinema", "movie", "theater", "theatre", "game", "entertainment", "majestic", "scope", "ticket"], "Entertainment", 0.8),
            (["school", "college", "university", "education", "book", "course", "tuition", "fees"], "Education", 0.8)
        ]
        
        var bestMatch: (category: String, confidence: Float) = ("Other", 0.0)
        
        for mapping in categoryMappings {
            var matchCount = 0
            var totalMatches = 0
            
            for keyword in mapping.keywords {
                totalMatches += 1
                if words.contains(keyword) || lowercaseText.contains(keyword) {
                    matchCount += 1
                }
            }
            
            if matchCount > 0 {
                let matchRatio = Float(matchCount) / Float(totalMatches)
                let confidence = mapping.baseConfidence * matchRatio * (matchCount > 1 ? 1.2 : 1.0)
                
                if confidence > bestMatch.confidence {
                    bestMatch = (mapping.category, confidence)
                }
            }
        }
        
        return (bestMatch.confidence > 0.3 ? bestMatch.category : nil, bestMatch.confidence)
    }
    
    func extractMerchant(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
        let cleanLines = lines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 2 }
        
        for line in cleanLines.prefix(5) {
            if line.lowercased().contains("receipt") ||
               line.lowercased().contains("invoice") ||
               line.contains("tel:") ||
               line.contains("phone") ||
               line.range(of: #"\d{3,}"#, options: .regularExpression) != nil {
                continue
            }
            
            let letterCount = line.filter { $0.isLetter }.count
            if letterCount > line.count / 2 && line.count > 3 && line.count < 50 {
                return line
            }
        }
        
        return nil
    }
    
    func extractDate(from text: String) -> Date? {
        let datePatterns = [
            #"\b(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})\b"#,
            #"\b(\d{2,4})[\/\-](\d{1,2})[\/\-](\d{1,2})\b"#,
            #"\b(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{2,4})\b"#
        ]
        
        for pattern in datePatterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            for match in matches {
                if let dateRange = Range(match.range, in: text) {
                    let dateString = String(text[dateRange])
                    
                    let formatters = [
                        "dd/MM/yyyy", "MM/dd/yyyy", "yyyy/MM/dd",
                        "dd-MM-yyyy", "MM-dd-yyyy", "yyyy-MM-dd",
                        "dd MMM yyyy"
                    ]
                    
                    for format in formatters {
                        let formatter = DateFormatter()
                        formatter.dateFormat = format
                        if let date = formatter.date(from: dateString) {
                            let now = Date()
                            let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
                            
                            if date <= now && date >= oneYearAgo {
                                return date
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
}

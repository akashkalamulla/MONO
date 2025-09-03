import Foundation
import Vision
import CoreImage
import UIKit
import CoreImage.CIFilterBuiltins

extension OCRService {
    
    // Analyze image quality and choose optimal preprocessing
    func analyzeImageQuality(_ image: UIImage) -> ImageQualityMetrics {
        guard let cgImage = image.cgImage else {
            return ImageQualityMetrics(brightness: 0.5, contrast: 0.5, sharpness: 0.5, hasGoodLighting: false)
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext(options: nil)
        
        // Sample a smaller region for performance
        let sampleRect = CGRect(x: ciImage.extent.width * 0.25, 
                               y: ciImage.extent.height * 0.25,
                               width: ciImage.extent.width * 0.5, 
                               height: ciImage.extent.height * 0.5)
        
        // Calculate brightness
        let averageFilter = CIFilter(name: "CIAreaAverage")!
        averageFilter.setValue(ciImage.cropped(to: sampleRect), forKey: kCIInputImageKey)
        averageFilter.setValue(CIVector(cgRect: sampleRect), forKey: kCIInputExtentKey)
        
        var brightness: Float = 0.5
        if let averageColor = averageFilter.outputImage {
            // Extract brightness from the average color
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let avgCGImage = context.createCGImage(averageColor, from: averageColor.extent) {
                let data = avgCGImage.dataProvider?.data
                let bytes = CFDataGetBytePtr(data!)
                brightness = Float(bytes![0]) / 255.0 // Red channel as brightness approximation
            }
        }
        
        // Estimate contrast and sharpness
        let contrast = Float(brightness > 0.3 && brightness < 0.7 ? 0.7 : 0.4)
        let sharpness = Float(brightness > 0.2 && brightness < 0.8 ? 0.7 : 0.5)
        let hasGoodLighting = brightness > 0.3 && brightness < 0.8
        
        return ImageQualityMetrics(brightness: brightness, contrast: contrast, sharpness: sharpness, hasGoodLighting: hasGoodLighting)
    }
    
    func preprocessImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        // Analyze image quality first
        let quality = analyzeImageQuality(image)
        
        // Create a high-performance context
        let options = [CIContextOption.useSoftwareRenderer: false, 
                      CIContextOption.priorityRequestLow: false]
        let context = CIContext(options: options)
        let ciImage = CIImage(cgImage: cgImage)
        
        var processedImage = ciImage
        
        // Apply adaptive preprocessing based on image quality
        if quality.brightness < 0.4 {
            // Image is too dark - boost exposure more aggressively
            if let exposureFilter = CIFilter(name: "CIExposureAdjust") {
                exposureFilter.setValue(processedImage, forKey: kCIInputImageKey)
                exposureFilter.setValue(1.0, forKey: kCIInputEVKey) // Higher exposure boost
                if let output = exposureFilter.outputImage {
                    processedImage = output
                }
            }
        } else if quality.brightness > 0.7 {
            // Image is too bright - reduce exposure
            if let exposureFilter = CIFilter(name: "CIExposureAdjust") {
                exposureFilter.setValue(processedImage, forKey: kCIInputImageKey)
                exposureFilter.setValue(-0.3, forKey: kCIInputEVKey) // Reduce exposure
                if let output = exposureFilter.outputImage {
                    processedImage = output
                }
            }
        } else {
            // Normal lighting - standard exposure adjustment
            if let exposureFilter = CIFilter(name: "CIExposureAdjust") {
                exposureFilter.setValue(processedImage, forKey: kCIInputImageKey)
                exposureFilter.setValue(0.5, forKey: kCIInputEVKey)
                if let output = exposureFilter.outputImage {
                    processedImage = output
                }
            }
        }
        
        // Apply unsharp mask for better edge detection (adaptive strength)
        if let unsharpMaskFilter = CIFilter(name: "CIUnsharpMask") {
            unsharpMaskFilter.setValue(processedImage, forKey: kCIInputImageKey)
            unsharpMaskFilter.setValue(quality.sharpness < 0.6 ? 2.0 : 1.5, forKey: kCIInputRadiusKey)
            unsharpMaskFilter.setValue(quality.sharpness < 0.6 ? 1.5 : 1.0, forKey: kCIInputIntensityKey)
            if let output = unsharpMaskFilter.outputImage {
                processedImage = output
            }
        }
        
        // Adaptive contrast enhancement
        if let contrastFilter = CIFilter(name: "CIColorControls") {
            contrastFilter.setValue(processedImage, forKey: kCIInputImageKey)
            let contrastValue = quality.contrast < 0.5 ? 1.5 : 1.3
            contrastFilter.setValue(contrastValue, forKey: kCIInputContrastKey)
            contrastFilter.setValue(quality.hasGoodLighting ? 0.05 : 0.15, forKey: kCIInputBrightnessKey)
            contrastFilter.setValue(0.0, forKey: kCIInputSaturationKey) // Remove color for better OCR
            if let output = contrastFilter.outputImage {
                processedImage = output
            }
        }
        
        // Apply gamma correction for better text visibility
        if let gammaFilter = CIFilter(name: "CIGammaAdjust") {
            gammaFilter.setValue(processedImage, forKey: kCIInputImageKey)
            gammaFilter.setValue(quality.brightness < 0.5 ? 0.8 : 1.2, forKey: "inputPower")
            if let output = gammaFilter.outputImage {
                processedImage = output
            }
        }
        
        // Convert to grayscale with enhanced method
        if let grayscaleFilter = CIFilter(name: "CIColorMonochrome") {
            grayscaleFilter.setValue(processedImage, forKey: kCIInputImageKey)
            grayscaleFilter.setValue(CIColor(red: 0.299, green: 0.587, blue: 0.114), forKey: kCIInputColorKey) // Luminance weights
            grayscaleFilter.setValue(1.0, forKey: kCIInputIntensityKey)
            if let output = grayscaleFilter.outputImage {
                processedImage = output
            }
        }
        
        // Final sharpening pass to emphasize text edges
        if let sharpenFilter = CIFilter(name: "CISharpenLuminance") {
            sharpenFilter.setValue(processedImage, forKey: kCIInputImageKey)
            sharpenFilter.setValue(quality.sharpness < 0.6 ? 1.0 : 0.7, forKey: kCIInputSharpnessKey)
            if let output = sharpenFilter.outputImage {
                processedImage = output
            }
        }
        
        guard let outputCGImage = context.createCGImage(processedImage, from: processedImage.extent) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
    
    func extractAmountsAdvanced(from text: String, confidence: Float) -> [(amount: Double, confidence: Float)] {
        var amounts: [(amount: Double, confidence: Float)] = []
        let lines = text.components(separatedBy: .newlines)
        
        // Keep track of lines with "total" keywords to boost their confidence
        var totalLines: [String] = []
        var amountLines: [String] = []
        
        // First pass - identify special lines
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let lowercaseLine = trimmedLine.lowercased()
            
            if lowercaseLine.contains("total") || 
               lowercaseLine.contains("amount") || 
               lowercaseLine.contains("sum") || 
               lowercaseLine.contains("pay") || 
               lowercaseLine.contains("due") {
                totalLines.append(trimmedLine)
            }
            
            // Check for lines that likely contain amounts
            if trimmedLine.contains("Rs.") || 
               trimmedLine.contains("Rs") || 
               trimmedLine.contains("LKR") || 
               trimmedLine.contains("₨") || 
               trimmedLine.contains("$") {
                amountLines.append(trimmedLine)
            }
        }
        
        // All lines to process, prioritizing total lines
        let linesToProcess = totalLines + amountLines + lines
        
        for line in linesToProcess {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let _ = trimmedLine.lowercased() // We'll use this for pattern matching below
            
            guard trimmedLine.count > 3 else { continue }

            // Quick heuristics: skip lines that are likely phone numbers or dates
            if containsPhoneOrDate(trimmedLine) { continue }
            let digitCount = trimmedLine.filter { $0.isNumber }.count
            // If a line has many digits but no decimal point, it's likely a phone/serial number, not an amount
            if digitCount >= 7 && !trimmedLine.contains(".") { continue }
            
            // Much more comprehensive patterns for amount detection with weighted confidence
            let patterns = [
                // Highest confidence patterns with explicit total identifiers
                (#"(?i)(?:total|grand\s*total|bill\s*total|amount\s*due|amount\s*payable|final\s*amount|to\s*pay|net\s*total|balance\s*due)\s*[:\-=]?\s*[Rr][Ss]\.?\s*([0-9,]+\.?[0-9]*)"#, 1.0),
                (#"(?i)(?:total|grand\s*total|bill\s*total|amount\s*due|amount\s*payable|final\s*amount|to\s*pay|net\s*total|balance\s*due)\s*[:\-=]?\s*([0-9,]+\.[0-9]{2})"#, 0.98),
                
                // High confidence currency patterns
                (#"[Rr][Ss]\.?\s*([0-9,]+\.[0-9]{2})\s*$"#, 0.95), // End of line currency with decimals
                (#"[Rr][Ss]\.?\s*([0-9,]{1,3}(?:,[0-9]{3})*\.[0-9]{2})"#, 0.92), // Proper thousand separators
                (#"[Ll][Kk][Rr]\s*([0-9,]+\.[0-9]{2})"#, 0.90),
                (#"₨\s*([0-9,]+\.?[0-9]*)"#, 0.90),
                
                // Medium-high confidence patterns
                (#"(?i)(?:sub\s*total|subtotal)\s*[:\-=]?\s*[Rr][Ss]\.?\s*([0-9,]+\.?[0-9]*)"#, 0.85),
                (#"(?i)(?:amount|sum|price|cost)\s*[:\-=]?\s*[Rr][Ss]\.?\s*([0-9,]+\.?[0-9]*)"#, 0.82),
                
                // Context-dependent patterns
                (#"\b(?:pay|paid|payment|charge|fee)\s*[:\-=]?\s*[Rr][Ss]\.?\s*([0-9,]+\.?[0-9]*)"#, 0.80),
                (#"\b(?:balance|owing|due)\s*[:\-=]?\s*[Rr][Ss]\.?\s*([0-9,]+\.?[0-9]*)"#, 0.78),
                
                // Generic currency patterns (lower confidence)
                (#"[Rr][Ss]\.?\s*([0-9,]+)"#, 0.75),
                (#"[Ll][Kk][Rr]\s*([0-9,]+)"#, 0.75),
                
                // Numbers at end of lines (often totals in simple receipts)
                (#".*?([0-9,]+\.[0-9]{2})\s*$"#, 0.70),
                
                // Large whole numbers (potential totals without decimals)
                (#"\b([0-9,]{4,})\b"#, 0.65),
                
                // International currency patterns
                (#"\$\s*([0-9,]+\.?[0-9]*)"#, 0.60),
                (#"€\s*([0-9,]+\.?[0-9]*)"#, 0.60),
                (#"£\s*([0-9,]+\.?[0-9]*)"#, 0.60),
                
                // Fallback patterns for poorly formatted receipts
                (#"(?i)total.*?([0-9,]+\.?[0-9]*)"#, 0.55),
                (#"(?i)amount.*?([0-9,]+\.?[0-9]*)"#, 0.50)
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

    // Use NSDataDetector to quickly detect phone numbers or dates in a line
    func containsPhoneOrDate(_ text: String) -> Bool {
        do {
            let types = NSTextCheckingResult.CheckingType.phoneNumber.rawValue | NSTextCheckingResult.CheckingType.date.rawValue
            let detector = try NSDataDetector(types: types)
            let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            for match in matches {
                if match.resultType == .phoneNumber || match.resultType == .date {
                    return true
                }
            }
        } catch {
            // If detector fails, don't block processing
            return false
        }
        return false
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
            #"\b(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2,4})\b"#,
            #"\b(\d{2,4})[\/\-\.](\d{1,2})[\/\-\.](\d{1,2})\b"#,
            #"\b(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{2,4})\b"#,
            #"\b(January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{1,2})[,]?\s+(\d{2,4})\b"#,
            #"\b(\d{1,2})(?:st|nd|rd|th)?\s+(January|February|March|April|May|June|July|August|September|October|November|December|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[,]?\s+(\d{2,4})\b"#,
            #"(?i)date\s*[:\-]?\s*(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2,4})"#
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
                        "dd.MM.yyyy", "MM.dd.yyyy", "yyyy.MM.dd",
                        "dd MMM yyyy", "MMM dd yyyy", "dd MMMM yyyy",
                        "MMMM dd, yyyy", "MMMM dd yyyy",
                        "d MMMM yyyy", "MMMM d, yyyy"
                    ]
                    
                    // Try natural language date parsing first
                    let naturalLangFormatter = DateFormatter()
                    naturalLangFormatter.dateStyle = .long
                    naturalLangFormatter.timeStyle = .none
                    naturalLangFormatter.locale = Locale(identifier: "en_US")
                    if let date = naturalLangFormatter.date(from: dateString) {
                        let now = Date()
                        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
                        
                        if date <= now && date >= oneYearAgo {
                            return date
                        }
                    }
                    
                    // Then try specific formats
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
    
    func detectReceiptAndCorrectPerspective(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        // Create Vision request to detect rectangles (like receipts)
        let request = VNDetectRectanglesRequest()
        request.minimumAspectRatio = 0.3 // Receipts are usually taller than wide
        request.maximumAspectRatio = 0.9
        request.minimumSize = 0.3 // Rectangle should be at least 30% of the image
        request.maximumObservations = 1 // Just find the most prominent rectangle
        request.quadratureTolerance = 10.0 // Allow some deviation from perfect rectangle
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            // Check if we found a rectangle
            guard let results = request.results,
                  let rectangle = results.first as? VNRectangleObservation else {
                return nil
            }
            
            // Get rectangle corners
            let topLeft = rectangle.topLeft
            let topRight = rectangle.topRight
            let bottomLeft = rectangle.bottomLeft
            let bottomRight = rectangle.bottomRight
            
            // Convert normalized coordinates to image coordinates
            let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
            
            // Create CIImage for perspective correction
            let ciImage = CIImage(cgImage: cgImage)
            
            // Apply perspective correction using CIPerspectiveCorrection filter
            let filter = CIFilter.perspectiveCorrection()
            filter.inputImage = ciImage
            filter.topLeft = CGPoint(x: topLeft.x * imageSize.width, y: (1 - topLeft.y) * imageSize.height)
            filter.topRight = CGPoint(x: topRight.x * imageSize.width, y: (1 - topRight.y) * imageSize.height)
            filter.bottomLeft = CGPoint(x: bottomLeft.x * imageSize.width, y: (1 - bottomLeft.y) * imageSize.height)
            filter.bottomRight = CGPoint(x: bottomRight.x * imageSize.width, y: (1 - bottomRight.y) * imageSize.height)
            
            // Get corrected image
            guard let outputCIImage = filter.outputImage else {
                return nil
            }
            
            // Convert back to UIImage
            let context = CIContext(options: nil)
            guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
                return nil
            }
            
            return UIImage(cgImage: outputCGImage)
        } catch {
            print("Error detecting receipt rectangle: \(error)")
            return nil
        }
    }
    
    // Advanced multi-pass OCR with different configurations
    func multiPassOCRProcessing(_ image: UIImage, completion: @escaping (Result<OCRResult, Error>) -> Void) {
        var allResults: [OCRResult] = []
        let dispatchGroup = DispatchGroup()
        
        // Pass 1: Standard preprocessing
        dispatchGroup.enter()
        self.processImage(image) { result in
            if case .success(let ocrResult) = result {
                allResults.append(ocrResult)
            }
            dispatchGroup.leave()
        }
        
        // Pass 2: High contrast version for poor lighting
        dispatchGroup.enter()
        if let enhancedImage = self.createEnhancedContrastImage(image) {
            self.processImage(enhancedImage) { result in
                if case .success(let ocrResult) = result {
                    allResults.append(ocrResult)
                }
                dispatchGroup.leave()
            }
        } else {
            dispatchGroup.leave()
        }
        
        // Pass 3: Perspective corrected version (if different from original)
        dispatchGroup.enter()
        if let perspectiveCorrected = self.detectReceiptAndCorrectPerspective(image),
           perspectiveCorrected != image {
            self.processImage(perspectiveCorrected) { result in
                if case .success(let ocrResult) = result {
                    allResults.append(ocrResult)
                }
                dispatchGroup.leave()
            }
        } else {
            dispatchGroup.leave()
        }
        
        // Combine results when all passes complete
        dispatchGroup.notify(queue: .main) {
            let bestResult = self.combineOCRResults(allResults)
            completion(.success(bestResult))
        }
    }
    
    // Combine multiple OCR results to get the best possible outcome
    private func combineOCRResults(_ results: [OCRResult]) -> OCRResult {
        guard !results.isEmpty else {
            return OCRResult(amount: nil, text: "", suggestedCategory: nil, confidence: 0.0, merchant: nil, extractedDate: nil)
        }
        
        if results.count == 1 {
            return validateOCRResult(results[0])
        }
        
        // Find the result with highest confidence amount
        let resultsWithAmounts = results.filter { $0.amount != nil }
        let bestAmountResult = resultsWithAmounts.max { $0.confidence < $1.confidence }
        
        // Combine text from all results for better context
        let combinedText = results.map { $0.text }.joined(separator: "\n")
        
        // Get the most confident category
        let categoriesWithConfidence = results.compactMap { result -> (String, Float)? in
            guard let category = result.suggestedCategory else { return nil }
            return (category, result.confidence)
        }
        let bestCategory = categoriesWithConfidence.max { $0.1 < $1.1 }?.0
        
        // Get the most confident merchant
        let merchantsWithConfidence = results.compactMap { result -> (String, Float)? in
            guard let merchant = result.merchant else { return nil }
            return (merchant, result.confidence)
        }
        let bestMerchant = merchantsWithConfidence.max { $0.1 < $1.1 }?.0
        
        // Get the most confident date
        let datesWithConfidence = results.compactMap { result -> (Date, Float)? in
            guard let date = result.extractedDate else { return nil }
            return (date, result.confidence)
        }
        let bestDate = datesWithConfidence.max { $0.1 < $1.1 }?.0
        
        // Calculate average confidence
        let avgConfidence = results.map { $0.confidence }.reduce(0, +) / Float(results.count)
        
        let combinedResult = OCRResult(
            amount: bestAmountResult?.amount,
            text: combinedText,
            suggestedCategory: bestCategory,
            confidence: avgConfidence,
            merchant: bestMerchant,
            extractedDate: bestDate
        )
        
        return validateOCRResult(combinedResult)
    }
    
    // Additional preprocessing method specifically for high-contrast enhancement
    private func createEnhancedContrastImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let context = CIContext(options: nil)
        let ciImage = CIImage(cgImage: cgImage)
        
        var processedImage = ciImage
        
        // Apply high contrast settings
        if let contrastFilter = CIFilter(name: "CIColorControls") {
            contrastFilter.setValue(processedImage, forKey: kCIInputImageKey)
            contrastFilter.setValue(2.0, forKey: kCIInputContrastKey) // Very high contrast
            contrastFilter.setValue(-0.1, forKey: kCIInputBrightnessKey) // Slightly darker
            if let output = contrastFilter.outputImage {
                processedImage = output
            }
        }
        
        // Convert to black and white for extreme contrast
        if let monochromeFilter = CIFilter(name: "CIColorMonochrome") {
            monochromeFilter.setValue(processedImage, forKey: kCIInputImageKey)
            monochromeFilter.setValue(CIColor(red: 0.0, green: 0.0, blue: 0.0), forKey: kCIInputColorKey)
            monochromeFilter.setValue(1.0, forKey: kCIInputIntensityKey)
            if let output = monochromeFilter.outputImage {
                processedImage = output
            }
        }
        
        guard let outputCGImage = context.createCGImage(processedImage, from: processedImage.extent) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
    
    // Quality check method to validate OCR results with advanced heuristics
    func validateOCRResult(_ result: OCRResult) -> OCRResult {
        var validatedResult = result
        var adjustedConfidence = result.confidence
        
        // Clean and validate the extracted text
        let cleanedText = cleanExtractedText(result.text)
        
        // Validate amount with smart heuristics
        if let amount = result.amount {
            // Flag suspicious amounts
            if amount > 1_000_000 {
                adjustedConfidence *= 0.3 // Very likely an error
            } else if amount > 100_000 {
                adjustedConfidence *= 0.6 // Possibly an error
            } else if amount < 1 {
                adjustedConfidence *= 0.4 // Very small amounts are often errors
            } else if amount < 10 && result.confidence > 0.8 {
                // Small amounts with high confidence might be item codes
                adjustedConfidence *= 0.6
            }
            
            // Check if amount has proper decimal formatting
            let amountStr = String(format: "%.2f", amount)
            if amountStr.hasSuffix(".00") && amount > 50 {
                adjustedConfidence *= 1.1 // Round amounts are often totals
            }
        }
        
        // Advanced text analysis for receipt validation
        let lowercaseText = cleanedText.lowercased()
        let words = lowercaseText.components(separatedBy: .whitespacesAndNewlines)
        
        // Strong receipt indicators
        let strongReceiptKeywords = ["receipt", "invoice", "bill", "total", "tax", "payment", "cash", "card"]
        let strongKeywordCount = strongReceiptKeywords.filter { lowercaseText.contains($0) }.count
        
        // Weak receipt indicators
        let weakReceiptKeywords = ["date", "time", "thank you", "customer", "change", "subtotal", "amount"]
        let weakKeywordCount = weakReceiptKeywords.filter { lowercaseText.contains($0) }.count
        
        // Business/merchant indicators
        let businessKeywords = ["store", "shop", "restaurant", "cafe", "ltd", "pvt", "inc", "corp", "llc"]
        let businessKeywordCount = businessKeywords.filter { lowercaseText.contains($0) }.count
        
        // Calculate content quality score
        var contentQualityMultiplier: Float = 1.0
        
        if strongKeywordCount >= 3 {
            contentQualityMultiplier *= 1.3
        } else if strongKeywordCount >= 2 {
            contentQualityMultiplier *= 1.2
        } else if strongKeywordCount >= 1 {
            contentQualityMultiplier *= 1.1
        }
        
        if weakKeywordCount >= 2 {
            contentQualityMultiplier *= 1.1
        }
        
        if businessKeywordCount >= 1 {
            contentQualityMultiplier *= 1.05
        }
        
        // Penalize if text looks like noise
        let wordCount = words.filter { $0.count > 2 }.count
        if wordCount < 3 {
            contentQualityMultiplier *= 0.7 // Very little meaningful text
        } else if wordCount < 6 {
            contentQualityMultiplier *= 0.85
        }
        
        // Check for date-time patterns (receipts usually have them)
        let dateTimePatterns = [
            #"\b\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4}\b"#,
            #"\b\d{1,2}:\d{2}\b"#,
            #"\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\b"#
        ]
        
        for pattern in dateTimePatterns {
            if lowercaseText.range(of: pattern, options: .regularExpression) != nil {
                contentQualityMultiplier *= 1.05
                break
            }
        }
        
        // Apply all adjustments
        adjustedConfidence = min(adjustedConfidence * contentQualityMultiplier, 1.0)
        
        validatedResult.confidence = max(adjustedConfidence, 0.0)
        return validatedResult
    }
    
    // Clean extracted text for better processing
    private func cleanExtractedText(_ text: String) -> String {
        var cleaned = text
        
        // Remove excessive whitespace
        cleaned = cleaned.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        
        // Fix common OCR mistakes
        let ocrCorrections = [
            ("0CR", "OCR"),
            ("1nvoice", "Invoice"),
            ("Rece1pt", "Receipt"),
            ("B111", "Bill"),
            ("T0tal", "Total"),
            ("5ubtotal", "Subtotal"),
            ("Ca5h", "Cash"),
            ("C4rd", "Card"),
            ("D4te", "Date"),
            ("T1me", "Time")
        ]
        
        for (mistake, correction) in ocrCorrections {
            cleaned = cleaned.replacingOccurrences(of: mistake, with: correction, options: .caseInsensitive)
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

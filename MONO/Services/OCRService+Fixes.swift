import Foundation
import Vision
import UIKit

// Extension to fix OCR service issues
extension OCRService {
    
    // This extends the public API without conflicting with the private implementation
    func enhancedOCRProcessing(_ image: UIImage, completion: @escaping (Result<OCRResult, Error>) -> Void) {
        // Using enhanced OCR implementation with app-local temp file

        // Save image to app temp to avoid any FileProvider/security-scoped issues
        guard let tempURL = OCRFileHelper.saveImageToAppTemp(image) else {
            print("OCR Debug: Failed to save image to app temp")
            DispatchQueue.main.async { completion(.failure(OCRError.invalidImage)) }
            return
        }

        // Process on background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                OCRFileHelper.removeTempFile(tempURL)
                return
            }

            // Load the image back from our sandbox copy
            guard let loaded = OCRFileHelper.loadImageFromAppURL(tempURL) else {
                print("OCR Debug: Failed to load image from temp URL")
                OCRFileHelper.removeTempFile(tempURL)
                DispatchQueue.main.async { completion(.failure(OCRError.invalidImage)) }
                return
            }

            // Convert to CGImage safely
            guard let finalCGImage = OCRFileHelper.cgImageFrom(self.preprocessImage(loaded) ?? loaded) else {
                print("OCR Debug: Failed to create CGImage from loaded image")
                OCRFileHelper.removeTempFile(tempURL)
                DispatchQueue.main.async { completion(.failure(OCRError.invalidImage)) }
                return
            }

            // Build request
            let request = VNRecognizeTextRequest { [weak self] (request, error) in
                // Clean up temp file as soon as we have results
                OCRFileHelper.removeTempFile(tempURL)

                guard let self = self else { return }
                if let error = error {
                    print("OCR Debug: VNRecognizeTextRequest error: \(error)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                    print("OCR Debug: No text found in image")
                    DispatchQueue.main.async { completion(.failure(OCRError.noTextFound)) }
                    return
                }

                // Process results on background queue and return on main
                self.improvedProcessOCRResults(observations) { result in
                    DispatchQueue.main.async { completion(result) }
                }
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US", "en-GB", "en-AU", "en-CA"]
            if #available(iOS 16.0, *) {
                request.revision = VNRecognizeTextRequestRevision3
            } else if #available(iOS 14.0, *) {
                request.revision = VNRecognizeTextRequestRevision2
            }
            request.customWords = ["total","amount","bill","receipt","invoice","payment","Rs","LKR","rupees","cash","card","tax","fee"]

            let handler = VNImageRequestHandler(cgImage: finalCGImage, orientation: .up, options: [:])
            do {
                try handler.perform([request])
            } catch {
                OCRFileHelper.removeTempFile(tempURL)
                print("OCR Debug: Failed to perform recognition: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
    
    // Implementation of improved amount selection to avoid accessing private method from main class
    func improvedFindBestAmount(from amounts: [(amount: Double, confidence: Float)]) -> (amount: Double, confidence: Float)? {
        guard !amounts.isEmpty else { return nil }
        
        print("OCR Debug: Finding best amount from \(amounts.count) candidates")
        
        // Sort amounts by confidence first, then by value
        let sortedByConfidence = amounts.sorted { $0.confidence > $1.confidence }
        let highConfidenceAmounts = sortedByConfidence.filter { $0.confidence > 0.7 }
        
        if !highConfidenceAmounts.isEmpty {
            // For high confidence amounts, prefer larger values
            let bestHighConfidence = highConfidenceAmounts.sorted { $0.amount > $1.amount }.first
            print("OCR Debug: Selected high confidence amount: \(bestHighConfidence?.amount ?? 0)")
            return bestHighConfidence
        } else {
            // If no high confidence amounts, take the largest amount with reasonable confidence
            let reasonableAmounts = amounts.filter { $0.confidence > 0.5 }.sorted { $0.amount > $1.amount }
            if !reasonableAmounts.isEmpty {
                print("OCR Debug: Selected reasonable confidence amount: \(reasonableAmounts.first?.amount ?? 0)")
                return reasonableAmounts.first
            }
            
            // Last resort: take the largest value
            let largestAmount = amounts.sorted { $0.amount > $1.amount }.first
            print("OCR Debug: Selected largest amount: \(largestAmount?.amount ?? 0)")
            return largestAmount
        }
    }
    
    // Modified function with improved pattern matching
    func improvedExtractAmounts(from text: String, confidence: Float) -> [(amount: Double, confidence: Float)] {
        let amountString = text
        
        // First check if this is actually an amount string
        let digitCount = amountString.filter { $0.isNumber || $0 == "." }.count
        let totalCount = amountString.count
        
        // If it doesn't have enough digits or has too many characters, skip it
        if digitCount < 1 || totalCount > 15 {
            print("OCR Debug: Skipping unlikely amount string: \(amountString)")
            return []
        }
        
        // Log the attempted parse
        print("OCR Debug: Attempting to parse amount from: \(amountString)")
        
        // Clean the string from potential OCR errors
        var cleanedString = amountString
            .replacingOccurrences(of: "O", with: "0")
            .replacingOccurrences(of: "o", with: "0")
            .replacingOccurrences(of: "l", with: "1")
            .replacingOccurrences(of: "I", with: "1")
            .replacingOccurrences(of: "S", with: "5")
            .replacingOccurrences(of: "s", with: "5")
            .replacingOccurrences(of: "B", with: "8")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Simple pattern for detecting amounts - match anything with digits and possibly decimal points
        let patterns = [
            // Match currency symbol followed by digits
            #"(?:[Rr][Ss]\.?\s*|₨\s*|\$\s*|[Ll][Kk][Rr]\s*)([0-9,]+\.?[0-9]*)"#,
            
            // Match digits followed by decimal point
            #"([0-9,]+\.[0-9]{2})"#,
            
            // Match large numbers that might be amounts
            #"([0-9,]{3,})"#
        ]
        
        var amounts: [(amount: Double, confidence: Float)] = []
        
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
                continue
            }
            
            let matches = regex.matches(in: cleanedString, options: [], range: NSRange(location: 0, length: cleanedString.utf16.count))
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: cleanedString) {
                    let extractedString = String(cleanedString[range]).replacingOccurrences(of: ",", with: "")
                    print("OCR Debug: Extracted potential amount string: \(extractedString)")
                    
                    if let amount = Double(extractedString) {
                        // Only accept reasonable amounts (between 1 and 1 million)
                        if amount >= 1 && amount <= 1_000_000 {
                            print("OCR Debug: Valid amount found: \(amount)")
                            amounts.append((amount: amount, confidence: confidence))
                        } else {
                            print("OCR Debug: Amount out of reasonable range: \(amount)")
                        }
                    } else {
                        print("OCR Debug: Failed to convert to Double: \(extractedString)")
                    }
                }
            }
        }
        
        // If standard patterns failed, try one last approach - look for digits
        if amounts.isEmpty {
            // Extract all digit sequences as a last resort
            if let regex = try? NSRegularExpression(pattern: #"([0-9]+)"#, options: []) {
                let matches = regex.matches(in: cleanedString, options: [], range: NSRange(location: 0, length: cleanedString.utf16.count))
                
                for match in matches {
                    if let range = Range(match.range(at: 1), in: cleanedString) {
                        let digitString = String(cleanedString[range])
                        if let amount = Double(digitString), amount >= 10 {
                            print("OCR Debug: Found digits as amount: \(amount)")
                            // Lower confidence for this method
                            amounts.append((amount: amount, confidence: confidence * 0.7))
                        }
                    }
                }
            }
        }
        
        return amounts
    }
    
    // Improved text processing with better error handling and thread safety
    func improvedProcessOCRResults(_ observations: [VNRecognizedTextObservation], completion: @escaping (Result<OCRResult, Error>) -> Void) {
        print("OCR Debug: Processing \(observations.count) text observations")
        
        // Create a safe copy of observations to work with
        let safeObservations = observations
        
        // Catch any exceptions that might occur during text processing
        do {
            var allText = ""
            var detectedAmounts: [(amount: Double, confidence: Float)] = []
            var allCandidates: [String] = []
            
            // First pass - collect all text
            for observation in safeObservations {
                // Make sure we can get a candidate
                guard let topCandidate = observation.topCandidates(1).first else { 
                    continue 
                }
                
                let text = topCandidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Skip empty strings
                guard !text.isEmpty else { continue }
                
                allText += text + "\n"
                
                // Get all candidates for this observation (safely)
                let candidateCount = min(3, observation.topCandidates(3).count)
                let alternatives = observation.topCandidates(candidateCount).map { $0.string }
                allCandidates.append(contentsOf: alternatives)
                
                // Debug info
                print("OCR Debug: Observation text: \(text) (confidence: \(topCandidate.confidence))")
            }
        
            // Process entire text for amounts
            let combinedText = allText.trimmingCharacters(in: .whitespacesAndNewlines)
            print("OCR Debug: Combined text length: \(combinedText.count) characters")
            
            if combinedText.isEmpty {
                print("OCR Debug: Empty combined text, no content to process")
                completion(.failure(OCRError.noTextFound))
                return
            }
            
            // Process individual lines for amounts
            let lines = combinedText.components(separatedBy: .newlines)
            print("OCR Debug: Processing \(lines.count) lines of text")
            
            for line in lines {
                if !line.isEmpty {
                    // Try to extract amounts from each line
                    let lineAmounts = improvedExtractAmounts(from: line, confidence: 0.8)
                    detectedAmounts.append(contentsOf: lineAmounts)
                }
            }
            
            // Process individual words for amounts (in case amounts span multiple observations)
            let words = combinedText.components(separatedBy: .whitespacesAndNewlines)
            for word in words {
                if !word.isEmpty && word.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                    // Try to extract amounts from word with digits
                    let wordAmounts = improvedExtractAmounts(from: word, confidence: 0.7)
                    detectedAmounts.append(contentsOf: wordAmounts)
                }
            }
            
            print("OCR Debug: Total detected amounts: \(detectedAmounts.count)")
            
            // Find best amount - largest amount with highest confidence
            let bestAmount = improvedFindBestAmount(from: detectedAmounts)
            print("OCR Debug: Best amount found: \(bestAmount?.amount ?? 0.0)")
            
            // Get category and merchant
            let categoryResult = categorizeExpenseAdvanced(from: combinedText)
            let merchant = extractMerchant(from: combinedText)
            let extractedDate = extractDate(from: combinedText)
            
            // Set final confidence
            var finalConfidence = bestAmount?.confidence ?? 0.0
            
            // Create and return the result
            let result = OCRResult(
                amount: bestAmount?.amount,
                text: combinedText,
                suggestedCategory: categoryResult.category,
                confidence: finalConfidence,
                merchant: merchant,
                extractedDate: extractedDate
            )
            
            print("OCR Debug: Result created with confidence: \(finalConfidence)")
            completion(.success(result))
        } catch let error {
            print("OCR Debug: Exception during text processing: \(error.localizedDescription)")
            completion(.failure(OCRError.processingFailed))
        }
    }
    
    // Function to test OCR on a sample image
    func testOCRProcessingWithFixes(_ image: UIImage, completion: @escaping (Result<OCRResult, Error>) -> Void) {
        // Starting OCR test with fixed processing
        
        // Use a preprocessed image for better results
        let processedImage = preprocessImage(image) ?? image
        
        guard let cgImage = processedImage.cgImage else {
            print("OCR Debug: Invalid image")
            completion(.failure(OCRError.invalidImage))
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            if let error = error {
                print("OCR Debug: VNRecognizeTextRequest error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("OCR Debug: No text found in image")
                completion(.failure(OCRError.noTextFound))
                return
            }
            
            print("OCR Debug: Found \(observations.count) text observations")
            
            self?.improvedProcessOCRResults(observations, completion: completion)
        }
        
        // Configure the text recognition request
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US", "en-GB", "en-AU", "en-CA"]
        
        if #available(iOS 16.0, *) {
            request.revision = VNRecognizeTextRequestRevision3
        } else if #available(iOS 14.0, *) {
            request.revision = VNRecognizeTextRequestRevision2
        }
        
        // Process the image
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            print("OCR Debug: Performing text recognition request")
            try handler.perform([request])
        } catch {
            print("OCR Debug: Failed to perform recognition: \(error)")
            completion(.failure(error))
        }
    }
}

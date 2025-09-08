//
//  OCRService.swift
//  MONO
//
//  Created by Akash01 on 2025-08-29.
//

import Foundation
import Vision
import UIKit
import SwiftUI

struct ImageQualityMetrics {
    let brightness: Float
    let contrast: Float
    let sharpness: Float
    let hasGoodLighting: Bool
}

struct OCRResult {
    let amount: Double?
    let text: String
    let suggestedCategory: String?
    var confidence: Float
    let merchant: String?
    let extractedDate: Date?
}

class OCRService: ObservableObject {
    static let shared = OCRService()
    
    private init() {}
    
    // MARK: - Public Methods
    func processImage(_ image: UIImage, completion: @escaping (Result<OCRResult, Error>) -> Void) {
        // Advanced multi-step image processing pipeline
        
        // Step 1: Try to detect if this is a receipt and perform perspective correction
        let perspectiveCorrectedImage = detectReceiptAndCorrectPerspective(image) ?? image
        
        // Step 2: Apply image enhancement filters
        let processedImage = preprocessImage(perspectiveCorrectedImage) ?? perspectiveCorrectedImage
        
        guard let cgImage = processedImage.cgImage else {
            completion(.failure(OCRError.invalidImage))
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.failure(OCRError.noTextFound))
                return
            }
            
            self?.processOCRResults(observations, completion: completion)
        }
        
        // Configure for maximum accuracy with receipt-specific settings
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        // Support multiple languages for international receipts
        request.recognitionLanguages = ["en-US", "en-GB", "en-AU", "en-CA"]
        
        // Add comprehensive custom words for better receipt recognition
        request.customWords = [
            // Receipt keywords
            "receipt", "invoice", "bill", "total", "subtotal", "amount", "tax", "date", "time",
            "payment", "cash", "credit", "debit", "card", "change", "merchant", "store",
            "grand total", "net total", "final amount", "balance due", "amount due",
            
            // Currency and numbers
            "Rs", "LKR", "rupees", "cents", "USD", "dollars",
            
            // Common Sri Lankan businesses and terms
            "keells", "cargills", "arpico", "woolworths", "abans", "softlogic", "singer",
            "damro", "kapruka", "ikman", "daraz", "dialog", "mobitel", "hutch", "airtel",
            "ceb", "water board", "colombo", "kandy", "galle", "negombo", "mount lavinia",
            
            // International chains that might be in Sri Lanka
            "mcdonalds", "kfc", "subway", "pizza hut", "dominos", "burger king", "starbucks",
            
            // Receipt sections
            "items", "description", "qty", "quantity", "price", "unit price", "discount",
            "service charge", "vat", "tax", "tip", "gratuity", "delivery", "shipping"
        ]
        
        // Use latest revision for best accuracy
        if #available(iOS 16.0, *) {
            request.revision = VNRecognizeTextRequestRevision3
        } else if #available(iOS 14.0, *) {
            request.revision = VNRecognizeTextRequestRevision2
        }
        
        // Enable automatic language detection
        request.automaticallyDetectsLanguage = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Private Methods
    private func processOCRResults(_ observations: [VNRecognizedTextObservation], completion: @escaping (Result<OCRResult, Error>) -> Void) {
        var allText = ""
        var detectedAmounts: [(amount: Double, confidence: Float)] = []
        var allTopCandidates: [String] = []
        var allCandidates: [String] = []
        
        // First pass - collect all potential text
        for observation in observations {
            // Get top candidate
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            let text = topCandidate.string
            allText += text + "\n"
            allTopCandidates.append(text)
            
            // Also collect alternative text recognitions for important lines
            let alternatives = observation.topCandidates(3).map { $0.string }
            allCandidates.append(contentsOf: alternatives)
            
            // First pass amount detection from top candidates only
            let amounts = extractAmountsAdvanced(from: text, confidence: topCandidate.confidence)
            // Apply a spatial/keyword-based boost to amounts found in likely total regions
            for amt in amounts {
                var adjustedConfidence = amt.confidence
                let boost = spatialConfidenceBoost(for: observation, containing: text)
                adjustedConfidence = min(adjustedConfidence * boost, 1.0)
                detectedAmounts.append((amount: amt.amount, confidence: adjustedConfidence))
            }
        }
        
        // Second pass - analyze full text for context
        let combinedText = allText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Look for receipt structural elements to improve confidence
        let hasReceiptElements = combinedText.range(of: "receipt", options: .caseInsensitive) != nil ||
                                 combinedText.range(of: "total", options: .caseInsensitive) != nil ||
                                 combinedText.range(of: "amount", options: .caseInsensitive) != nil ||
                                 combinedText.range(of: "date", options: .caseInsensitive) != nil ||
                                 combinedText.range(of: "invoice", options: .caseInsensitive) != nil
        
        // Also check alternative candidates for amount patterns
        for candidate in allCandidates {
            let altAmounts = extractAmountsAdvanced(from: candidate, 
                                                   confidence: 0.7) // Lower base confidence for alternatives
            detectedAmounts.append(contentsOf: altAmounts)
        }
        
        // Boost confidence for amounts that appear in lines with "total" keywords
        var boostedAmounts: [(amount: Double, confidence: Float)] = []
        let lines = combinedText.components(separatedBy: .newlines)
        for line in lines {
            let lowercaseLine = line.lowercased()
            if lowercaseLine.contains("total") || 
               lowercaseLine.contains("amount") || 
               lowercaseLine.contains("sum") || 
               lowercaseLine.contains("pay") {
                
                // Find any amounts in detectedAmounts that are also in this line
                for (amount, confidence) in detectedAmounts {
                    let amountStr = String(format: "%.2f", amount).dropZeros()
                    if lowercaseLine.contains(amountStr) {
                        // Boost confidence for amounts in "total" lines
                        boostedAmounts.append((amount, min(confidence * 1.3, 1.0)))
                    }
                }
            }
        }
        detectedAmounts.append(contentsOf: boostedAmounts)
        
        // Find the most likely amount (highest value with good confidence)
        let bestAmount = findBestAmount(from: detectedAmounts)
        
        // Third pass - context-sensitive information extraction
        let categoryResult = categorizeExpenseAdvanced(from: combinedText)
        let merchant = extractMerchant(from: combinedText)
        let extractedDate = extractDate(from: combinedText)
        
        // Adjust final confidence based on receipt elements
        var finalConfidence = bestAmount?.confidence ?? 0.0
        if hasReceiptElements {
            finalConfidence = min(finalConfidence * 1.2, 1.0)
        }
        
        let result = OCRResult(
            amount: bestAmount?.amount,
            text: combinedText,
            suggestedCategory: categoryResult.category,
            confidence: finalConfidence,
            merchant: merchant,
            extractedDate: extractedDate
        )
        
        completion(.success(result))
    }
    
    private func extractAmounts(from text: String, confidence: Float) -> [(amount: Double, confidence: Float)] {
        var amounts: [(amount: Double, confidence: Float)] = []
        
        // Common patterns for Sri Lankan currency
        let patterns = [
            // Rs. 1,234.56 or Rs 1234.56
            #"[Rr][Ss]\.?\s*([0-9,]+\.?[0-9]*)"#,
            // LKR 1,234.56
            #"[Ll][Kk][Rr]\s*([0-9,]+\.?[0-9]*)"#,
            // Just numbers with decimals (total lines)
            #"\b([0-9,]+\.[0-9]{2})\b"#,
            // Large numbers without decimals
            #"\b([0-9,]{4,})\b"#
        ]
        
        for pattern in patterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: text) {
                    let amountString = String(text[range]).replacingOccurrences(of: ",", with: "")
                    if let amount = Double(amountString), amount > 10 { // Minimum Rs. 10
                        amounts.append((amount: amount, confidence: confidence))
                    }
                }
            }
        }
        
        return amounts
    }
    
    private func findBestAmount(from amounts: [(amount: Double, confidence: Float)]) -> (amount: Double, confidence: Float)? {
        guard !amounts.isEmpty else { return nil }
        
        // Sort by amount descending (usually the total is the largest)
        let sortedAmounts = amounts.sorted { $0.amount > $1.amount }
        
        // Filter out amounts that are too low confidence
        let highConfidenceAmounts = sortedAmounts.filter { $0.confidence > 0.7 }
        
        if !highConfidenceAmounts.isEmpty {
            return highConfidenceAmounts.first
        } else {
            return sortedAmounts.first
        }
    }

    // Boost confidence for amounts found in likely total regions or lines containing 'total'-like keywords
    private func spatialConfidenceBoost(for observation: VNRecognizedTextObservation, containing text: String) -> Float {
        var boost: Float = 1.0

        // If the text line contains explicit total keywords, give a larger boost
        let lower = text.lowercased()
        let totalKeywords = ["total", "grand total", "amount due", "amount payable", "net total", "final amount", "balance due", "to pay", "payable"]
        for kw in totalKeywords {
            if lower.contains(kw) {
                boost *= 1.4
                break
            }
        }

        // Spatial bias: observations near the bottom-right of the image are more likely to be totals
        // VNRectangle coordinates are normalized with origin at bottom-left in Vision
        let box = observation.boundingBox
        // bottom (y) close to 0, right (x) close to 1
        let yBoost = Float(1.0 + max(0.0, (0.4 - box.minY))) // boost for lines in lower 40%
        let xBoost = Float(1.0 + max(0.0, (box.maxX - 0.5)))   // boost for lines in right half

        // Combine spatial boosts conservatively
        boost *= min(1.0 + ((yBoost - 1.0) + (xBoost - 1.0)) * 0.6, 1.6)

        return boost
    }
    
    private func categorizeExpense(from text: String) -> String? {
        let lowercaseText = text.lowercased()
        
        // Food & Dining keywords
        let foodKeywords = ["restaurant", "cafe", "food", "dining", "meal", "lunch", "dinner", "breakfast", "pizza", "burger", "coffee", "tea", "bakery", "hotel", "bar"]
        
        // Transportation keywords
        let transportKeywords = ["taxi", "uber", "pickme", "fuel", "petrol", "diesel", "bus", "train", "transport", "parking", "toll"]
        
        // Shopping keywords
        let shoppingKeywords = ["mall", "shop", "store", "market", "supermarket", "keells", "cargills", "arpico"]
        
        // Utilities keywords
        let utilitiesKeywords = ["electricity", "water", "phone", "internet", "bill", "utility", "ceb", "dialog", "mobitel", "hutch"]
        
        // Healthcare keywords
        let healthcareKeywords = ["hospital", "pharmacy", "doctor", "medical", "clinic", "medicine", "osusala"]
        
        // Entertainment keywords
        let entertainmentKeywords = ["cinema", "movie", "theater", "game", "entertainment", "majestic", "scope"]
        
        let categoryMappings: [(keywords: [String], category: String)] = [
            (foodKeywords, "Food & Dining"),
            (transportKeywords, "Transportation"),
            (shoppingKeywords, "Shopping"),
            (utilitiesKeywords, "Utilities"),
            (healthcareKeywords, "Healthcare"),
            (entertainmentKeywords, "Entertainment")
        ]
        
        for mapping in categoryMappings {
            for keyword in mapping.keywords {
                if lowercaseText.contains(keyword) {
                    return mapping.category
                }
            }
        }
        
        return "Other"
    }
}

enum OCRError: Error, LocalizedError {
    case invalidImage
    case noTextFound
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image provided"
        case .noTextFound:
            return "No text found in the image"
        case .processingFailed:
            return "Failed to process the image"
        }
    }
}

extension String {
    // Helper method to drop unnecessary zeros from decimal strings
    func dropZeros() -> String {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        if self.contains(decimalSeparator) {
            var result = self
            while result.hasSuffix("0") {
                result = String(result.dropLast())
            }
            if result.hasSuffix(decimalSeparator) {
                result = String(result.dropLast())
            }
            return result
        }
        return self
    }
}
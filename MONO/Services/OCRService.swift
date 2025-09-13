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
    
    // Flag to indicate if enhanced OCR processing is available
    private(set) var hasEnhancedOCR = false
    
    // Testing implementation for improved OCR
    var testOCRProcessingWithFixes: ((UIImage, @escaping (Result<OCRResult, Error>) -> Void) -> Void)?
    
    private init() {
    // The enhanced OCR implementation is provided via an extension file
    // and is available at compile time in this target. Enable it so
    // callers use the app-local temp file flow (avoids FileProvider issues).
    hasEnhancedOCR = true
    print("OCRService: enhancedOCR enabled")
    }
    
    func processImage(_ image: UIImage, completion: @escaping (Result<OCRResult, Error>) -> Void) {
        let perspectiveCorrectedImage = detectReceiptAndCorrectPerspective(image) ?? image
        let processedImage = preprocessImage(perspectiveCorrectedImage) ?? perspectiveCorrectedImage

        // Create an app-local copy and a safe CGImage to avoid provider-backed resources
        var tempURL: URL? = nil
        var finalCGImage: CGImage? = nil

        if let saved = OCRFileHelper.saveImageToAppTemp(processedImage) {
            tempURL = saved
            if let loaded = OCRFileHelper.loadImageFromAppURL(saved), let cg = OCRFileHelper.cgImageFrom(loaded) {
                finalCGImage = cg
            }
        }

        // Fallback to direct cgImage if app-copy failed
        if finalCGImage == nil {
            finalCGImage = processedImage.cgImage
        }

        guard let cgImage = finalCGImage else {
            // cleanup temp if created
            if let t = tempURL { OCRFileHelper.removeTempFile(t) }
            completion(.failure(OCRError.invalidImage))
            return
        }

        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            // Remove the temporary file as soon as we have results (best-effort)
            if let t = tempURL { OCRFileHelper.removeTempFile(t) }

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
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US", "en-GB", "en-AU", "en-CA"]
        request.customWords = [
            "receipt", "invoice", "bill", "total", "subtotal", "amount", "tax", "date", "time",
            "payment", "cash", "credit", "debit", "card", "change", "merchant", "store",
            "grand total", "net total", "final amount", "balance due", "amount due",
            "Rs", "LKR", "rupees", "cents", "USD", "dollars",
            "keells", "cargills", "arpico", "woolworths", "abans", "softlogic", "singer",
            "damro", "kapruka", "ikman", "daraz", "dialog", "mobitel", "hutch", "airtel",
            "ceb", "water board", "colombo", "kandy", "galle", "negombo", "mount lavinia",
            "mcdonalds", "kfc", "subway", "pizza hut", "dominos", "burger king", "starbucks",
            "items", "description", "qty", "quantity", "price", "unit price", "discount",
            "service charge", "vat", "tax", "tip", "gratuity", "delivery", "shipping"
        ]
        
        if #available(iOS 16.0, *) {
            request.revision = VNRecognizeTextRequestRevision3
        } else if #available(iOS 14.0, *) {
            request.revision = VNRecognizeTextRequestRevision2
        }
        request.automaticallyDetectsLanguage = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
    
    private func processOCRResults(_ observations: [VNRecognizedTextObservation], completion: @escaping (Result<OCRResult, Error>) -> Void) {
        var allText = ""
        var detectedAmounts: [(amount: Double, confidence: Float)] = []
        var allTopCandidates: [String] = []
        var allCandidates: [String] = []
        
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            let text = topCandidate.string
            allText += text + "\n"
            allTopCandidates.append(text)
            
            let alternatives = observation.topCandidates(3).map { $0.string }
            allCandidates.append(contentsOf: alternatives)
            let amounts = extractAmountsAdvanced(from: text, confidence: topCandidate.confidence)

            for amt in amounts {
                var adjustedConfidence = amt.confidence
                let boost = spatialConfidenceBoost(for: observation, containing: text)
                adjustedConfidence = min(adjustedConfidence * boost, 1.0)
                detectedAmounts.append((amount: amt.amount, confidence: adjustedConfidence))
            }
        }
        
        let combinedText = allText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let hasReceiptElements = combinedText.range(of: "receipt", options: .caseInsensitive) != nil ||
                                 combinedText.range(of: "total", options: .caseInsensitive) != nil ||
                                 combinedText.range(of: "amount", options: .caseInsensitive) != nil ||
                                 combinedText.range(of: "date", options: .caseInsensitive) != nil ||
                                 combinedText.range(of: "invoice", options: .caseInsensitive) != nil
        
        for candidate in allCandidates {
            let altAmounts = extractAmountsAdvanced(from: candidate, 
                                                   confidence: 0.7)
            detectedAmounts.append(contentsOf: altAmounts)
        }
        
        var boostedAmounts: [(amount: Double, confidence: Float)] = []
        let lines = combinedText.components(separatedBy: .newlines)
        for line in lines {
            let lowercaseLine = line.lowercased()
            if lowercaseLine.contains("total") || 
               lowercaseLine.contains("amount") || 
               lowercaseLine.contains("sum") || 
               lowercaseLine.contains("pay") {
                
                for (amount, confidence) in detectedAmounts {
                    let amountStr = String(format: "%.2f", amount).dropZeros()
                    if lowercaseLine.contains(amountStr) {
                        boostedAmounts.append((amount, min(confidence * 1.3, 1.0)))
                    }
                }
            }
        }
        detectedAmounts.append(contentsOf: boostedAmounts)
        
        let bestAmount = findBestAmount(from: detectedAmounts)
        
        let categoryResult = categorizeExpenseAdvanced(from: combinedText)
        let merchant = extractMerchant(from: combinedText)
        let extractedDate = extractDate(from: combinedText)
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
            extractedDate: extractedDate,
        )
        
        completion(.success(result))
    }
    
    private func extractAmounts(from text: String, confidence: Float) -> [(amount: Double, confidence: Float)] {
        var amounts: [(amount: Double, confidence: Float)] = []
        
        let patterns = [
            #"[Rr][Ss]\.?\s*([0-9,]+\.?[0-9]*)"#,
            #"[Ll][Kk][Rr]\s*([0-9,]+\.?[0-9]*)"#,
            #"\b([0-9,]+\.[0-9]{2})\b"#,
            #"\b([0-9,]{4,})\b"#
        ]
        
        for pattern in patterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: text) {
                    let amountString = String(text[range]).replacingOccurrences(of: ",", with: "")
                    if let amount = Double(amountString), amount > 10 {
                        amounts.append((amount: amount, confidence: confidence))
                    }
                }
            }
        }
        
        return amounts
    }
    
    private func findBestAmount(from amounts: [(amount: Double, confidence: Float)]) -> (amount: Double, confidence: Float)? {
        guard !amounts.isEmpty else { return nil }
        
        // Remove duplicates by grouping similar amounts
        var uniqueAmounts: [(amount: Double, confidence: Float)] = []
        for (amount, confidence) in amounts {
            let existing = uniqueAmounts.firstIndex { abs($0.amount - amount) < 0.01 }
            if let index = existing {
                // Keep the one with higher confidence
                if confidence > uniqueAmounts[index].confidence {
                    uniqueAmounts[index] = (amount, confidence)
                }
            } else {
                uniqueAmounts.append((amount, confidence))
            }
        }
        
        // Prefer amounts with proper decimal formatting (xx.yy)
        let decimalAmounts = uniqueAmounts.filter { amount in
            let amountStr = String(format: "%.2f", amount.amount)
            return amountStr.contains(".") && !amountStr.hasSuffix(".00")
        }
        
        // Prefer amounts in reasonable receipt ranges (10-10,000)
        let reasonableAmounts = uniqueAmounts.filter { $0.amount >= 10 && $0.amount <= 10_000 }
        
        // Sort by confidence, then by reasonableness
        let sortedAmounts = uniqueAmounts.sorted { first, second in
            // First priority: confidence
            if abs(first.confidence - second.confidence) > 0.1 {
                return first.confidence > second.confidence
            }
            
            // Second priority: proper decimal formatting
            let firstHasDecimals = String(format: "%.2f", first.amount).contains(".") && !String(format: "%.2f", first.amount).hasSuffix(".00")
            let secondHasDecimals = String(format: "%.2f", second.amount).contains(".") && !String(format: "%.2f", second.amount).hasSuffix(".00")
            
            if firstHasDecimals != secondHasDecimals {
                return firstHasDecimals
            }
            
            // Third priority: reasonable amount range
            let firstIsReasonable = first.amount >= 10 && first.amount <= 10_000
            let secondIsReasonable = second.amount >= 10 && second.amount <= 10_000
            
            if firstIsReasonable != secondIsReasonable {
                return firstIsReasonable
            }
            
            // Final tiebreaker: smaller amounts are more likely to be correct in case of OCR errors
            return first.amount < second.amount
        }
        
        // Return the best amount based on our sorting criteria
        if !decimalAmounts.isEmpty && !reasonableAmounts.isEmpty {
            // Look for amounts that are both decimal-formatted AND reasonable
            let idealAmounts = decimalAmounts.filter { decimalAmount in
                reasonableAmounts.contains { reasonableAmount in
                    abs(decimalAmount.amount - reasonableAmount.amount) < 0.01
                }
            }
            if !idealAmounts.isEmpty {
                return idealAmounts.max { $0.confidence < $1.confidence }
            }
        }
        
        // Fall back to highest confidence amount that meets our criteria
        let highConfidenceAmounts = sortedAmounts.filter { $0.confidence > 0.7 }
        if !highConfidenceAmounts.isEmpty {
            return highConfidenceAmounts.first
        } else {
            return sortedAmounts.first
        }
    }

    private func spatialConfidenceBoost(for observation: VNRecognizedTextObservation, containing text: String) -> Float {
        var boost: Float = 1.0
        let lower = text.lowercased()
        let totalKeywords = ["total", "grand total", "amount due", "amount payable", "net total", "final amount", "balance due", "to pay", "payable"]
        for kw in totalKeywords {
            if lower.contains(kw) {
                boost *= 1.4
                break
            }
        }

        let box = observation.boundingBox
        let yBoost = Float(1.0 + max(0.0, (0.4 - box.minY)))
        let xBoost = Float(1.0 + max(0.0, (box.maxX - 0.5)))

        boost *= min(1.0 + ((yBoost - 1.0) + (xBoost - 1.0)) * 0.6, 1.6)

        return boost
    }
    
    private func categorizeExpense(from text: String) -> String? {
        let lowercaseText = text.lowercased()
        let foodKeywords = ["restaurant", "cafe", "food", "dining", "meal", "lunch", "dinner", "breakfast", "pizza", "burger", "coffee", "tea", "bakery", "hotel", "bar"]
        
        let transportKeywords = ["taxi", "uber", "pickme", "fuel", "petrol", "diesel", "bus", "train", "transport", "parking", "toll"]
        
        let shoppingKeywords = ["mall", "shop", "store", "market", "supermarket", "keells", "cargills", "arpico"]
        
        let utilitiesKeywords = ["electricity", "water", "phone", "internet", "bill", "utility", "ceb", "dialog", "mobitel", "hutch"]
        
        let healthcareKeywords = ["hospital", "pharmacy", "doctor", "medical", "clinic", "medicine", "osusala"]
        
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

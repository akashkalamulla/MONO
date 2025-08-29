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

struct OCRResult {
    let amount: Double?
    let text: String
    let suggestedCategory: String?
    let confidence: Float
    let merchant: String?
    let extractedDate: Date?
}

class OCRService: ObservableObject {
    static let shared = OCRService()
    
    private init() {}
    
    // MARK: - Public Methods
    func processImage(_ image: UIImage, completion: @escaping (Result<OCRResult, Error>) -> Void) {
        // Preprocess image for better accuracy
        let processedImage = preprocessImage(image) ?? image
        
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
        
        // Configure for better accuracy
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
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
        
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            let text = topCandidate.string
            allText += text + "\n"
            
            // Extract amounts from this text
            let amounts = extractAmountsAdvanced(from: text, confidence: topCandidate.confidence)
            detectedAmounts.append(contentsOf: amounts)
        }
        
        // Find the most likely amount (highest value with good confidence)
        let bestAmount = findBestAmount(from: detectedAmounts)
        let categoryResult = categorizeExpenseAdvanced(from: allText)
        let merchant = extractMerchant(from: allText)
        let extractedDate = extractDate(from: allText)
        
        let result = OCRResult(
            amount: bestAmount?.amount,
            text: allText.trimmingCharacters(in: .whitespacesAndNewlines),
            suggestedCategory: categoryResult.category,
            confidence: bestAmount?.confidence ?? 0.0,
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
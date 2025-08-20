//
//  Income.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import Foundation
import CoreData
import SwiftUI

// MARK: - Income Category Model
struct IncomeCategory: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let color: String // Store as hex string for Core Data compatibility
    
    // Add this computed property for SwiftUI Color
    var swiftUIColor: Color {
        return Color(hex: color)
    }
    
    static let defaultCategories: [IncomeCategory] = [
        IncomeCategory(id: "salary", name: "Salary", icon: "dollarsign.circle.fill", color: "#4CAF50"),
        IncomeCategory(id: "freelance", name: "Freelance", icon: "laptopcomputer", color: "#2196F3"),
        IncomeCategory(id: "business", name: "Business", icon: "building.2.fill", color: "#FF9800"),
        IncomeCategory(id: "investment", name: "Investment", icon: "chart.line.uptrend.xyaxis", color: "#9C27B0"),
        IncomeCategory(id: "rental", name: "Rental", icon: "house.fill", color: "#795548"),
        IncomeCategory(id: "bonus", name: "Bonus", icon: "gift.fill", color: "#E91E63"),
        IncomeCategory(id: "other", name: "Other", icon: "plus.circle.fill", color: "#607D8B")
    ]
}

// MARK: - Recurrence Frequency Enum
enum RecurrenceFrequency: String, CaseIterable, Codable {
    case weekly = "weekly"
    case biweekly = "biweekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .weekly:
            return "Weekly"
        case .biweekly:
            return "Bi-weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
}

// MARK: - Income Model (for Core Data)
struct IncomeModel: Identifiable {
    let id: UUID
    let amount: Double
    let categoryId: String
    let categoryName: String
    let categoryIcon: String
    let categoryColor: String
    let description: String?
    let date: Date
    let isRecurring: Bool
    let recurrenceFrequency: RecurrenceFrequency?
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        amount: Double,
        category: IncomeCategory,
        description: String? = nil,
        date: Date = Date(),
        isRecurring: Bool = false,
        recurrenceFrequency: RecurrenceFrequency? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.categoryId = category.id
        self.categoryName = category.name
        self.categoryIcon = category.icon
        self.categoryColor = category.color
        self.description = description
        self.date = date
        self.isRecurring = isRecurring
        self.recurrenceFrequency = recurrenceFrequency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

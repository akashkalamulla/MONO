//
//  Expense.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import Foundation
import CoreData
import SwiftUI

// MARK: - Expense Category Model
struct ExpenseCategory: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let color: String // Store as hex string for Core Data compatibility
    
    static let defaultCategories: [ExpenseCategory] = [
        ExpenseCategory(id: "food", name: "Food & Dining", icon: "fork.knife", color: "#FF5722"),
        ExpenseCategory(id: "transport", name: "Transportation", icon: "car.fill", color: "#2196F3"),
        ExpenseCategory(id: "housing", name: "Housing", icon: "house.fill", color: "#4CAF50"),
        ExpenseCategory(id: "utilities", name: "Utilities", icon: "bolt.fill", color: "#FF9800"),
        ExpenseCategory(id: "shopping", name: "Shopping", icon: "bag.fill", color: "#9C27B0"),
        ExpenseCategory(id: "healthcare", name: "Healthcare", icon: "cross.fill", color: "#F44336"),
        ExpenseCategory(id: "entertainment", name: "Entertainment", icon: "tv.fill", color: "#E91E63"),
        ExpenseCategory(id: "education", name: "Education", icon: "book.fill", color: "#3F51B5"),
        ExpenseCategory(id: "other", name: "Other", icon: "ellipsis.circle.fill", color: "#607D8B")
    ]
}

// MARK: - Recurrence Frequency Enum
enum ExpenseRecurrenceFrequency: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
}

// MARK: - Payment Reminder Frequency Enum
enum PaymentReminderFrequency: String, CaseIterable, Codable {
    case once = "once"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .once:
            return "Once"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
}

// MARK: - Expense Model (for Core Data)
struct ExpenseModel: Identifiable {
    let id: UUID
    let amount: Double
    let category: String
    let description: String?
    let date: Date
    let isRecurring: Bool
    let recurringFrequency: ExpenseRecurrenceFrequency?
    let isPaymentReminder: Bool
    let reminderDate: Date?
    let reminderDayOfMonth: Int?
    let reminderFrequency: PaymentReminderFrequency?
    let isReminderActive: Bool
    let lastReminderSent: Date?
    let userID: UUID
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        amount: Double,
        category: String,
        description: String? = nil,
        date: Date = Date(),
        isRecurring: Bool = false,
        recurringFrequency: ExpenseRecurrenceFrequency? = nil,
        isPaymentReminder: Bool = false,
        reminderDate: Date? = nil,
        reminderDayOfMonth: Int? = nil,
        reminderFrequency: PaymentReminderFrequency? = nil,
        isReminderActive: Bool = false,
        lastReminderSent: Date? = nil,
        userID: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.description = description
        self.date = date
        self.isRecurring = isRecurring
        self.recurringFrequency = recurringFrequency
        self.isPaymentReminder = isPaymentReminder
        self.reminderDate = reminderDate
        self.reminderDayOfMonth = reminderDayOfMonth
        self.reminderFrequency = reminderFrequency
        self.isReminderActive = isReminderActive
        self.lastReminderSent = lastReminderSent
        self.userID = userID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

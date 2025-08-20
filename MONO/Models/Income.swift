//
//  Income.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import Foundation
import SwiftUI

// MARK: - Income Category Model
struct IncomeCategory: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let description: String
    
    static let allCategories = [
        IncomeCategory(
            name: "Salary",
            icon: "banknote.fill",
            color: .green,
            description: "Regular monthly salary from employment"
        ),
        IncomeCategory(
            name: "Freelance",
            icon: "laptopcomputer",
            color: .blue,
            description: "Income from freelance work and projects"
        ),
        IncomeCategory(
            name: "Investment",
            icon: "chart.line.uptrend.xyaxis",
            color: .purple,
            description: "Returns from stocks, bonds, and investments"
        ),
        IncomeCategory(
            name: "Part-time Work",
            icon: "clock.fill",
            color: .orange,
            description: "Income from part-time employment"
        ),
        IncomeCategory(
            name: "Business",
            icon: "briefcase.fill",
            color: .red,
            description: "Income from business operations"
        ),
        IncomeCategory(
            name: "Rental",
            icon: "house.fill",
            color: .brown,
            description: "Income from property rental"
        ),
        IncomeCategory(
            name: "Bonus",
            icon: "star.fill",
            color: .yellow,
            description: "Performance bonuses and incentives"
        ),
        IncomeCategory(
            name: "Commission",
            icon: "percent",
            color: .cyan,
            description: "Sales commissions and referral fees"
        ),
        IncomeCategory(
            name: "Dividend",
            icon: "dollarsign.circle.fill",
            color: .mint,
            description: "Dividend payments from stocks"
        ),
        IncomeCategory(
            name: "Interest",
            icon: "plus.circle.fill",
            color: .indigo,
            description: "Interest from savings and deposits"
        ),
        IncomeCategory(
            name: "Gift Money",
            icon: "gift.fill",
            color: .pink,
            description: "Money received as gifts"
        ),
        IncomeCategory(
            name: "Other",
            icon: "ellipsis.circle.fill",
            color: .gray,
            description: "Other sources of income"
        )
    ]
}

// MARK: - Income Model
struct Income {
    let id: UUID
    let source: String
    let category: String
    let amount: Double
    let dateReceived: Date
    let dateCreated: Date
    let categoryIcon: String
    let categoryColor: String
    let incomeDescription: String?
    let notes: String?
    let isRecurring: Bool
    let recurringFrequency: String?
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: dateReceived)
    }
}

// MARK: - Recurring Frequency Options
enum RecurringFrequency: String, CaseIterable {
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case annually = "Annually"
    
    var description: String {
        switch self {
        case .weekly:
            return "Every week"
        case .biweekly:
            return "Every 2 weeks"
        case .monthly:
            return "Every month"
        case .quarterly:
            return "Every 3 months"
        case .annually:
            return "Once a year"
        }
    }
}

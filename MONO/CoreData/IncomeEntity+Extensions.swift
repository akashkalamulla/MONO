//
//  IncomeEntity+Extensions.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import Foundation
import CoreData

extension IncomeEntity {
    var recurrenceFrequencyEnum: RecurrenceFrequency? {
        get {
            guard let frequencyString = recurrenceFrequency else { return nil }
            return RecurrenceFrequency(rawValue: frequencyString)
        }
        set {
            recurrenceFrequency = newValue?.rawValue
        }
    }
    
    func toIncomeModel() -> IncomeModel {
        return IncomeModel(
            id: id ?? UUID(),
            amount: amount,
            category: IncomeCategory(
                id: categoryId ?? "",
                name: categoryName ?? "",
                icon: categoryIcon ?? "",
                color: categoryColor ?? ""
            ),
            description: incomeDescription,
            date: date ?? Date(),
            isRecurring: isRecurring,
            recurrenceFrequency: recurrenceFrequencyEnum,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}

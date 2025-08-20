//
//  IncomeManager.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import Foundation
import CoreData
import SwiftUI

class IncomeManager: ObservableObject {
    @Published var incomes: [IncomeEntity] = []
    @Published var isLoading = false
    @Published var totalIncome: Double = 0
    @Published var monthlyIncome: Double = 0
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.viewContext = context
        fetchIncomes()
        calculateTotals()
    }
    
    // MARK: - Fetch Incomes
    func fetchIncomes() {
        let request: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \IncomeEntity.dateReceived, ascending: false)]
        
        do {
            incomes = try viewContext.fetch(request)
            calculateTotals()
        } catch {
            print("Error fetching incomes: \(error)")
        }
    }
    
    func fetchIncomes(for user: UserEntity) {
        let request: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \IncomeEntity.dateReceived, ascending: false)]
        
        do {
            incomes = try viewContext.fetch(request)
            calculateTotals()
        } catch {
            print("Error fetching user incomes: \(error)")
        }
    }
    
    // MARK: - Add Income
    func addIncome(
        source: String,
        category: IncomeCategory,
        amount: Double,
        dateReceived: Date,
        description: String? = nil,
        notes: String? = nil,
        isRecurring: Bool = false,
        recurringFrequency: RecurringFrequency? = nil,
        user: UserEntity
    ) -> Bool {
        
        let income = IncomeEntity(context: viewContext)
        income.id = UUID()
        income.source = source
        income.category = category.name
        income.amount = amount
        income.dateReceived = dateReceived
        income.dateCreated = Date()
        income.categoryIcon = category.icon
        income.categoryColor = category.color.description
        income.incomeDescription = description
        income.notes = notes
        income.isRecurring = isRecurring
        income.recurringFrequency = recurringFrequency?.rawValue
        income.user = user
        
        do {
            try viewContext.save()
            fetchIncomes(for: user)
            return true
        } catch {
            print("Error saving income: \(error)")
            return false
        }
    }
    
    // MARK: - Update Income
    func updateIncome(_ income: IncomeEntity) -> Bool {
        do {
            try viewContext.save()
            fetchIncomes()
            return true
        } catch {
            print("Error updating income: \(error)")
            return false
        }
    }
    
    // MARK: - Delete Income
    func deleteIncome(_ income: IncomeEntity) {
        viewContext.delete(income)
        
        do {
            try viewContext.save()
            fetchIncomes()
        } catch {
            print("Error deleting income: \(error)")
        }
    }
    
    // MARK: - Analytics
    private func calculateTotals() {
        totalIncome = incomes.reduce(0) { $0 + $1.amount }
        
        // Calculate monthly income (current month)
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
        
        monthlyIncome = incomes.filter { income in
            guard let date = income.dateReceived else { return false }
            return date >= startOfMonth && date <= endOfMonth
        }.reduce(0) { $0 + $1.amount }
    }
    
    func getIncomesByCategory() -> [String: Double] {
        var categoryTotals: [String: Double] = [:]
        
        for income in incomes {
            let category = income.category ?? "Other"
            categoryTotals[category, default: 0] += income.amount
        }
        
        return categoryTotals
    }
    
    func getMonthlyIncomes(for months: Int = 6) -> [(month: String, amount: Double)] {
        let calendar = Calendar.current
        let now = Date()
        var monthlyData: [(month: String, amount: Double)] = []
        
        for i in 0..<months {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now),
                  let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else {
                continue
            }
            
            let monthIncomes = incomes.filter { income in
                guard let date = income.dateReceived else { return false }
                return monthInterval.contains(date)
            }
            
            let monthTotal = monthIncomes.reduce(0) { $0 + $1.amount }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let monthName = formatter.string(from: monthDate)
            
            monthlyData.append((month: monthName, amount: monthTotal))
        }
        
        return monthlyData.reversed()
    }
    
    func getRecurringIncomes() -> [IncomeEntity] {
        return incomes.filter { $0.isRecurring }
    }
    
    func getTotalIncomeForDateRange(from startDate: Date, to endDate: Date) -> Double {
        return incomes.filter { income in
            guard let date = income.dateReceived else { return false }
            return date >= startDate && date <= endDate
        }.reduce(0) { $0 + $1.amount }
    }
}

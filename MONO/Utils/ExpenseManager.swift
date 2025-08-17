//
//  ExpenseManager.swift
//  MONO
//
//  Created by Akash01 on 2025-08-17.
//

import Foundation
import CoreData
import UserNotifications
import SwiftUI

class ExpenseManager: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var isLoading = false
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchExpenses()
    }
    
    // MARK: - Fetch Expenses
    func fetchExpenses() {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]
        
        do {
            expenses = try viewContext.fetch(request)
        } catch {
            print("Error fetching expenses: \(error)")
        }
    }
    
    // MARK: - Add Expense
    func addExpense(
        name: String,
        amount: Double,
        type: String,
        category: String,
        categoryIcon: String,
        categoryColor: String,
        date: Date,
        location: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        notes: String? = nil,
        reminderDate: Date? = nil,
        user: User
    ) -> Bool {
        
        let expense = Expense(context: viewContext)
        expense.id = UUID()
        expense.name = name
        expense.amount = amount
        expense.type = type
        expense.category = category
        expense.categoryIcon = categoryIcon
        expense.categoryColor = categoryColor
        expense.date = date
        expense.location = location
        expense.latitude = latitude ?? 0
        expense.longitude = longitude ?? 0
        expense.notes = notes
        expense.reminderDate = reminderDate
        expense.createdAt = Date()
        expense.user = user
        
        do {
            try viewContext.save()
            fetchExpenses() // Refresh the list
            
            // Schedule reminder if needed
            if let reminderDate = reminderDate {
                scheduleReminder(for: expense, at: reminderDate)
            }
            
            return true
        } catch {
            print("Error saving expense: \(error)")
            return false
        }
    }
    
    // MARK: - Delete Expense
    func deleteExpense(_ expense: Expense) {
        viewContext.delete(expense)
        
        do {
            try viewContext.save()
            fetchExpenses()
        } catch {
            print("Error deleting expense: \(error)")
        }
    }
    
    // MARK: - Update Expense
    func updateExpense(_ expense: Expense) -> Bool {
        do {
            try viewContext.save()
            fetchExpenses()
            return true
        } catch {
            print("Error updating expense: \(error)")
            return false
        }
    }
    
    // MARK: - Get Expenses by Type
    func getExpenses(ofType type: String) -> [Expense] {
        return expenses.filter { $0.type == type }
    }
    
    // MARK: - Get Expenses by Category
    func getExpenses(inCategory category: String) -> [Expense] {
        return expenses.filter { $0.category == category }
    }
    
    // MARK: - Get Expenses by Date Range
    func getExpenses(from startDate: Date, to endDate: Date) -> [Expense] {
        return expenses.filter { expense in
            guard let date = expense.date else { return false }
            return date >= startDate && date <= endDate
        }
    }
    
    // MARK: - Get Expenses with Location
    func getExpensesWithLocation() -> [Expense] {
        return expenses.filter { expense in
            return expense.latitude != 0 && expense.longitude != 0
        }
    }
    
    // MARK: - Calculate Total Amount
    func getTotalAmount(ofType type: String? = nil) -> Double {
        let filteredExpenses = type != nil ? getExpenses(ofType: type!) : expenses
        return filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Get Monthly Summary
    func getMonthlySummary(for date: Date) -> (income: Double, expenses: Double, balance: Double) {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end ?? date
        
        let monthlyExpenses = getExpenses(from: startOfMonth, to: endOfMonth)
        
        let income = monthlyExpenses.filter { $0.type == "Income" }.reduce(0) { $0 + $1.amount }
        let expenses = monthlyExpenses.filter { $0.type == "Expenses" }.reduce(0) { $0 + $1.amount }
        let balance = income - expenses
        
        return (income: income, expenses: expenses, balance: balance)
    }
    
    // MARK: - Reminder Scheduling
    private func scheduleReminder(for expense: Expense, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "💰 Expense Reminder"
        content.body = "Don't forget: \(expense.name ?? "Expense")"
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "expense_reminder_\(expense.id?.uuidString ?? UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error)")
            } else {
                print("Reminder scheduled for: \(expense.name ?? "Expense") at \(date)")
            }
        }
    }
    
    func cancelReminder(for expenseId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["expense_reminder_\(expenseId.uuidString)"]
        )
    }
    
    // MARK: - Notification Permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}

// MARK: - Location Helper Methods (now in separate LocationHelper.swift file)
// These methods are now implemented in the dedicated LocationHelper class

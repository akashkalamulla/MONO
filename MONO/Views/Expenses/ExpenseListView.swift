  //
//  ExpenseListView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import SwiftUI

struct ExpenseListView: View {
    @StateObject private var coreDataStack = CoreDataStack.shared
    @State private var showingAddExpense = false
    @State private var totalExpenses: Double = 0
    @State private var expenses: [ExpenseEntity] = []
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with total expenses
                VStack(spacing: 8) {
                    Text("Total Expenses")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(formatCurrency(totalExpenses))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Expenses List
                List {
                    if expenses.isEmpty {
                        Text("No expenses yet")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(expenses) { expense in
                            ExpenseRowItem(expense: expense)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                Spacer()
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadExpenses()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExpense = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense, onDismiss: {
                loadExpenses()
            }) {
                NavigationView {
                    SimpleExpenseEntry()
                        .navigationTitle("Add Expense")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    showingAddExpense = false
                                }
                            }
                        }
                }
            }
        }
    }
    
    private func loadExpenses() {
        guard let currentUser = coreDataStack.fetchCurrentUser() else {
            print("Error: No current user found")
            return
        }
        
        // Fetch expenses
        expenses = coreDataStack.fetchExpenses(for: currentUser)
        
        // Calculate total
        totalExpenses = expenses.reduce(0) { $0 + $1.amount }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rs. "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "Rs. 0.00"
    }
}

// MARK: - Expense Row Item
struct ExpenseRowItem: View {
    let expense: ExpenseEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category ?? "Uncategorized")
                    .font(.headline)

                if let description = expense.expenseDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                if let location = expense.value(forKey: "locationName") as? String, !location.isEmpty {
                    Text(location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let date = expense.date {
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text(formatAmount(expense.amount))
                .font(.headline)
                .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rs. "
        return formatter.string(from: NSNumber(value: amount)) ?? "Rs. 0.00"
    }
}

#Preview {
    ExpenseListView()
}

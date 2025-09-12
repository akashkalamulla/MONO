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
    @State private var showingHelp = false
    @State private var totalExpenses: Double = 0
    @State private var expenses: [ExpenseEntity] = []
    
    var body: some View {
        NavigationView {
            VStack {
             
                VStack(spacing: 8) {
                    Text("Total Expenses")
                        .font(.headline)
                        .foregroundColor(.monoSecondary)
                    
                    Text(formatCurrency(totalExpenses))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.monoPrimary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.monoBackground)
                .cornerRadius(12)
                .padding(.horizontal)
                
       
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Help") {
                        showingHelp = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExpense = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingHelp) {
                NavigationView {
                    ExpenseHelpView()
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
        
    
        expenses = coreDataStack.fetchExpenses(for: currentUser)
        
   
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


struct ExpenseRowItem: View {
    let expense: ExpenseEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category ?? "Uncategorized")
                    .font(.headline)
                    .foregroundColor(.black)

                if let description = expense.expenseDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.monoSecondary.opacity(0.8))
                }

                if let location = expense.value(forKey: "locationName") as? String, !location.isEmpty {
                    Text(location)
                        .font(.subheadline)
                        .foregroundColor(.monoSecondary.opacity(0.7))
                }

                if let date = expense.date {
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundColor(.monoSecondary.opacity(0.6))
                }
            }
            
            Spacer()
            
            Text(formatAmount(expense.amount))
                .font(.headline)
                .foregroundColor(.monoPrimary)
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

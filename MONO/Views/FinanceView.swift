//
//  FinanceView.swift
//  MONO
//
//  Created by GitHub Copilot on 2025-09-11.
//

import SwiftUI
import CoreData

struct FinanceView: View {
    @StateObject private var coreDataStack = CoreDataStack.shared
    @State private var selectedTab = 0
    @State private var showingAddIncome = false
    @State private var showingAddExpense = false
    @State private var totalIncome: Double = 0
    @State private var totalExpenses: Double = 0
    @State private var incomes: [IncomeEntity] = []
    @State private var expenses: [ExpenseEntity] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Summary Cards
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        // Total Income Card
                        VStack(spacing: 6) {
                            Text("Income")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.monoSecondary)
                            
                            Text(formatCurrency(totalIncome))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Total Expenses Card
                        VStack(spacing: 6) {
                            Text("Expenses")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.monoSecondary)
                            
                            Text(formatCurrency(totalExpenses))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Net Balance Card
                    VStack(spacing: 8) {
                        Text("Net Balance")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(formatCurrency(totalIncome - totalExpenses))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.monoPrimary, Color.monoSecondary]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Segmented Control
                VStack(spacing: 0) {
                    Picker("Finance Type", selection: $selectedTab) {
                        Text("Income").tag(0)
                        Text("Expenses").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    
                    // Tab indicator
                    HStack {
                        Text("\(selectedTab == 0 ? incomes.count : expenses.count) \(selectedTab == 0 ? "entries" : "entries")")
                            .font(.system(size: 14))
                            .foregroundColor(.monoSecondary)
                        
                        Spacer()
                        
                        if selectedTab == 0 {
                            Label("Swipe to see expenses", systemImage: "arrow.right")
                                .font(.system(size: 12))
                                .foregroundColor(.gray.opacity(0.7))
                        } else {
                            Label("Swipe to see income", systemImage: "arrow.left")
                                .font(.system(size: 12))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                // Lists
                TabView(selection: $selectedTab) {
                    // Income List
                    List {
                        if incomes.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("No income entries yet")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                
                                Text("Tap the + button to add your first income entry")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(incomes, id: \.id) { income in
                                IncomeRowItemSimple(income: income)
                            }
                            .onDelete { offsets in
                                deleteIncomes(offsets: offsets)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .tag(0)
                    
                    // Expenses List
                    List {
                        if expenses.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "minus.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("No expenses yet")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                
                                Text("Tap the + button to add your first expense")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(expenses) { expense in
                                ExpenseRowItem(expense: expense)
                            }
                            .onDelete { offsets in
                                deleteExpenses(offsets: offsets)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Finance")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadFinanceData()
            }
            .refreshable {
                loadFinanceData()
            }
            .sheet(isPresented: $showingAddIncome, onDismiss: {
                loadFinanceData()
            }) {
                NavigationView {
                    SimpleIncomeEntry()
                        .navigationTitle("Add Income")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    showingAddIncome = false
                                }
                                .foregroundColor(.monoPrimary)
                            }
                        }
                }
            }
            .sheet(isPresented: $showingAddExpense, onDismiss: {
                loadFinanceData()
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
                                .foregroundColor(.monoPrimary)
                            }
                        }
                }
            }
        }
    }
    
    private func loadFinanceData() {
        guard let currentUser = coreDataStack.fetchCurrentUser() else {
            print("Error: No current user found")
            return
        }
        
        // Load incomes
        incomes = coreDataStack.fetchIncomes(for: currentUser)
        totalIncome = incomes.reduce(0) { $0 + $1.amount }
        
        // Load expenses
        expenses = coreDataStack.fetchExpenses(for: currentUser)
        totalExpenses = expenses.reduce(0) { $0 + $1.amount }
    }
    
    private func deleteIncomes(offsets: IndexSet) {
        for index in offsets {
            let income = incomes[index]
            coreDataStack.deleteIncome(income)
        }
        loadFinanceData()
    }
    
    private func deleteExpenses(offsets: IndexSet) {
        for index in offsets {
            let expense = expenses[index]
            coreDataStack.deleteExpense(expense)
        }
        loadFinanceData()
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

struct IncomeRowItemSimple: View {
    let income: IncomeEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(income.categoryName ?? "Unknown Category")
                    .font(.headline)
                    .foregroundColor(.black)

                if let description = income.incomeDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.monoSecondary.opacity(0.8))
                }

                if income.isRecurring {
                    Text("Recurring Income")
                        .font(.subheadline)
                        .foregroundColor(.monoSecondary.opacity(0.7))
                }

                if let date = income.date {
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundColor(.monoSecondary.opacity(0.6))
                }
            }
            
            Spacer()
            
            Text(formatAmount(income.amount))
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
    FinanceView()
}

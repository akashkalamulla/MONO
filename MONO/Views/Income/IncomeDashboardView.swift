//
//  IncomeDashboardView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import SwiftUI
import CoreData

struct IncomeDashboardView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingAddIncome = false
    @State private var totalIncome: Double = 0
    @State private var monthlyIncome: Double = 0
    @State private var recentIncomes: [IncomeDisplayItem] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Income")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddIncome = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 20)
                
                // Summary Cards
                HStack(spacing: 16) {
                    SummaryCard(
                        title: "Total Income",
                        amount: totalIncome,
                        color: .green
                    )
                    
                    SummaryCard(
                        title: "This Month",
                        amount: monthlyIncome,
                        color: .blue
                    )
                }
                .padding(.horizontal, 20)
                
                // Recent Income List
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Recent Income")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("See All") {
                            // Show full income list
                        }
                        .foregroundColor(.green)
                    }
                    .padding(.horizontal, 20)
                    
                    if recentIncomes.isEmpty {
                        EmptyIncomeView {
                            showingAddIncome = true
                        }
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(recentIncomes, id: \.id) { income in
                                IncomeRowView(income: income)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .onAppear {
                loadIncomeData()
            }
        }
        .sheet(isPresented: $showingAddIncome) {
            SimpleAddIncomeView()
                .environmentObject(authManager)
        }
    }
    
    private func loadIncomeData() {
        guard let currentUser = authManager.currentUser else { return }
        
        let coreDataStack = CoreDataStack.shared
        if let userEntity = coreDataStack.fetchUser(by: currentUser.email) {
            let incomes = coreDataStack.fetchIncomes(for: userEntity)
            
            // Calculate totals
            totalIncome = incomes.compactMap { income in
                income.value(forKey: "amount") as? Double
            }.reduce(0, +)
            
            // Calculate monthly income
            let calendar = Calendar.current
            let now = Date()
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
            
            monthlyIncome = incomes.filter { income in
                guard let date = income.value(forKey: "dateReceived") as? Date else { return false }
                return date >= startOfMonth && date <= endOfMonth
            }.compactMap { income in
                income.value(forKey: "amount") as? Double
            }.reduce(0, +)
            
            // Convert to display items
            recentIncomes = incomes.prefix(5).compactMap { income in
                guard let id = income.value(forKey: "id") as? UUID,
                      let source = income.value(forKey: "source") as? String,
                      let category = income.value(forKey: "category") as? String,
                      let amount = income.value(forKey: "amount") as? Double,
                      let date = income.value(forKey: "dateReceived") as? Date else {
                    return nil
                }
                
                let icon = income.value(forKey: "categoryIcon") as? String ?? "banknote.fill"
                let isRecurring = income.value(forKey: "isRecurring") as? Bool ?? false
                
                return IncomeDisplayItem(
                    id: id,
                    source: source,
                    category: category,
                    amount: amount,
                    date: date,
                    icon: icon,
                    isRecurring: isRecurring
                )
            }
        }
    }
}

// MARK: - Supporting Views
struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            Text(formatCurrency(amount))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct IncomeRowView: View {
    let income: IncomeDisplayItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(Color.green.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: income.icon)
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                )
            
            // Details
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(income.source)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if income.isRecurring {
                        Image(systemName: "repeat")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                }
                
                Text(income.category)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text(formatDate(income.date))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount
            Text(formatCurrency(income.amount))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
}

struct EmptyIncomeView: View {
    let addAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green.opacity(0.6))
            
            Text("No Income Yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Start tracking your income")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Button(action: addAction) {
                Text("Add Income")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

// MARK: - Data Models
struct IncomeDisplayItem {
    let id: UUID
    let source: String
    let category: String
    let amount: Double
    let date: Date
    let icon: String
    let isRecurring: Bool
}

#Preview {
    IncomeDashboardView()
        .environmentObject(AuthenticationManager())
}

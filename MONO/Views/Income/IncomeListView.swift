//
//  IncomeListView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import SwiftUI

struct IncomeListView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingAddIncome = false
    @State private var selectedFilter: IncomeFilter = .all
    
    // Sample data for preview - replace with real data from IncomeManager
    @State private var incomes: [MockIncome] = MockIncome.sampleIncomes
    
    var filteredIncomes: [MockIncome] {
        switch selectedFilter {
        case .all:
            return incomes
        case .thisMonth:
            let calendar = Calendar.current
            let now = Date()
            return incomes.filter { income in
                calendar.isDate(income.dateReceived, equalTo: now, toGranularity: .month)
            }
        case .recurring:
            return incomes.filter { $0.isRecurring }
        }
    }
    
    var totalIncome: Double {
        filteredIncomes.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with total
                HeaderSection()
                
                // Filter Section
                FilterSection()
                
                // Income List
                if filteredIncomes.isEmpty {
                    EmptyStateView()
                } else {
                    IncomeListContent()
                }
                
                Spacer()
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddIncome) {
            AddIncomeView()
        }
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private func HeaderSection() -> some View {
        VStack(spacing: 16) {
            // Navigation
            HStack {
                Button(action: {
                    // Navigate back
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Income")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showingAddIncome = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Total Income Card
            VStack(spacing: 8) {
                Text("Total Income")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(formatCurrency(totalIncome))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                if selectedFilter != .all {
                    Text(selectedFilter.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Filter Section
    @ViewBuilder
    private func FilterSection() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(IncomeFilter.allCases, id: \.self) { filter in
                    FilterButton(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    // MARK: - Income List Content
    @ViewBuilder
    private func IncomeListContent() -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredIncomes, id: \.id) { income in
                    IncomeRowCard(income: income)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Empty State
    @ViewBuilder
    private func EmptyStateView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green.opacity(0.6))
            
            Text("No Income Yet")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Start tracking your income by adding your first entry")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                showingAddIncome = true
            }) {
                Text("Add Income")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
    
    // MARK: - Helper Methods
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.green : Color.gray.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Income Row Card
struct IncomeRowCard: View {
    let income: MockIncome
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Circle()
                .fill(income.categoryColor.opacity(0.15))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: income.categoryIcon)
                        .font(.system(size: 20))
                        .foregroundColor(income.categoryColor)
                )
            
            // Income Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(income.source)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if income.isRecurring {
                        Image(systemName: "repeat")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                }
                
                Text(income.category)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text(formatDate(income.dateReceived))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(income.amount))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
                
                if income.isRecurring, let frequency = income.recurringFrequency {
                    Text(frequency)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
        }
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Filter Options
enum IncomeFilter: String, CaseIterable {
    case all = "All"
    case thisMonth = "This Month"
    case recurring = "Recurring"
    
    var description: String {
        switch self {
        case .all:
            return "All time"
        case .thisMonth:
            return "Current month"
        case .recurring:
            return "Recurring only"
        }
    }
}

// MARK: - Mock Data (Remove when implementing real data)
struct MockIncome: Identifiable {
    let id = UUID()
    let source: String
    let category: String
    let categoryIcon: String
    let categoryColor: Color
    let amount: Double
    let dateReceived: Date
    let isRecurring: Bool
    let recurringFrequency: String?
    
    static let sampleIncomes: [MockIncome] = [
        MockIncome(
            source: "Tech Corp Inc.",
            category: "Salary",
            categoryIcon: "banknote.fill",
            categoryColor: .green,
            amount: 5500.00,
            dateReceived: Date(),
            isRecurring: true,
            recurringFrequency: "Monthly"
        ),
        MockIncome(
            source: "Freelance Project",
            category: "Freelance",
            categoryIcon: "laptopcomputer",
            categoryColor: .blue,
            amount: 1200.00,
            dateReceived: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            isRecurring: false,
            recurringFrequency: nil
        ),
        MockIncome(
            source: "Stock Dividends",
            category: "Investment",
            categoryIcon: "chart.line.uptrend.xyaxis",
            categoryColor: .purple,
            amount: 150.00,
            dateReceived: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
            isRecurring: true,
            recurringFrequency: "Quarterly"
        )
    ]
}

#Preview {
    IncomeListView()
        .environmentObject(AuthenticationManager())
}

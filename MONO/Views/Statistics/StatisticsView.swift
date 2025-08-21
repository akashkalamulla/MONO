//
//  StatisticsView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @State private var selectedPeriod = "Day"
    @State private var selectedType = "Expense"
    @State private var chartData: [ChartDataPoint] = []
    @State private var topSpending: [TopSpendingItem] = []
    @State private var totalAmount: Double = 1230
    
    let periods = ["Day", "Week", "Month", "Year"]
    let types = ["Income", "Expense"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    periodSelector
                    typeSelector
                    chartSection
                    topSpendingSection
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .background(Color.gray.opacity(0.05))
        }
        .onAppear {
            loadInitialData()
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("Statistics")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                // Export functionality
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
    }
    
    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(periods, id: \.self) { period in
                Button(action: {
                    selectedPeriod = period
                    updateChartData()
                }) {
                    Text(period)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedPeriod == period ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedPeriod == period ? 
                            Color.blue : Color.clear
                        )
                }
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var typeSelector: some View {
        HStack {
            Spacer()
            
            Menu {
                ForEach(types, id: \.self) { type in
                    Button(action: {
                        selectedType = type
                        updateChartData()
                    }) {
                        HStack {
                            Text(type)
                            if selectedType == type {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedType)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var chartSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Chart(chartData) { dataPoint in
                    LineMark(
                        x: .value("Time", dataPoint.date),
                        y: .value("Amount", dataPoint.amount)
                    )
                    .foregroundStyle(Color.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Time", dataPoint.date),
                        y: .value("Amount", dataPoint.amount)
                    )
                    .foregroundStyle(Color.blue.opacity(0.2))
                }
                .frame(height: 200)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Rs. \(String(format: "%.0f", totalAmount))")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.1), radius: 2)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding()
            }
            
            HStack {
                ForEach(getMonthLabels(), id: \.self) { month in
                    Text(month)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
    
    private var topSpendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Top Spending")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // Sort functionality
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(topSpending) { item in
                    TopSpendingRow(item: item)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func updateChartData() {
        // Generate sample data based on selected period and type
        chartData = generateSampleData(for: selectedPeriod, type: selectedType)
        topSpending = generateTopSpending(for: selectedType)
        totalAmount = chartData.max(by: { $0.amount < $1.amount })?.amount ?? 0
    }
    
    private func loadInitialData() {
        updateChartData()
    }
    
    private func getMonthLabels() -> [String] {
        switch selectedPeriod {
        case "Day":
            return ["6AM", "12PM", "6PM", "12AM"]
        case "Week":
            return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        case "Month":
            return ["Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct"]
        case "Year":
            return ["2020", "2021", "2022", "2023", "2024", "2025"]
        default:
            return ["Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct"]
        }
    }
    
    private func generateSampleData(for period: String, type: String) -> [ChartDataPoint] {
        let baseAmount = type == "Income" ? 2000.0 : 1200.0
        let variation = type == "Income" ? 500.0 : 300.0
        
        return (0..<8).map { index in
            ChartDataPoint(
                date: Date().addingTimeInterval(TimeInterval(index * 24 * 3600)),
                amount: baseAmount + Double.random(in: -variation...variation)
            )
        }
    }
    
    private func generateTopSpending(for type: String) -> [TopSpendingItem] {
        if type == "Income" {
            return [
                TopSpendingItem(
                    id: UUID(),
                    name: "Salary",
                    date: "Monthly",
                    amount: 85000.00,
                    icon: "dollarsign.circle.fill",
                    color: .green,
                    isIncome: true
                ),
                TopSpendingItem(
                    id: UUID(),
                    name: "Freelance",
                    date: "Aug 15, 2025",
                    amount: 25000.00,
                    icon: "laptopcomputer",
                    color: .blue,
                    isIncome: true
                ),
                TopSpendingItem(
                    id: UUID(),
                    name: "Investment",
                    date: "Aug 10, 2025",
                    amount: 15000.00,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple,
                    isIncome: true
                )
            ]
        } else {
            return [
                TopSpendingItem(
                    id: UUID(),
                    name: "Starbucks",
                    date: "Jan 12, 2025",
                    amount: 150.00,
                    icon: "cup.and.saucer.fill",
                    color: .green,
                    isIncome: false
                ),
                TopSpendingItem(
                    id: UUID(),
                    name: "Transfer",
                    date: "Yesterday",
                    amount: 850.00,
                    icon: "arrow.right.circle.fill",
                    color: .blue,
                    isIncome: false,
                    isHighlighted: true
                ),
                TopSpendingItem(
                    id: UUID(),
                    name: "YouTube",
                    date: "Jan 16, 2025",
                    amount: 119.90,
                    icon: "play.rectangle.fill",
                    color: .red,
                    isIncome: false
                ),
                TopSpendingItem(
                    id: UUID(),
                    name: "Grocery",
                    date: "Aug 18, 2025",
                    amount: 2500.00,
                    icon: "cart.fill",
                    color: .orange,
                    isIncome: false
                ),
                TopSpendingItem(
                    id: UUID(),
                    name: "Gas Station",
                    date: "Aug 17, 2025",
                    amount: 3200.00,
                    icon: "fuelpump.fill",
                    color: .blue,
                    isIncome: false
                )
            ]
        }
    }
}

// MARK: - Data Models
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

struct TopSpendingItem: Identifiable {
    let id: UUID
    let name: String
    let date: String
    let amount: Double
    let icon: String
    let color: Color
    let isIncome: Bool
    let isHighlighted: Bool
    
    init(id: UUID, name: String, date: String, amount: Double, icon: String, color: Color, isIncome: Bool, isHighlighted: Bool = false) {
        self.id = id
        self.name = name
        self.date = date
        self.amount = amount
        self.icon = icon
        self.color = color
        self.isIncome = isIncome
        self.isHighlighted = isHighlighted
    }
}

// MARK: - Top Spending Row Component
struct TopSpendingRow: View {
    let item: TopSpendingItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(item.color.opacity(0.2))
                    .frame(width: 45, height: 45)
                
                Image(systemName: item.icon)
                    .font(.system(size: 20))
                    .foregroundColor(item.color)
            }
            
            // Name and Date
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(item.date)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount
            Text("\(item.isIncome ? "+" : "-") Rs. \(String(format: "%.2f", item.amount))")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(item.isIncome ? .green : .red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            item.isHighlighted ? 
            Color.blue.opacity(0.1) : Color.white
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    StatisticsView()
}

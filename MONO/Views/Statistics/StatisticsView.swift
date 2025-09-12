//
//  StatisticsView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import SwiftUI
import Charts
import CoreData

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedPeriod = "Month"
    @State private var selectedType = "Expense"
    @State private var chartData: [ChartDataPoint] = []
    @State private var topSpending: [TopSpendingItem] = []
    @State private var totalAmount: Double = 0
    @State private var currentUser: NSManagedObject?
    @State private var isLoading = false
    // Insights feature removed
    
    @State private var incomes: [NSManagedObject] = []
    @State private var expenses: [NSManagedObject] = []

    let periods = ["Day", "Week", "Month", "Year"]
    let types = ["Income", "Expense"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    enhancedHeaderSection
                    enhancedSummaryCards
                    enhancedControlsSection
                    enhancedChartSection
                    enhancedTopSpendingSection
                    Spacer(minLength: 80)
                }
                .padding(.top, 8)
            }
            .background(
                LinearGradient(
                    colors: [Color.monoBackground, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .refreshable {
                await refreshData()
            }
        }
        .onAppear {
            loadCurrentUser()
            loadInitialData()
        }
        .onChange(of: selectedPeriod) { 
            loadRealData()
        }
        .onChange(of: selectedType) { 
            loadRealData()
        }
    }
    
    private func loadCurrentUser() {
        // Try to get current user from Core Data
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "UserEntity")
        request.predicate = NSPredicate(format: "isLoggedIn == %@", NSNumber(value: true))
        request.fetchLimit = 1
        
        do {
            let users = try viewContext.fetch(request)
            currentUser = users.first
        } catch {
            print("Error fetching current user: \(error)")
            currentUser = nil
        }
    }
    
    private func loadRealData() {
        guard let user = currentUser else {
            // Clear data when no user is found instead of showing sample data
            chartData = []
            topSpending = []
            totalAmount = 0
            return
        }
        
        let (startDate, endDate) = getDateRange(for: selectedPeriod)
        
        // Fetch incomes
        let incomeRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "IncomeEntity")
        incomeRequest.predicate = NSPredicate(format: "user == %@ AND date >= %@ AND date <= %@", user, startDate as NSDate, endDate as NSDate)
        incomeRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        // Fetch expenses  
        let expenseRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "ExpenseEntity")
        expenseRequest.predicate = NSPredicate(format: "user == %@ AND date >= %@ AND date <= %@", user, startDate as NSDate, endDate as NSDate)
        expenseRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let fetchedIncomes = try viewContext.fetch(incomeRequest)
            let fetchedExpenses = try viewContext.fetch(expenseRequest)
            
            if selectedType == "Income" {
                generateChartDataFromIncomes(fetchedIncomes)
                generateTopSpendingFromIncomes(fetchedIncomes)
            } else {
                generateChartDataFromExpenses(fetchedExpenses)
                generateTopSpendingFromExpenses(fetchedExpenses)
            }
        } catch {
            print("Error fetching real data: \(error)")
            // Clear data on error instead of showing sample data
            chartData = []
            topSpending = []
            totalAmount = 0
        }
    }
    
    private func getDateRange(for period: String) -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case "Day":
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return (startOfDay, endOfDay)
            
        case "Week":
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
            return (startOfWeek, endOfWeek)
            
        case "Month":
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            return (startOfMonth, endOfMonth)
            
        case "Year":
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!
            return (startOfYear, endOfYear)
            
        default:
            return getDateRange(for: "Month")
        }
    }
    
    private func generateChartDataFromIncomes(_ incomes: [NSManagedObject]) {
        chartData = incomes.compactMap { income in
            guard let date = income.value(forKey: "date") as? Date,
                  let amount = income.value(forKey: "amount") as? Double else {
                return nil
            }
            return ChartDataPoint(date: date, amount: amount)
        }
        
        totalAmount = chartData.reduce(0) { $0 + $1.amount }
    }
    
    private func generateChartDataFromExpenses(_ expenses: [NSManagedObject]) {
        chartData = expenses.compactMap { expense in
            guard let date = expense.value(forKey: "date") as? Date,
                  let amount = expense.value(forKey: "amount") as? Double else {
                return nil
            }
            return ChartDataPoint(date: date, amount: amount)
        }
        
        totalAmount = chartData.reduce(0) { $0 + $1.amount }
    }
    
    private func generateTopSpendingFromIncomes(_ incomes: [NSManagedObject]) {
        topSpending = incomes.compactMap { income in
            guard let amount = income.value(forKey: "amount") as? Double,
                  let date = income.value(forKey: "date") as? Date,
                  let categoryName = income.value(forKey: "categoryName") as? String else {
                return nil
            }
            
            let categoryIcon = income.value(forKey: "categoryIcon") as? String ?? "dollarsign.circle.fill"
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            
            return TopSpendingItem(
                id: UUID(),
                name: categoryName,
                date: formatter.string(from: date),
                amount: amount,
                icon: categoryIcon,
                color: .green,
                isIncome: true
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    private func generateTopSpendingFromExpenses(_ expenses: [NSManagedObject]) {
        topSpending = expenses.compactMap { expense in
            guard let amount = expense.value(forKey: "amount") as? Double,
                  let date = expense.value(forKey: "date") as? Date,
                  let category = expense.value(forKey: "category") as? String else {
                return nil
            }
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            
            // Map expense category to icon and color
            let (icon, color) = getExpenseCategoryIconAndColor(for: category)
            
            return TopSpendingItem(
                id: UUID(),
                name: category,
                date: formatter.string(from: date),
                amount: amount,
                icon: icon,
                color: color,
                isIncome: false
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    private func getExpenseCategoryIconAndColor(for category: String) -> (String, Color) {
        switch category.lowercased() {
        case "food & dining", "food":
            return ("fork.knife", .orange)
        case "transportation", "transport":
            return ("car.fill", .blue)
        case "housing":
            return ("house.fill", .green)
        case "utilities":
            return ("bolt.fill", .yellow)
        case "shopping":
            return ("bag.fill", .purple)
        case "healthcare":
            return ("cross.fill", .red)
        case "entertainment":
            return ("tv.fill", .pink)
        case "education":
            return ("book.fill", .indigo)
        default:
            return ("ellipsis.circle.fill", .gray)
        }
    }
    
    private var enhancedHeaderSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Financial Analytics")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.monoPrimary)
                    
                    Text("Track your financial patterns")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var enhancedSummaryCards: some View {
        HStack(spacing: 12) {
            SummaryCard(
                title: selectedType == "Income" ? "Total Income" : "Total Expenses",
                value: "Rs. \(String(format: "%.0f", totalAmount))",
                icon: selectedType == "Income" ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                color: selectedType == "Income" ? .green : .red,
                trend: getTrendPercentage(),
                isPositive: selectedType == "Income" ? true : getTrendPercentage() < 0
            )
            
            SummaryCard(
                title: "This Period",
                value: "\(chartData.count) entries",
                icon: "calendar",
                color: .monoPrimary,
                trend: nil,
                isPositive: true
            )
        }
        .padding(.horizontal, 20)
    }
    
    private var enhancedControlsSection: some View {
        VStack(spacing: 16) {
            // Period Selector
            VStack(spacing: 8) {
                HStack {
                    Text("Time Period")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.monoPrimary)
                    
                    Spacer()
                    
                    Text(selectedPeriod)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 0) {
                    ForEach(periods, id: \.self) { period in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPeriod = period
                                updateChartData()
                            }
                        }) {
                            Text(period)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedPeriod == period ? .white : .monoPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    selectedPeriod == period ? 
                                    LinearGradient(colors: [Color.monoPrimary, Color.monoSecondary], startPoint: .leading, endPoint: .trailing) : 
                                    LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(14)
                .padding(.horizontal, 20)
            }
            
            // Type Selector with improved design
            HStack {
                Text("Category")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.monoPrimary)
                
                Spacer()
                
                Menu {
                    ForEach(types, id: \.self) { type in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedType = type
                                updateChartData()
                            }
                        }) {
                            HStack {
                                Image(systemName: type == "Income" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                    .foregroundColor(type == "Income" ? .green : .red)
                                Text(type)
                                if selectedType == type {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.monoPrimary)
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: selectedType == "Income" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .foregroundColor(selectedType == "Income" ? .green : .red)
                        
                        Text(selectedType)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.monoPrimary)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.monoShadow, radius: 2, x: 0, y: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
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
    
    private var enhancedChartSection: some View {
        VStack(spacing: 16) {
            // Chart Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trends")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.monoPrimary)
                    
                    Text("\(selectedPeriod)ly overview")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Chart type buttons
                HStack(spacing: 8) {
                    Button(action: {}) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.monoPrimary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.monoPrimary.opacity(0.1)))
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.gray.opacity(0.1)))
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Enhanced Chart
            VStack(spacing: 12) {
                ZStack {
                    // Background grid
                    VStack(spacing: 0) {
                        ForEach(0..<4, id: \.self) { _ in
                            Divider()
                                .background(Color.gray.opacity(0.2))
                            Spacer()
                        }
                    }
                    .frame(height: 200)
                    
                    if chartData.isEmpty {
                        // Empty state for chart
                        VStack(spacing: 16) {
                            Image(systemName: selectedType == "Income" ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.gray.opacity(0.4))
                            
                            VStack(spacing: 4) {
                                Text("No \(selectedType) Data")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.monoPrimary)
                                
                                Text("Add some \(selectedType.lowercased()) entries to see trends")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(height: 200)
                    } else {
                        Chart(chartData) { dataPoint in
                            LineMark(
                                x: .value("Time", dataPoint.date),
                                y: .value("Amount", dataPoint.amount)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: selectedType == "Income" ? 
                                    [Color.green, Color.green.opacity(0.8)] : 
                                    [Color.monoPrimary, Color.monoSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            .symbol(Circle().strokeBorder(lineWidth: 2))
                            .symbolSize(40)
                            
                            AreaMark(
                                x: .value("Time", dataPoint.date),
                                y: .value("Amount", dataPoint.amount)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: selectedType == "Income" ? 
                                    [Color.green.opacity(0.3), Color.green.opacity(0.1)] : 
                                    [Color.monoPrimary.opacity(0.3), Color.monoPrimary.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                        .frame(height: 200)
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        
                        // Floating total amount - only show when there's data
                        VStack {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Total")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Text("Rs. \(String(format: "%.0f", totalAmount))")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(selectedType == "Income" ? .green : .monoPrimary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: Color.monoShadow, radius: 8, x: 0, y: 4)
                                )
                                
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding()
                    }
                }
                
                // Enhanced axis labels - only show when there's data
                if !chartData.isEmpty {
                    HStack {
                        ForEach(getMonthLabels(), id: \.self) { month in
                            Text(month)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.monoShadow, radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, 20)
        }
    }
    
    // Insights section removed
    
    private var enhancedTopSpendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Top \(selectedType == "Income" ? "Income Sources" : "Expenses")")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.monoPrimary)
                    
                    Text("Highest transactions this \(selectedPeriod.lowercased())")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    // Sort functionality
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 14))
                        Text("Sort")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.monoPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.monoPrimary.opacity(0.1))
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 20)
            
            if topSpending.isEmpty {
                EmptyStateView(
                    icon: selectedType == "Income" ? "arrow.up.circle" : "arrow.down.circle",
                    title: "No \(selectedType) Data",
                    description: "Start tracking your \(selectedType.lowercased()) to see insights here"
                )
                .padding(.horizontal, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(topSpending.enumerated()), id: \.element.id) { index, item in
                        EnhancedTopSpendingRow(item: item, rank: index + 1)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func updateChartData() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isLoading = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.5)) {
                loadRealData()
                isLoading = false
            }
        }
    }
    
    private func loadInitialData() {
        loadRealData()
    }
    
    private func refreshData() async {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.5)) {
                loadRealData()
                isLoading = false
            }
        }
    }
    
    private func getTrendPercentage() -> Double {
        // Calculate real trend by comparing current period with previous period
        guard let user = currentUser else { return 0 }
        
        let (currentStartDate, currentEndDate) = getDateRange(for: selectedPeriod)
        let (previousStartDate, previousEndDate) = getPreviousDateRange(for: selectedPeriod)
        
        // Fetch current period data
        let currentRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: selectedType == "Income" ? "IncomeEntity" : "ExpenseEntity")
        currentRequest.predicate = NSPredicate(format: "user == %@ AND date >= %@ AND date <= %@", user, currentStartDate as NSDate, currentEndDate as NSDate)
        
        // Fetch previous period data
        let previousRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: selectedType == "Income" ? "IncomeEntity" : "ExpenseEntity")
        previousRequest.predicate = NSPredicate(format: "user == %@ AND date >= %@ AND date <= %@", user, previousStartDate as NSDate, previousEndDate as NSDate)
        
        do {
            let currentData = try viewContext.fetch(currentRequest)
            let previousData = try viewContext.fetch(previousRequest)
            
            let currentTotal = currentData.compactMap { $0.value(forKey: "amount") as? Double }.reduce(0, +)
            let previousTotal = previousData.compactMap { $0.value(forKey: "amount") as? Double }.reduce(0, +)
            
            guard previousTotal > 0 else { return 0 }
            
            return ((currentTotal - previousTotal) / previousTotal) * 100
        } catch {
            print("Error calculating trend: \(error)")
            return 0
        }
    }
    
    private func getPreviousDateRange(for period: String) -> (Date, Date) {
        let calendar = Calendar.current
        let (currentStart, _) = getDateRange(for: period)
        
        switch period {
        case "Day":
            let previousStart = calendar.date(byAdding: .day, value: -1, to: currentStart)!
            let previousEnd = calendar.date(byAdding: .day, value: 1, to: previousStart)!
            return (previousStart, previousEnd)
            
        case "Week":
            let previousStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentStart)!
            let previousEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: previousStart)!
            return (previousStart, previousEnd)
            
        case "Month":
            let previousStart = calendar.date(byAdding: .month, value: -1, to: currentStart)!
            let previousEnd = calendar.date(byAdding: .month, value: 1, to: previousStart)!
            return (previousStart, previousEnd)
            
        case "Year":
            let previousStart = calendar.date(byAdding: .year, value: -1, to: currentStart)!
            let previousEnd = calendar.date(byAdding: .year, value: 1, to: previousStart)!
            return (previousStart, previousEnd)
            
        default:
            return getPreviousDateRange(for: "Month")
        }
    }
    
    private func getMonthLabels() -> [String] {
        let calendar = Calendar.current
        let (startDate, endDate) = getDateRange(for: selectedPeriod)
        
        switch selectedPeriod {
        case "Day":
            return ["6AM", "12PM", "6PM", "12AM"]
        case "Week":
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            var labels: [String] = []
            var currentDate = startDate
            while currentDate < endDate {
                labels.append(formatter.string(from: currentDate))
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                if labels.count >= 7 { break }
            }
            return labels
        case "Month":
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            var labels: [String] = []
            var currentDate = startDate
            for _ in 0..<8 {
                labels.append(formatter.string(from: currentDate))
                currentDate = calendar.date(byAdding: .day, value: 4, to: currentDate) ?? currentDate
            }
            return labels
        case "Year":
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            var labels: [String] = []
            var currentDate = startDate
            for _ in 0..<12 {
                labels.append(formatter.string(from: currentDate))
                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
            }
            return labels
        default:
            return ["No Data"]
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

// MARK: - Enhanced UI Components

// Scale Button Style for better interactions
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Enhanced Summary Card
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: Double?
    let isPositive: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                
                Spacer()
                
                if let trend = trend {
                    HStack(spacing: 4) {
                        Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                            .font(.system(size: 10, weight: .bold))
                        Text("\(String(format: "%.1f", abs(trend)))%")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(isPositive ? .green : .red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill((isPositive ? Color.green : Color.red).opacity(0.1))
                    )
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.monoPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.monoShadow, radius: 4, x: 0, y: 2)
        )
    }
}

// Insight Card Component
struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.monoPrimary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.monoShadow, radius: 2, x: 0, y: 1)
        )
    }
}

// Enhanced Top Spending Row
struct EnhancedTopSpendingRow: View {
    let item: TopSpendingItem
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank indicator
            ZStack {
                Circle()
                    .fill(getRankColor().opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text("\(rank)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(getRankColor())
            }
            
            // Enhanced Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [item.color.opacity(0.2), item.color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(item.color)
            }
            
            // Enhanced Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.monoPrimary)
                    
                    Spacer()
                    
                    Text("\(item.isIncome ? "+" : "")Rs. \(String(format: "%.0f", item.amount))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(item.isIncome ? .green : .monoPrimary)
                }
                
                HStack {
                    Text(item.date)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Category badge
                    Text(item.isIncome ? "Income" : "Expense")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(item.isIncome ? .green : .red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill((item.isIncome ? Color.green : Color.red).opacity(0.1))
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(item.isHighlighted ? Color.monoPrimary.opacity(0.05) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(item.isHighlighted ? Color.monoPrimary.opacity(0.2) : Color.clear, lineWidth: 1)
                )
                .shadow(color: Color.monoShadow, radius: 3, x: 0, y: 1)
        )
    }
    
    private func getRankColor() -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .monoPrimary
        }
    }
}

// Empty State Component
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.gray.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.monoPrimary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 32)
    }
}

// Legacy component for compatibility
struct TopSpendingRow: View {
    let item: TopSpendingItem
    
    var body: some View {
        EnhancedTopSpendingRow(item: item, rank: 1)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}

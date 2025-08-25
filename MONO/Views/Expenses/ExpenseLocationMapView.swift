//
//  ExpenseLocationMapView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-25.
//

import SwiftUI
import MapKit
import CoreData

struct ExpenseLocationMapView: View {
    @StateObject private var coreDataStack = CoreDataStack.shared
    @State private var expenses: [ExpenseLocationData] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612), // Sri Lanka center
        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
    )
    @State private var showingHeatmap = true
    @State private var selectedPeriod: TimePeriod = .all
    @State private var isLoading = true
    @State private var showingListView = false
    
    enum TimePeriod: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
        case all = "All Time"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
            
                VStack(spacing: 12) {
              
                    Picker("Time Period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
       
                    HStack {
                        Button(action: { showingHeatmap.toggle() }) {
                            HStack {
                                Image(systemName: showingHeatmap ? "flame.fill" : "flame")
                                Text(showingHeatmap ? "Hide Heatmap" : "Show Heatmap")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(showingHeatmap ? Color.red : Color.gray.opacity(0.2))
                            .foregroundColor(showingHeatmap ? .white : .primary)
                            .cornerRadius(20)
                        }
                        
                        Button(action: { showingListView.toggle() }) {
                            HStack {
                                Image(systemName: showingListView ? "map.fill" : "list.bullet")
                                Text(showingListView ? "Map View" : "List View")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(20)
                        }
                        
                        Spacer()
                        
                        Text("\(filteredExpenses.count) locations")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(UIColor.systemBackground))
                
                Divider()
                
                if isLoading {
                    VStack {
                        ProgressView()
                        Text("Loading expense locations...")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if expenses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Location Data")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Start adding expenses with locations to see them on the map")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    if showingListView {
                  
                        ExpenseLocationListContentView(expenses: filteredExpenses)
                    } else {
           
                        ZStack {
                            Map(coordinateRegion: $region, 
                                showsUserLocation: true,
                                annotationItems: showingHeatmap ? [] : filteredExpenses) { location in
                                MapAnnotation(coordinate: location.coordinate) {
                                    ExpenseMapPin(location: location)
                                }
                            }
                            .edgesIgnoringSafeArea(.bottom)
                    
                            if showingHeatmap {
                                HeatmapOverlay(expenses: filteredExpenses)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                }
                
         
                if !expenses.isEmpty {
                    ExpenseLocationStats(expenses: filteredExpenses)
                        .background(Color(UIColor.systemBackground))
                }
            }
            .navigationTitle("Expense Locations")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadExpenseLocations()
            }
            .onChange(of: selectedPeriod) { _ in
                loadExpenseLocations()
            }
        }
    }
    
    private var filteredExpenses: [ExpenseLocationData] {
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedPeriod {
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return expenses.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return expenses.filter { $0.date >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return expenses.filter { $0.date >= yearAgo }
        case .all:
            return expenses
        }
    }
    
    private func loadExpenseLocations() {
        isLoading = true
        
        guard let currentUser = coreDataStack.fetchCurrentUser() else {
            isLoading = false
            return
        }
        
        let fetchedExpenses = coreDataStack.fetchExpenses(for: currentUser)
        

        expenses = fetchedExpenses.compactMap { expense in
            guard let locationName = expense.value(forKey: "locationName") as? String,
                  !locationName.isEmpty,
                  let latitude = expense.value(forKey: "latitude") as? Double,
                  let longitude = expense.value(forKey: "longitude") as? Double,
                  let date = expense.date else {
                return nil
            }
            
            return ExpenseLocationData(
                id: expense.id ?? UUID(),
                locationName: locationName,
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                amount: expense.amount,
                category: expense.category ?? "Other",
                date: date
            )
        }
        
 
        if !expenses.isEmpty {
            updateMapRegion()
        }
        
        isLoading = false
    }
    
    private func updateMapRegion() {
        let coordinates = expenses.map { $0.coordinate }
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        let minLat = latitudes.min() ?? 6.9271
        let maxLat = latitudes.max() ?? 6.9271
        let minLon = longitudes.min() ?? 79.8612
        let maxLon = longitudes.max() ?? 79.8612
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.2, 0.05),
            longitudeDelta: max((maxLon - minLon) * 1.2, 0.05)
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
}



struct ExpenseMapPin: View {
    let location: ExpenseLocationData
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail.toggle() }) {
            ZStack {
                Circle()
                    .fill(categoryColor(for: location.category))
                    .frame(width: 30, height: 30)
                
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
        }
        .popover(isPresented: $showingDetail) {
            VStack(alignment: .leading, spacing: 8) {
                Text(location.locationName)
                    .font(.headline)
                
                Text(location.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Rs. \(String(format: "%.2f", location.amount))")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(formatDate(location.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(minWidth: 200)
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        let categories = ExpenseCategory.defaultCategories
        if let categoryObj = categories.first(where: { $0.name == category }) {
            return Color(hex: categoryObj.color)
        }
        return .blue
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}



struct HeatmapOverlay: View {
    let expenses: [ExpenseLocationData]
    
    var body: some View {
        Canvas { context, size in

            let groupedExpenses = groupNearbyExpenses(expenses)
            
            for group in groupedExpenses {
                let intensity = calculateIntensity(for: group)
                let radius = calculateRadius(for: group, maxRadius: 50)
                
    
                let centerX = size.width * 0.5
                let centerY = size.height * 0.5
                
                let gradient = Gradient(colors: [
                    Color.red.opacity(intensity),
                    Color.yellow.opacity(intensity * 0.7),
                    Color.clear
                ])
                
                context.fill(
                    Circle().path(in: CGRect(x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2)),
                    with: .radialGradient(gradient, center: CGPoint(x: centerX, y: centerY), startRadius: 0, endRadius: radius)
                )
            }
        }
    }
    
    private func groupNearbyExpenses(_ expenses: [ExpenseLocationData]) -> [[ExpenseLocationData]] {
        var groups: [[ExpenseLocationData]] = []
        var remaining = expenses
        
        while !remaining.isEmpty {
            let first = remaining.removeFirst()
            var group = [first]
            
            remaining.removeAll { expense in
                let distance = first.coordinate.distance(to: expense.coordinate)
                if distance < 1000 {
                    group.append(expense)
                    return true
                }
                return false
            }
            
            groups.append(group)
        }
        
        return groups
    }
    
    private func calculateIntensity(for group: [ExpenseLocationData]) -> Double {
        let totalAmount = group.reduce(0) { $0 + $1.amount }
        return min(totalAmount / 10000, 1.0)
    }
    
    private func calculateRadius(for group: [ExpenseLocationData], maxRadius: Double) -> Double {
        let count = Double(group.count)
        return min(maxRadius * (count / 10), maxRadius)
    }
}


struct ExpenseLocationStats: View {
    let expenses: [ExpenseLocationData]
    
    var body: some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Spent")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Rs. \(String(format: "%.2f", totalAmount))")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Locations")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(expenses.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Most Expensive")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Rs. \(String(format: "%.2f", maxAmount))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
    
    private var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    private var maxAmount: Double {
        expenses.map { $0.amount }.max() ?? 0
    }
}


struct ExpenseLocationListContentView: View {
    let expenses: [ExpenseLocationData]
    
    var body: some View {
        List {
            ForEach(groupedExpenses.keys.sorted(), id: \.self) { locationName in
                Section(header: LocationSectionHeader(locationName: locationName, expenses: groupedExpenses[locationName] ?? [])) {
                    ForEach(groupedExpenses[locationName] ?? [], id: \.id) { expense in
                        ExpenseLocationRowCompact(expense: expense)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private var groupedExpenses: [String: [ExpenseLocationData]] {
        Dictionary(grouping: expenses) { $0.locationName }
    }
}


struct ExpenseLocationRowCompact: View {
    let expense: ExpenseLocationData
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(categoryColor(for: expense.category).opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: categoryIcon(for: expense.category))
                    .font(.system(size: 14))
                    .foregroundColor(categoryColor(for: expense.category))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(formatDate(expense.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
        
            Text("Rs. \(String(format: "%.2f", expense.amount))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 2)
    }
    
    private func categoryColor(for category: String) -> Color {
        let categories = ExpenseCategory.defaultCategories
        if let categoryObj = categories.first(where: { $0.name == category }) {
            return Color(hex: categoryObj.color)
        }
        return .blue
    }
    
    private func categoryIcon(for category: String) -> String {
        let categories = ExpenseCategory.defaultCategories
        if let categoryObj = categories.first(where: { $0.name == category }) {
            return categoryObj.icon
        }
        return "dollarsign.circle"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct ExpenseLocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseLocationMapView()
    }
}

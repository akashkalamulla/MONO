//
//  ExpenseLocationMapView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-25.
//

import SwiftUI
import MapKit
import CoreData

// Shared header control styling for the heatmap / list / badge controls
fileprivate struct HeaderControlStyle: ViewModifier {
    var isPrimary: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isPrimary ?
                        LinearGradient(colors: [Color.red.opacity(0.8), Color.orange.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [Color.monoBackground, Color.monoBackground], startPoint: .leading, endPoint: .trailing)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isPrimary ? Color.clear : Color.monoPrimary.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: isPrimary ? Color.red.opacity(0.25) : Color.clear, radius: isPrimary ? 4 : 0, x: 0, y: isPrimary ? 2 : 0)
    }
}

struct ExpenseLocationMapView: View {
    @StateObject private var coreDataStack = CoreDataStack.shared
    @State private var expenses: [ExpenseLocationData] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
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
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("Time Period")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.monoPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        Picker("Time Period", selection: $selectedPeriod) {
                            ForEach(TimePeriod.allCases, id: \.self) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                    }

                    HStack(spacing: 12) {

                        Button(action: { 
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingHeatmap.toggle() 
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: showingHeatmap ? "flame.fill" : "flame")
                                    .font(.system(size: 14, weight: .medium))
                                Text(showingHeatmap ? "Hide Heatmap" : "Show Heatmap")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(showingHeatmap ? .white : .monoPrimary)
                            .modifier(HeaderControlStyle(isPrimary: showingHeatmap))
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                   
                        Button(action: { 
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingListView.toggle() 
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: showingListView ? "map.fill" : "list.bullet")
                                    .font(.system(size: 14, weight: .medium))
                                Text(showingListView ? "Map View" : "List View")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.monoPrimary)
                            .modifier(HeaderControlStyle(isPrimary: false))
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        Spacer()
                        
     
                        VStack(spacing: 2) {
                            Text("\(filteredExpenses.count)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.monoPrimary)
                            Text("locations")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .modifier(HeaderControlStyle(isPrimary: false))
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
                .background(
                    Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: Color.monoShadow, radius: 2, x: 0, y: 1)
                )
                

                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.monoPrimary)
                        
                        VStack(spacing: 8) {
                            Text("Loading Expense Locations")
                                .font(.headline)
                                .foregroundColor(.monoPrimary)
                            
                            Text("Mapping your spending patterns...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.monoBackground.opacity(0.5))
                    
  
               } else if expenses.isEmpty {
                    VStack(spacing: 24) {

                        ZStack {
                            Circle()
                                .fill(Color.monoPrimary.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "location.slash.fill")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(.monoPrimary.opacity(0.6))
                        }
                        
                        VStack(spacing: 12) {
                            Text("No Location Data")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.monoPrimary)
                            
                            Text("Start adding expenses with locations to visualize your spending patterns on the map")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .padding(.horizontal, 32)
                        }
                        
             
                        Button(action: {
                          
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add First Expense")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.monoPrimary)
                            )
                            .shadow(color: Color.monoPrimary.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.monoBackground.opacity(0.3))
                } else {
                    if showingListView {

                        ExpenseLocationListContentView(expenses: filteredExpenses)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else {
                 
                        ZStack {
                            Map(coordinateRegion: $region, 
                                showsUserLocation: true,
                                annotationItems: showingHeatmap ? [] : filteredExpenses) { location in
                                MapAnnotation(coordinate: location.coordinate) {
                                    EnhancedExpenseMapPin(location: location)
                                }
                            }
                            .mapStyle(.standard(elevation: .realistic))
                            .cornerRadius(0)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    
     
                            if showingHeatmap {
                                EnhancedHeatmapOverlay(expenses: filteredExpenses)
                                    .allowsHitTesting(false)
                                    .transition(.opacity)
                            }
                            

                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    VStack(spacing: 8) {
                                    
                                        Button(action: updateMapRegion) {
                                            Image(systemName: "scope")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.monoPrimary)
                                                .frame(width: 44, height: 44)
                                                .background(
                                                    Circle()
                                                        .fill(Color.white)
                                                        .shadow(color: Color.monoShadow, radius: 4, x: 0, y: 2)
                                                )
                                        }
                                        .buttonStyle(ScaleButtonStyle())
                                        
           
                                        Button(action: centerOnUserLocation) {
                                            Image(systemName: "location.fill")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.monoPrimary)
                                                .frame(width: 44, height: 44)
                                                .background(
                                                    Circle()
                                                        .fill(Color.white)
                                                        .shadow(color: Color.monoShadow, radius: 4, x: 0, y: 2)
                                                )
                                        }
                                        .buttonStyle(ScaleButtonStyle())
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.trailing, 16)
                            .padding(.top, 16)
                        }
                    }
                }
                
          
                if !expenses.isEmpty && !isLoading {
                    EnhancedExpenseLocationStats(expenses: filteredExpenses)
                        .background(
                            Rectangle()
                                .fill(Color(UIColor.systemBackground))
                                .shadow(color: Color.monoShadow, radius: 2, x: 0, y: -1)
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Expense Locations")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadExpenseLocations()
            }
            .onChange(of: selectedPeriod) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    loadExpenseLocations()
                }
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
        guard !expenses.isEmpty else { return }
        
        withAnimation(.easeInOut(duration: 0.5)) {
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
    
    private func centerOnUserLocation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
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


struct EnhancedExpenseMapPin: View {
    let location: ExpenseLocationData
    @State private var showingDetail = false
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: { 
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showingDetail.toggle()
            }
        }) {
            ZStack {
     
                Circle()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .offset(y: 2)
                

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                categoryColor(for: location.category),
                                categoryColor(for: location.category).opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 34, height: 34)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                

                Image(systemName: categoryIcon(for: location.category))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
 
                if location.amount > 5000 {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .offset(x: 12, y: -12)
                        .overlay(
                            Text("!")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: 12, y: -12)
                        )
                }
            }
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
        }
        .onAppear {
       
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...0.5)) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        isAnimating = false
                    }
                }
            }
        }
        .sheet(isPresented: $showingDetail) {
            ExpenseDetailSheet(location: location)
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        let categories = ExpenseCategory.defaultCategories
        if let categoryObj = categories.first(where: { $0.name == category }) {
            return Color(hex: categoryObj.color)
        }
        return .monoPrimary
    }
    
    private func categoryIcon(for category: String) -> String {
        let categories = ExpenseCategory.defaultCategories
        if let categoryObj = categories.first(where: { $0.name == category }) {
            return categoryObj.icon
        }
        return "dollarsign.circle"
    }
}


struct ExpenseDetailSheet: View {
    let location: ExpenseLocationData
    
    var body: some View {
        VStack(spacing: 20) {
 
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 6)
                .padding(.top, 8)
            
            VStack(spacing: 16) {
      
                HStack {
                    ZStack {
                        Circle()
                            .fill(categoryColor(for: location.category).opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: categoryIcon(for: location.category))
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(categoryColor(for: location.category))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.locationName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.monoPrimary)
                        
                        Text(location.category)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
          
                VStack(spacing: 4) {
                    Text("Amount Spent")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("Rs. \(String(format: "%.2f", location.amount))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.monoPrimary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.monoBackground)
                )
                
 
                VStack(spacing: 8) {
                    HStack {
                        Label("Date", systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(formatDate(location.date))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Label("Location", systemImage: "location")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.4f", location.coordinate.latitude)), \(String(format: "%.4f", location.coordinate.longitude))")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.monoPrimary)
                    }
                }
                

                Button(action: openInMaps) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Open in Maps")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.monoPrimary)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        let categories = ExpenseCategory.defaultCategories
        if let categoryObj = categories.first(where: { $0.name == category }) {
            return Color(hex: categoryObj.color)
        }
        return .monoPrimary
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
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func openInMaps() {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let url = URL(string: "maps://?q=\(latitude),\(longitude)")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}


struct EnhancedHeatmapOverlay: View {
    let expenses: [ExpenseLocationData]
    
    var body: some View {
        Canvas { context, size in
            let groupedExpenses = groupNearbyExpenses(expenses)
            
            for group in groupedExpenses {
                let intensity = calculateIntensity(for: group)
                let radius = calculateRadius(for: group, maxRadius: 60)

                let centerX = size.width * 0.5 + CGFloat.random(in: -size.width*0.3...size.width*0.3)
                let centerY = size.height * 0.5 + CGFloat.random(in: -size.height*0.3...size.height*0.3)
                
                let gradient = Gradient(colors: [
                    Color.red.opacity(intensity * 0.8),
                    Color.orange.opacity(intensity * 0.6),
                    Color.yellow.opacity(intensity * 0.4),
                    Color.clear
                ])
                
                let rect = CGRect(x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2)
                
                context.fill(
                    Circle().path(in: rect),
                    with: .radialGradient(
                        gradient,
                        center: CGPoint(x: centerX, y: centerY),
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
        }
        .blendMode(.multiply)
    }
    
    private func groupNearbyExpenses(_ expenses: [ExpenseLocationData]) -> [[ExpenseLocationData]] {
        var groups: [[ExpenseLocationData]] = []
        var remaining = expenses
        
        while !remaining.isEmpty {
            let first = remaining.removeFirst()
            var group = [first]
            
            remaining.removeAll { expense in
                let distance = first.coordinate.distance(to: expense.coordinate)
                if distance < 2000 { // Increased grouping distance
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
        let count = Double(group.count)
        return min((totalAmount / 15000) * (count / 5), 1.0)
    }
    
    private func calculateRadius(for group: [ExpenseLocationData], maxRadius: Double) -> Double {
        let count = Double(group.count)
        let amount = group.reduce(0) { $0 + $1.amount }
        return min(maxRadius * (count / 8) * (amount / 20000), maxRadius)
    }
}


struct EnhancedExpenseLocationStats: View {
    let expenses: [ExpenseLocationData]
    
    var body: some View {
        VStack(spacing: 0) {
    
            LinearGradient(
                colors: [Color.clear, Color.monoPrimary.opacity(0.3), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
            
            VStack(spacing: 16) {
          
                HStack {
                    Text("Spending Summary")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.monoPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.monoPrimary.opacity(0.6))
                }
                
         
                HStack(spacing: 16) {
                    StatCard(
                        title: "Total Spent",
                        value: "Rs. \(String(format: "%.0f", totalAmount))",
                        icon: "creditcard.fill",
                        color: .monoPrimary
                    )
                    
                    StatCard(
                        title: "Locations",
                        value: "\(expenses.count)",
                        icon: "location.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Highest",
                        value: "Rs. \(String(format: "%.0f", maxAmount))",
                        icon: "exclamationmark.triangle.fill",
                        color: .red
                    )
                    
                    StatCard(
                        title: "Average",
                        value: "Rs. \(String(format: "%.0f", averageAmount))",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .orange
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    private var maxAmount: Double {
        expenses.map { $0.amount }.max() ?? 0
    }
    
    private var averageAmount: Double {
        guard !expenses.isEmpty else { return 0 }
        return totalAmount / Double(expenses.count)
    }
}


struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ExpenseLocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseLocationMapView()
    }
}

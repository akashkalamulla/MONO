//
//  ExpenseLocationListView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-25.
//

import SwiftUI
import CoreData
import CoreLocation
import UIKit

struct ExpenseLocationListView: View {
    @StateObject private var coreDataStack = CoreDataStack.shared
    @State private var expenses: [ExpenseLocationData] = []
    @State private var selectedPeriod: TimePeriod = .all
    @State private var isLoading = true
    @State private var searchText = ""
    
    enum TimePeriod: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
        case all = "All Time"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Controls
                VStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search locations...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Period selector
                    Picker("Time Period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
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
                } else if filteredExpenses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Location Data")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Start adding expenses with locations to see them here")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        // Group by location name
                        ForEach(groupedExpenses.keys.sorted(), id: \.self) { locationName in
                            Section(header: LocationSectionHeader(locationName: locationName, expenses: groupedExpenses[locationName] ?? [])) {
                                ForEach(groupedExpenses[locationName] ?? [], id: \.id) { expense in
                                    ExpenseLocationRow(expense: expense)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
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
        
        var timeFiltered: [ExpenseLocationData]
        
        switch selectedPeriod {
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            timeFiltered = expenses.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            timeFiltered = expenses.filter { $0.date >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            timeFiltered = expenses.filter { $0.date >= yearAgo }
        case .all:
            timeFiltered = expenses
        }
        
        // Apply search filter
        if searchText.isEmpty {
            return timeFiltered
        } else {
            return timeFiltered.filter { expense in
                expense.locationName.localizedCaseInsensitiveContains(searchText) ||
                expense.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var groupedExpenses: [String: [ExpenseLocationData]] {
        Dictionary(grouping: filteredExpenses) { $0.locationName }
    }
    
    private func loadExpenseLocations() {
        isLoading = true
        
        guard let currentUser = coreDataStack.fetchCurrentUser() else {
            isLoading = false
            return
        }
        
        let fetchedExpenses = coreDataStack.fetchExpenses(for: currentUser)
        
        // Convert to location data
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
        
        isLoading = false
    }
}

struct ExpenseLocationListView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseLocationListView()
    }
}

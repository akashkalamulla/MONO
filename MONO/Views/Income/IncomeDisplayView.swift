//
//  IncomeDisplayView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import SwiftUI

struct IncomeDisplayView: View {
    @State private var savedIncomes: [SavedIncome] = []
    
    var body: some View {
        NavigationView {
            List {
                if savedIncomes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Income Records")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Add your first income using the 'Add Income' button")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(savedIncomes) { income in
                        IncomeRow(income: income)
                    }
                    .onDelete(perform: deleteIncome)
                }
            }
            .navigationTitle("Income Records")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Income") {
                        // This would trigger the add income sheet
                        // For now, let's add a sample entry
                        addSampleIncome()
                    }
                }
            }
            .onAppear {
                loadSavedIncomes()
            }
            .refreshable {
                loadSavedIncomes()
            }
        }
    }
    
    private func loadSavedIncomes() {
        // For now, using UserDefaults to demonstrate
        // Later you can replace this with Core Data fetching
        if let data = UserDefaults.standard.data(forKey: "saved_incomes"),
           let incomes = try? JSONDecoder().decode([SavedIncome].self, from: data) {
            savedIncomes = incomes.sorted { $0.date > $1.date }
        }
    }
    
    private func addSampleIncome() {
        let sampleIncome = SavedIncome(
            id: UUID(),
            amount: 50000.0,
            category: "Salary",
            description: "Monthly salary",
            date: Date(),
            isRecurring: true,
            frequency: "Monthly"
        )
        
        savedIncomes.insert(sampleIncome, at: 0)
        saveIncomes()
    }
    
    private func deleteIncome(offsets: IndexSet) {
        savedIncomes.remove(atOffsets: offsets)
        saveIncomes()
    }
    
    private func saveIncomes() {
        if let data = try? JSONEncoder().encode(savedIncomes) {
            UserDefaults.standard.set(data, forKey: "saved_incomes")
        }
    }
}

struct IncomeRow: View {
    let income: SavedIncome
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 45, height: 45)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(categoryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(income.category)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("Rs. \(income.amount, specifier: "%.2f")")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                }
                
                if !income.description.isEmpty {
                    Text(income.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(income.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if income.isRecurring {
                        Text("•")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                        
                        Text("Recurring \(income.frequency)")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var categoryIcon: String {
        switch income.category {
        case "Salary": return "dollarsign.circle.fill"
        case "Freelance": return "briefcase.fill"
        case "Business": return "building.2.fill"
        case "Investment": return "chart.line.uptrend.xyaxis"
        case "Rental": return "house.fill"
        default: return "ellipsis.circle.fill"
        }
    }
    
    private var categoryColor: Color {
        switch income.category {
        case "Salary": return .green
        case "Freelance": return .blue
        case "Business": return .orange
        case "Investment": return .purple
        case "Rental": return .brown
        default: return .gray
        }
    }
}

// MARK: - Data Model
struct SavedIncome: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let category: String
    let description: String
    let date: Date
    let isRecurring: Bool
    let frequency: String
}

#Preview {
    IncomeDisplayView()
}

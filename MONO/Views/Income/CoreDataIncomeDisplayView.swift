//
//  CoreDataIncomeDisplayView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import SwiftUI
import CoreData

struct CoreDataIncomeDisplayView: View {
    @StateObject private var coreDataStack = CoreDataStack.shared
    @State private var incomes: [IncomeEntity] = []
    
    var body: some View {
        NavigationView {
            List {
                if incomes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Income Records")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Your saved income entries will appear here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Refresh") {
                            loadIncomes()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 40)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(incomes, id: \.objectID) { income in
                        CoreDataIncomeRow(income: income)
                    }
                    .onDelete(perform: deleteIncome)
                }
            }
            .navigationTitle("Income Records")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if !incomes.isEmpty {
                        Button("Clear All") {
                            clearAllIncomes()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            loadIncomes()
        }
    }
    
    private func loadIncomes() {
        incomes = coreDataStack.fetchIncomes()
    }
    
    private func deleteIncome(at offsets: IndexSet) {
        for index in offsets {
            let income = incomes[index]
            do {
                try coreDataStack.deleteIncome(income)
                incomes.remove(at: index)
            } catch {
                print("Error deleting income: \(error)")
            }
        }
    }
    
    private func clearAllIncomes() {
        for income in incomes {
            do {
                try coreDataStack.deleteIncome(income)
            } catch {
                print("Error deleting income: \(error)")
            }
        }
        incomes.removeAll()
    }
}

struct CoreDataIncomeRow: View {
    let income: IncomeEntity
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: categoryIcon)
                .font(.title2)
                .foregroundColor(categoryColor)
                .frame(width: 40, height: 40)
                .background(categoryColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                // Category and Amount
                HStack {
                    Text(income.category?.name ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("Rs.\(income.amount, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                // Description (if available)
                if let description = income.descriptionText, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Date and Frequency
                HStack {
                    Text(income.date?.formatted(date: .abbreviated, time: .omitted) ?? "No date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if income.isRecurring {
                        Spacer()
                        
                        Text(income.recurrenceFrequency?.rawValue.capitalized ?? "Recurring")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var categoryIcon: String {
        switch income.category?.name ?? "" {
        case "Salary":
            return "briefcase.fill"
        case "Freelance":
            return "person.fill"
        case "Business":
            return "building.2.fill"
        case "Investment":
            return "chart.line.uptrend.xyaxis"
        case "Rental":
            return "house.fill"
        default:
            return "dollarsign.circle.fill"
        }
    }
    
    private var categoryColor: Color {
        switch income.category?.name ?? "" {
        case "Salary":
            return .blue
        case "Freelance":
            return .purple
        case "Business":
            return .orange
        case "Investment":
            return .green
        case "Rental":
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    CoreDataIncomeDisplayView()
}

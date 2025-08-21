//
//  IncomeListView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import SwiftUI
import CoreData

struct IncomeListView: View {
    @State private var incomes: [IncomeEntity] = []
    @State private var showingAddIncome = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(incomes, id: \.id) { income in
                    IncomeRowView(income: income)
                }
                .onDelete(perform: deleteIncomes)
            }
            .navigationTitle("Income")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddIncome = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddIncome) {
                IncomeCategoriesView()
            }
            .onAppear {
                loadIncomes()
            }
            .refreshable {
                loadIncomes()
            }
        }
    }
    
    private func loadIncomes() {
        if let currentUser = CoreDataStack.shared.fetchCurrentUser() {
            incomes = CoreDataStack.shared.fetchIncomes(for: currentUser)
        }
    }
    
    private func deleteIncomes(offsets: IndexSet) {
        for index in offsets {
            let income = incomes[index]
            CoreDataStack.shared.deleteIncome(income)
        }
        loadIncomes()
    }
}

struct IncomeRowView: View {
    let income: IncomeEntity
    
    var body: some View {
        HStack {
            // Category icon
            ZStack {
                Circle()
                    .fill(Color(hex: income.categoryColor ?? "#4CAF50").opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: income.categoryIcon ?? "dollarsign.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: income.categoryColor ?? "#4CAF50"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(income.categoryName ?? "Unknown")
                    .font(.system(size: 16, weight: .semibold))
                
                if let description = income.incomeDescription, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(income.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown Date")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if income.isRecurring {
                        Text("• Recurring")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            Text("$\(income.amount, specifier: "%.2f")")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    IncomeListView()
}

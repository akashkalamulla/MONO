//
//  DependentExpensesPlaceholderView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-24.
//

import SwiftUI
import CoreData

struct DependentExpensesPlaceholderView: View {
    let dependentName: String
    let dependentID: UUID
    @StateObject private var coreDataStack = CoreDataStack.shared
    @State private var expenses: [NSManagedObject] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Loading expenses...")
                        .padding(.top, 8)
                        .foregroundColor(.gray)
                }
            } else if expenses.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.monoSecondary)
                    
                    Text("No Expenses Found")
                        .font(.headline)
                    
                    Text("There are no expenses recorded for \(dependentName) yet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    NavigationLink(destination: ExpenseEntryForDependent(dependentID: dependentID, dependentName: dependentName)) {
                        Text("Add Expense")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.monoPrimary)
                            .cornerRadius(25)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)
                }
                .padding()
            } else {
                List {
                    Section(header: Text("Expenses")
                        .foregroundColor(.monoHeaderText)) {
                        ForEach(0..<expenses.count, id: \.self) { index in
                            ExpenseRowView(expense: expenses[index])
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("\(dependentName)'s Expenses")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadExpenses()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(dependentName)'s Expenses")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: {}) {
                    Text("Details")
                        .foregroundColor(.monoPrimary)
                }
            }
        }
    }
    
    private func loadExpenses() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.expenses = coreDataStack.fetchExpenses(for: dependentID)
            self.isLoading = false
        }
    }
}

struct ExpenseRowView: View {
    let expense: NSManagedObject
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.value(forKey: "category") as? String ?? "Uncategorized")
                    .font(.headline)
                    .foregroundColor(.black)
                
                if let description = expense.value(forKey: "expenseDescription") as? String, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.monoSecondary.opacity(0.8))
                }
                
                if let date = expense.value(forKey: "date") as? Date {
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundColor(.monoSecondary.opacity(0.6))
                }
            }
            
            Spacer()
            
            if let amount = expense.value(forKey: "amount") as? Double {
                Text("Rs. \(String(format: "%.2f", amount))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.monoPrimary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ExpenseEntryForDependent: View {
    let dependentID: UUID
    let dependentName: String
    
    var body: some View {
        SimpleExpenseEntry(
            isForDependent: true,
            selectedDependentId: dependentID,
            dependentManager: DependentManager()
        )
        .onAppear {

        }
        .navigationTitle("Add Expense for \(dependentName)")
    }
}

struct DependentExpensesPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DependentExpensesPlaceholderView(dependentName: "Emma Smith", dependentID: UUID())
        }
    }
}

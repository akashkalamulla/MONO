//
//  DependentExpensesView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-24.
//

import SwiftUI

struct DependentExpensesView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var coreDataStack = CoreDataStack.shared
    let dependent: Dependent
    @State private var expenses: [ExpenseModel] = []
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Loading expenses...")
                        .padding(.top, 8)
                        .foregroundColor(.gray)
                }
            } else if expenses.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    Text("No Expenses Found")
                        .font(.headline)
                    
                    Text("There are no expenses recorded for \(dependent.fullName) yet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        // Navigate to expense entry form with this dependent pre-selected
                        // This will be implemented when the navigation is set up
                    }) {
                        Text("Add Expense")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(25)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)
                }
                .padding()
            } else {
                List {
                    Section(header: Text("Expenses")) {
                        ForEach(expenses) { expense in
                            ExpenseRow(expense: expense)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("\(dependent.firstName)'s Expenses")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadExpenses()
        }
    }
    
    private func loadExpenses() {
        // TODO: Replace this with actual Core Data fetch once implementation is complete
        // This would fetch expenses where the dependentID matches the current dependent's ID
        
        // Simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Sample data - replace with actual data fetch
            self.expenses = []
            self.isLoading = false
        }
    }
}

struct ExpenseRow: View {
    let expense: ExpenseModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category)
                    .font(.headline)
                
                if let description = expense.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text(formatDate(expense.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("Rs. \(String(format: "%.2f", expense.amount))")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Preview isn't working due to model references - will be fixed when actual implementation is complete
struct DependentExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Preview not available")
    }
}

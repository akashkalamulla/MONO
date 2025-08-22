  //
//  ExpenseListView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import SwiftUI

struct ExpenseListView: View {
    @StateObject private var coreDataStack = CoreDataStack.shared
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with total expenses
                VStack(spacing: 8) {
                    Text("Total Expenses")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Rs. 0.00")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Expenses List
                List {
                    Text("No expenses yet")
                        .foregroundColor(.gray)
                        .italic()
                }
                .listStyle(PlainListStyle())
                
                Spacer()
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExpense = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                NavigationView {
                    SimpleExpenseEntry()
                        .navigationTitle("Add Expense")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    showingAddExpense = false
                                }
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    ExpenseListView()
}

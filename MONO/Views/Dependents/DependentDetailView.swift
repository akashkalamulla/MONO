//
//  DependentDetailView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import Foundation
import SwiftUI

struct DependentDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let dependent: Dependent
    @ObservedObject var dependentManager: DependentManager
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(dependent.isActive ? Color(red: 0.2, green: 0.6, blue: 0.6).opacity(0.2) : Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                        
                        Text(dependent.initials)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(dependent.isActive ? Color(red: 0.15, green: 0.45, blue: 0.45) : .gray)
                    }
                    
                    VStack(spacing: 4) {
                        Text(dependent.fullName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.monoPrimary)
                        
                        Text(dependent.relationship)
                            .font(.system(size: 16))
                            .foregroundColor(.monoSecondary)
                        
                        if !dependent.isActive {
                            Text("Inactive")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.top)
                
                VStack(spacing: 16) {
                    InfoCard(title: "Personal Information") {
                        VStack(spacing: 12) {
                            InfoRow(label: "Age", value: "\(dependent.age) years old")
                            InfoRow(label: "Date of Birth", value: formatDate(dependent.dateOfBirth))
                            InfoRow(label: "Added on", value: formatDate(dependent.dateAdded))
                        }
                    }
                    
                    if !dependent.phoneNumber.isEmpty || !dependent.email.isEmpty {
                        InfoCard(title: "Contact Information") {
                            VStack(spacing: 12) {
                                if !dependent.phoneNumber.isEmpty {
                                    InfoRow(label: "Phone", value: dependent.phoneNumber)
                                }
                                if !dependent.email.isEmpty {
                                    InfoRow(label: "Email", value: dependent.email)
                                }
                            }
                        }
                    }
                    
                    InfoCard(title: "Expense Summary") {
                        VStack(spacing: 12) {
                            InfoRow(label: "Total Expenses", value: fetchTotalExpensesForDependent())
                            InfoRow(label: "This Month", value: fetchMonthlyExpensesForDependent())
                            InfoRow(label: "Last Expense", value: fetchLastExpenseDate())
                            
                            NavigationLink(destination: DependentExpensesPlaceholderView(dependentName: dependent.fullName, dependentID: dependent.id)) {
                                Text("View All Expenses")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6))
                                    .padding(.top, 8)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button(action: { showingEditView = true }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Details")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.2, green: 0.6, blue: 0.6))
                        .cornerRadius(25)
                    }
                    
                    Button(action: toggleActiveStatus) {
                        HStack {
                            Image(systemName: dependent.isActive ? "pause.circle" : "play.circle")
                            Text(dependent.isActive ? "Deactivate" : "Activate")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(red: 0.2, green: 0.6, blue: 0.6), lineWidth: 1)
                        )
                    }
                    
                    Button(action: { showingDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Dependent")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.red, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
        )
        .sheet(isPresented: $showingEditView) {
            if let editView = try? EditDependentView(dependent: dependent, dependentManager: dependentManager) {
                editView
            } else {
                Text("Edit functionality coming soon")
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Dependent"),
                message: Text("Are you sure you want to delete \(dependent.fullName)? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteDependent()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func toggleActiveStatus() {
        _ = dependentManager.toggleDependentStatus(dependent)
    }
    
    private func deleteDependent() {
        _ = dependentManager.deleteDependent(dependent)
        presentationMode.wrappedValue.dismiss()
    }
    

    @StateObject private var coreDataStack = CoreDataStack.shared
    
    private func fetchTotalExpensesForDependent() -> String {
        let expenses = coreDataStack.fetchExpenses(for: dependent.id)
        let total = expenses.reduce(0.0) { total, expense in
            if let amount = expense.value(forKey: "amount") as? Double {
                return total + amount
            }
            return total
        }
        return "Rs. \(String(format: "%.2f", total))"
    }
    
    private func fetchMonthlyExpensesForDependent() -> String {
 
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return "Rs. 0.00"
        }
        
     
        let expenses = coreDataStack.fetchExpenses(for: dependent.id)
        let monthlyExpenses = expenses.filter { expense in
            if let date = expense.value(forKey: "date") as? Date {
                return date >= startOfMonth && date <= endOfMonth
            }
            return false
        }
        
        let total = monthlyExpenses.reduce(0.0) { total, expense in
            if let amount = expense.value(forKey: "amount") as? Double {
                return total + amount
            }
            return total
        }
        return "Rs. \(String(format: "%.2f", total))"
    }
    
    private func fetchLastExpenseDate() -> String {
        let expenses = coreDataStack.fetchExpenses(for: dependent.id)
        if let lastExpense = expenses.first {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            if let date = lastExpense.value(forKey: "date") as? Date {
                return formatter.string(from: date)
            }
        }
        return "No expenses yet"
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6))
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6)) // monoPrimary color
        }
    }
}

#Preview {
    let sampleDependent = Dependent(
        firstName: "Emma",
        lastName: "Smith",
        relationship: "Child",
        dateOfBirth: Calendar.current.date(byAdding: .year, value: -8, to: Date()) ?? Date(),
        phoneNumber: "555-0123",
        email: "emma@example.com",
        userId: UUID()
    )
    
    DependentDetailView(
        dependent: sampleDependent,
        dependentManager: DependentManager()
    )
}

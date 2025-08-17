//
//  AddExpenseView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-17.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: ExpenseType = .expenses
    @State private var selectedCategory: ExpenseCategory?
    @State private var showingAddExpenseDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("Add")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Button("Cancel") {
                        dismiss()
                    }
                    .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Type Selection Buttons
                HStack(spacing: 12) {
                    TypeSelectionButton(
                        title: "Expenses",
                        isSelected: selectedType == .expenses,
                        selectedColor: Color(hex: "#438883")
                    ) {
                        selectedType = .expenses
                    }
                    
                    TypeSelectionButton(
                        title: "Income",
                        isSelected: selectedType == .income,
                        borderColor: Color(hex: "#438883")
                    ) {
                        selectedType = .income
                    }
                    
                    TypeSelectionButton(
                        title: "Transfer",
                        isSelected: selectedType == .transfer,
                        borderColor: Color(hex: "#438883")
                    ) {
                        selectedType = .transfer
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                // Categories Grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 24) {
                        ForEach(categoriesForType(selectedType), id: \.id) { category in
                            CategoryButton(category: category) {
                                selectedCategory = category
                                showingAddExpenseDetail = true
                            }
                        }
                        
                        // Add Expenses Button
                        AddCategoryButton {
                            // Handle add new category
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                }
                
                Spacer()
            }
            .background(Color(UIColor.systemGray6))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddExpenseDetail) {
            if let category = selectedCategory {
                AddExpenseDetailView(
                    type: selectedType,
                    category: category
                )
            }
        }
    }
    
    private func categoriesForType(_ type: ExpenseType) -> [ExpenseCategory] {
        switch type {
        case .expenses:
            return ExpenseCategory.expenseCategories
        case .income:
            return ExpenseCategory.incomeCategories
        case .transfer:
            return ExpenseCategory.transferCategories
        }
    }
}

// MARK: - Type Selection Button
struct TypeSelectionButton: View {
    let title: String
    let isSelected: Bool
    let selectedColor: Color
    let borderColor: Color
    let action: () -> Void
    
    init(
        title: String,
        isSelected: Bool,
        selectedColor: Color = .clear,
        borderColor: Color = .clear,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.selectedColor = selectedColor
        self.borderColor = borderColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : borderColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? selectedColor : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.clear : borderColor, lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: ExpenseCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon Container
                RoundedRectangle(cornerRadius: 16)
                    .fill(category.color.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: category.icon)
                            .font(.system(size: 24))
                            .foregroundColor(category.color)
                    )
                
                // Category Name
                Text(category.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Add Category Button
struct AddCategoryButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon Container
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#438883"))
                    )
                
                // Category Name
                Text("Add Expenses")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#438883"))
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Models
enum ExpenseType: String, CaseIterable {
    case expenses = "Expenses"
    case income = "Income"
    case transfer = "Transfer"
}

struct ExpenseCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    
    static let expenseCategories = [
        ExpenseCategory(name: "Shopping", icon: "bag.fill", color: .blue),
        ExpenseCategory(name: "Food", icon: "fork.knife", color: .cyan),
        ExpenseCategory(name: "Phone", icon: "phone.fill", color: .blue),
        ExpenseCategory(name: "Water Bill", icon: "drop.fill", color: .cyan),
        ExpenseCategory(name: "Education", icon: "graduationcap.fill", color: .blue),
        ExpenseCategory(name: "Party", icon: "party.popper.fill", color: .red),
        ExpenseCategory(name: "Current Bill", icon: "bolt.fill", color: .yellow),
        ExpenseCategory(name: "Internet Bill", icon: "wifi", color: .blue),
        ExpenseCategory(name: "Health", icon: "cross.fill", color: .cyan),
        ExpenseCategory(name: "Groceries", icon: "cart.fill", color: .cyan),
        ExpenseCategory(name: "Clothing", icon: "tshirt.fill", color: .orange),
        ExpenseCategory(name: "Gifts", icon: "gift.fill", color: .brown)
    ]
    
    static let incomeCategories = [
        ExpenseCategory(name: "Salary", icon: "banknote.fill", color: .green),
        ExpenseCategory(name: "Freelance", icon: "laptopcomputer", color: .blue),
        ExpenseCategory(name: "Investment", icon: "chart.line.uptrend.xyaxis", color: .green),
        ExpenseCategory(name: "Business", icon: "briefcase.fill", color: .purple),
        ExpenseCategory(name: "Bonus", icon: "star.fill", color: .yellow),
        ExpenseCategory(name: "Gift Money", icon: "gift.fill", color: .pink),
        ExpenseCategory(name: "Rental", icon: "house.fill", color: .brown),
        ExpenseCategory(name: "Other", icon: "plus.circle.fill", color: .gray)
    ]
    
    static let transferCategories = [
        ExpenseCategory(name: "Bank Transfer", icon: "building.columns.fill", color: .blue),
        ExpenseCategory(name: "Cash Deposit", icon: "banknote.fill", color: .green),
        ExpenseCategory(name: "Card Payment", icon: "creditcard.fill", color: .purple),
        ExpenseCategory(name: "Mobile Payment", icon: "phone.and.waveform.fill", color: .orange),
        ExpenseCategory(name: "Online Transfer", icon: "wifi", color: .cyan),
        ExpenseCategory(name: "ATM", icon: "rectangle.portrait.and.arrow.forward", color: .gray),
        ExpenseCategory(name: "Wallet", icon: "wallet.pass.fill", color: .brown),
        ExpenseCategory(name: "Other", icon: "arrow.left.arrow.right.circle.fill", color: .indigo)
    ]
}

// MARK: - Add Expense Detail View (Placeholder)
struct AddExpenseDetailView: View {
    let type: ExpenseType
    let category: ExpenseCategory
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add \(type.rawValue)")
                    .font(.title2)
                    .padding()
                
                Text("Category: \(category.name)")
                    .font(.headline)
                    .padding()
                
                Text("Expense detail form will be implemented here")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("Add \(type.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddExpenseView()
}

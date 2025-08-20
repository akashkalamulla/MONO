//
//  IncomeViews.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import SwiftUI

// MARK: - Income Types
struct TempIncomeCategory: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: String
}

enum TempRecurrenceFrequency: String, CaseIterable {
    case weekly = "weekly"
    case biweekly = "biweekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .biweekly: return "Bi-weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}

// MARK: - Categories View
struct IncomeCategoriesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCategory: TempIncomeCategory?
    @State private var showingIncomeDetails = false
    
    let categories: [TempIncomeCategory] = [
        TempIncomeCategory(id: "salary", name: "Salary", icon: "dollarsign.circle.fill", color: "#4CAF50"),
        TempIncomeCategory(id: "freelance", name: "Freelance", icon: "briefcase.fill", color: "#2196F3"),
        TempIncomeCategory(id: "business", name: "Business", icon: "building.2.fill", color: "#FF9800"),
        TempIncomeCategory(id: "investment", name: "Investment", icon: "chart.line.uptrend.xyaxis", color: "#9C27B0"),
        TempIncomeCategory(id: "rental", name: "Rental", icon: "house.fill", color: "#795548"),
        TempIncomeCategory(id: "other", name: "Other", icon: "ellipsis.circle.fill", color: "#607D8B")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(categories) { category in
                        IncomeCategoryCard(category: category) {
                            selectedCategory = category
                            showingIncomeDetails = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Add Income")
        }
        .sheet(isPresented: $showingIncomeDetails) {
            if let category = selectedCategory {
                IncomeDetailsView(category: category)
            }
        }
    }
}

struct IncomeCategoryCard: View {
    let category: TempIncomeCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color.blue)
                }
                
                Text(category.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Details View
struct IncomeDetailsView: View {
    let category: TempIncomeCategory
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedDate = Date()
    @State private var isRecurring = false
    @State private var selectedFrequency: TempRecurrenceFrequency = .monthly
    @State private var showingSuccessAlert = false
    
    // Define colors to avoid extension issues
    private let primaryColor = Color(red: 0.2, green: 0.6, blue: 0.6)
    private let lightGrayColor = Color(red: 0.6, green: 0.6, blue: 0.6)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(primaryColor.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: category.icon)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(primaryColor)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Add \(category.name)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(primaryColor)
                            
                            Text("Enter the details of your \(category.name.lowercased())")
                                .font(.system(size: 14))
                                .foregroundColor(lightGrayColor)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Form Section
                    VStack(spacing: 20) {
                        // Amount Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(primaryColor)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(primaryColor)
                                
                                TextField("0.00", text: $amount)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(primaryColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // Description Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (Optional)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(primaryColor)
                            
                            TextField("Add a note...", text: $description, axis: .vertical)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .lineLimit(3...6)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // Date Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(primaryColor)
                            
                            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // Recurring Income Toggle
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Recurring Income")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(primaryColor)
                                    
                                    Text("This income repeats regularly")
                                        .font(.system(size: 12))
                                        .foregroundColor(lightGrayColor)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $isRecurring)
                                    .toggleStyle(SwitchToggleStyle(tint: primaryColor))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            
                            // Frequency Selection (only if recurring)
                            if isRecurring {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Frequency")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(primaryColor)
                                    
                                    Picker("Frequency", selection: $selectedFrequency) {
                                        ForEach(TempRecurrenceFrequency.allCases, id: \.self) { frequency in
                                            Text(frequency.displayName).tag(frequency)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            saveIncome()
                        }) {
                            Text("Add Income")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(primaryColor)
                                .cornerRadius(28)
                                .shadow(color: primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(amount.isEmpty)
                        .opacity(amount.isEmpty ? 0.6 : 1.0)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(primaryColor)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        }
        .alert("Income Added Successfully!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your \(category.name.lowercased()) of $\(amount) has been added.")
        }
        .animation(.easeInOut(duration: 0.3), value: isRecurring)
    }
    
    private func saveIncome() {
        // For now, just show success alert
        // Later you can integrate with CoreDataStack when it's available
        showingSuccessAlert = true
    }
}

// MARK: - Previews
#Preview("Categories") {
    IncomeCategoriesView()
}

#Preview("Details") {
    let sampleCategory = TempIncomeCategory(
        id: "salary",
        name: "Salary",
        icon: "dollarsign.circle.fill",
        color: "#4CAF50"
    )
    
    IncomeDetailsView(category: sampleCategory)
}

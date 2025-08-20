
//
//  IncomeDetailsView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import SwiftUI

// MARK: - Income Category Model (inline for compatibility)
struct IncomeCategory: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
}

// MARK: - Color Extensions (inline)
extension Color {
    static let monoPrimary = Color(red: 0.2, green: 0.6, blue: 0.6) // Teal
    static let monoTextLight = Color(red: 0.6, green: 0.6, blue: 0.6) // Light gray
}

struct IncomeDetailsView: View {
    let category: IncomeCategory
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedDate = Date()
    @State private var isRecurring = false
    @State private var selectedFrequency: RecurrenceFrequency = .monthly
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        // Category Icon
                        ZStack {
                            Circle()
                                .fill(category.color.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: category.icon)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(category.color)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Add \(category.name)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.monoPrimary)
                            
                            Text("Enter the details of your \(category.name.lowercased())")
                                .font(.system(size: 14))
                                .foregroundColor(.monoTextLight)
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
                                .foregroundColor(.monoPrimary)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.monoPrimary)
                                
                                TextField("0.00", text: $amount)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.monoPrimary)
                                    .keyboardType(.decimalPad)
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
                                .foregroundColor(.monoPrimary)
                            
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
                                .foregroundColor(.monoPrimary)
                            
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
                                        .foregroundColor(.monoPrimary)
                                    
                                    Text("This income repeats regularly")
                                        .font(.system(size: 12))
                                        .foregroundColor(.monoTextLight)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $isRecurring)
                                    .toggleStyle(SwitchToggleStyle(tint: .monoPrimary))
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
                                        .foregroundColor(.monoPrimary)
                                    
                                    Picker("Frequency", selection: $selectedFrequency) {
                                        ForEach(RecurrenceFrequency.allCases, id: \.self) { frequency in
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
                        // Save Button
                        Button(action: {
                            saveIncome()
                        }) {
                            Text("Add Income")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(.monoPrimary)
                                .cornerRadius(28)
                                .shadow(color: .monoPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(amount.isEmpty)
                        .opacity(amount.isEmpty ? 0.6 : 1.0)
                        
                        // Cancel Button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.monoPrimary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .overlay(
                // Custom navigation bar
                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.monoPrimary)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        
                        Spacer()
                        
                        Text(category.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.monoPrimary)
                        
                        Spacer()
                        
                        // Placeholder for balance
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                },
                alignment: .top
            )
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
        // TODO: Implement actual saving logic
        // For now, just show success alert
        showingSuccessAlert = true
    }
}

// MARK: - Recurrence Frequency Enum
enum RecurrenceFrequency: String, CaseIterable {
    case weekly = "weekly"
    case biweekly = "biweekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .weekly:
            return "Weekly"
        case .biweekly:
            return "Bi-weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
}

#Preview {
    let sampleCategory = IncomeCategory(
        id: "salary",
        name: "Salary",
        icon: "dollarsign.circle.fill",
        color: .green
    )
    
    IncomeDetailsView(category: sampleCategory)
}

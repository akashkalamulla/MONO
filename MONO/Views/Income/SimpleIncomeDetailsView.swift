//
//  SimpleIncomeDetailsView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import SwiftUI

struct SimpleIncomeCategory: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: String
}

enum SimpleRecurrenceFrequency: String, CaseIterable {
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

struct SimpleIncomeDetailsView: View {
    let category: SimpleIncomeCategory
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedDate = Date()
    @State private var isRecurring = false
    @State private var selectedFrequency: SimpleRecurrenceFrequency = .monthly
    @State private var showingSuccessAlert = false
    
    // Simple colors to avoid extension issues
    private let primaryColor = Color(red: 0.2, green: 0.6, blue: 0.6)
    private let lightGrayColor = Color(red: 0.6, green: 0.6, blue: 0.6)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HeaderView()
                    
                    // Form
                    FormSectionView()
                    
                    // Buttons
                    ButtonSectionView()
                }
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        }
        .alert("Income Added Successfully!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    @ViewBuilder
    private func HeaderView() -> some View {
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
    }
    
    @ViewBuilder
    private func FormSectionView() -> some View {
        VStack(spacing: 20) {
            AmountField()
            DescriptionField()
            DateField()
            RecurringField()
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func AmountField() -> some View {
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
    }
    
    @ViewBuilder
    private func DescriptionField() -> some View {
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
    }
    
    @ViewBuilder
    private func DateField() -> some View {
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
    }
    
    @ViewBuilder
    private func RecurringField() -> some View {
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
            
            if isRecurring {
                FrequencyPicker()
            }
        }
    }
    
    @ViewBuilder
    private func FrequencyPicker() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Frequency")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(primaryColor)
            
            Picker("Frequency", selection: $selectedFrequency) {
                ForEach(SimpleRecurrenceFrequency.allCases, id: \.self) { frequency in
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
    
    @ViewBuilder
    private func ButtonSectionView() -> some View {
        VStack(spacing: 12) {
            Button(action: saveIncome) {
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
    
    private func saveIncome() {
        // For now, just show success alert
        // Later you can integrate with CoreDataStack when it's available
        showingSuccessAlert = true
    }
}

#Preview {
    let sampleCategory = SimpleIncomeCategory(
        id: "salary",
        name: "Salary",
        icon: "dollarsign.circle.fill",
        color: "#4CAF50"
    )
    
    SimpleIncomeDetailsView(category: sampleCategory)
}

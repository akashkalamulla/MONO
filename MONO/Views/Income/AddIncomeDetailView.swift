//
//  AddIncomeDetailView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import SwiftUI
import CoreData

struct AddIncomeDetailView: View {
    let category: IncomeCategory
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    // Form State
    @State private var incomeSource: String = ""
    @State private var amount: String = ""
    @State private var selectedDate = Date()
    @State private var incomeDescription: String = ""
    @State private var notes: String = ""
    @State private var isRecurring: Bool = false
    @State private var selectedFrequency: RecurringFrequency = .monthly
    
    // UI State
    @State private var showingDatePicker = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HeaderView()
                
                // Form Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Category Display
                        CategoryDisplaySection()
                        
                        // Source Field
                        SourceFieldSection()
                        
                        // Amount Field
                        AmountFieldSection()
                        
                        // Date Field
                        DateFieldSection()
                        
                        // Description Field
                        DescriptionFieldSection()
                        
                        // Recurring Section
                        RecurringSection()
                        
                        // Notes Field
                        NotesFieldSection()
                        
                        // Save Button
                        SaveButtonSection()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
                .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            }
            .navigationBarHidden(true)
        }
        .alert("Income", isPresented: $showingAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            setupDefaults()
        }
    }
    
    // MARK: - Header View
    @ViewBuilder
    private func HeaderView() -> some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.primary)
            
            Spacer()
            
            Text("Add Income")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button("Cancel") { }
                .opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color.white)
    }
    
    // MARK: - Category Display Section
    @ViewBuilder
    private func CategoryDisplaySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CATEGORY")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            HStack(spacing: 12) {
                // Category Icon
                Circle()
                    .fill(category.color.opacity(0.15))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: category.icon)
                            .font(.system(size: 20))
                            .foregroundColor(category.color)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(category.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Source Field Section
    @ViewBuilder
    private func SourceFieldSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INCOME SOURCE")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            TextField("Enter income source (e.g., Company Name, Client)", text: $incomeSource)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Amount Field Section
    @ViewBuilder
    private func AmountFieldSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AMOUNT")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            HStack {
                TextField("$ 0.00", text: $amount)
                    .font(.system(size: 16))
                    .keyboardType(.decimalPad)
                    .foregroundColor(.primary)
                
                if !amount.isEmpty {
                    Button("Clear") {
                        amount = ""
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Date Field Section
    @ViewBuilder
    private func DateFieldSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DATE RECEIVED")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            Button(action: {
                showingDatePicker = true
            }) {
                HStack {
                    Text(formatDate(selectedDate))
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate)
        }
    }
    
    // MARK: - Description Field Section
    @ViewBuilder
    private func DescriptionFieldSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DESCRIPTION (OPTIONAL)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            TextField("Brief description of this income", text: $incomeDescription)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Recurring Section
    @ViewBuilder
    private func RecurringSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("RECURRING INCOME")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                
                Spacer()
                
                Toggle("", isOn: $isRecurring)
                    .labelsHidden()
            }
            
            if isRecurring {
                Picker("Frequency", selection: $selectedFrequency) {
                    ForEach(RecurringFrequency.allCases, id: \.self) { frequency in
                        Text(frequency.rawValue).tag(frequency)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Notes Field Section
    @ViewBuilder
    private func NotesFieldSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NOTES (OPTIONAL)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            TextField("Add any additional notes", text: $notes, axis: .vertical)
                .font(.system(size: 16))
                .lineLimit(3...6)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Save Button Section
    @ViewBuilder
    private func SaveButtonSection() -> some View {
        Button(action: {
            saveIncome()
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                }
                Text("Save Income")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFormValid ? Color.green : Color.gray)
            .cornerRadius(12)
        }
        .disabled(!isFormValid || isLoading)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helper Methods
    private var isFormValid: Bool {
        !incomeSource.isEmpty && !amount.isEmpty && Double(amount.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)) != nil
    }
    
    private func setupDefaults() {
        // You can set default values based on category if needed
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    private func saveIncome() {
        guard isFormValid,
              let currentUser = authManager.currentUser,
              let amountDouble = Double(amount.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)) else {
            return
        }
        
        isLoading = true
        
        // Use CoreDataStack directly
        let coreDataStack = CoreDataStack.shared
        if let userEntity = coreDataStack.fetchUser(by: currentUser.email) {
            
            let success = coreDataStack.addIncome(
                source: incomeSource,
                category: category.name,
                categoryIcon: category.icon,
                categoryColor: category.color.description,
                amount: amountDouble,
                dateReceived: selectedDate,
                description: incomeDescription.isEmpty ? nil : incomeDescription,
                notes: notes.isEmpty ? nil : notes,
                isRecurring: isRecurring,
                recurringFrequency: isRecurring ? selectedFrequency.rawValue : nil,
                user: userEntity
            )
            
            isLoading = false
            
            if success {
                alertMessage = "Income saved successfully!"
                showingAlert = true
            } else {
                alertMessage = "Failed to save income. Please try again."
                showingAlert = true
            }
        } else {
            isLoading = false
            alertMessage = "Error: User not found. Please log in again."
            showingAlert = true
        }
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let sampleCategory = IncomeCategory(
        name: "Salary",
        icon: "banknote.fill",
        color: .green,
        description: "Regular monthly salary from employment"
    )
    
    return AddIncomeDetailView(category: sampleCategory)
        .environmentObject(AuthenticationManager())
}

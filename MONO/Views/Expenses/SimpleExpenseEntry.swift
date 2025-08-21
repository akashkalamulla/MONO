//
//  SimpleExpenseEntry.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import SwiftUI

struct SimpleExpenseEntry: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var coreDataStack = CoreDataStack.shared
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategory = "Food & Dining"
    @State private var selectedDate = Date()
    @State private var isRecurring = false
    @State private var selectedFrequency = "Monthly"
    @State private var isPaymentReminder = false
    @State private var reminderFrequency = "Monthly"
    @State private var reminderDate = Date()
    @State private var reminderDayOfMonth = 1
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let categories = ["Food & Dining", "Transportation", "Housing", "Utilities", "Shopping", "Healthcare", "Entertainment", "Education", "Other"]
    let frequencies = ["Daily", "Weekly", "Monthly", "Yearly"]
    let reminderFrequencies = ["Once", "Monthly", "Yearly"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Amount Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.headline)
                    
                    HStack {
                        Text("Rs.")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        TextField("0.00", text: $amount)
                            .font(.title2)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Category Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.headline)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Date Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(.headline)
                    
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Recurring Expense Toggle
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Recurring Expense")
                            .font(.headline)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isRecurring)
                            .labelsHidden()
                    }
                    
                    if isRecurring {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Frequency")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Picker("Frequency", selection: $selectedFrequency) {
                                ForEach(frequencies, id: \.self) { frequency in
                                    Text(frequency).tag(frequency)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .animation(.easeInOut(duration: 0.3), value: isRecurring)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Payment Reminder Toggle
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Payment Reminder")
                            .font(.headline)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isPaymentReminder)
                            .labelsHidden()
                    }
                    
                    if isPaymentReminder {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reminder Type")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Picker("Reminder Type", selection: $reminderFrequency) {
                                ForEach(reminderFrequencies, id: \.self) { frequency in
                                    Text(frequency).tag(frequency)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            if reminderFrequency == "Once" || reminderFrequency == "Yearly" {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Reminder Date")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    DatePicker("Reminder Date", selection: $reminderDate, displayedComponents: .date)
                                        .datePickerStyle(CompactDatePickerStyle())
                                }
                            }
                            
                            if reminderFrequency == "Monthly" {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Day of Month")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Picker("Day of Month", selection: $reminderDayOfMonth) {
                                        ForEach(1...31, id: \.self) { day in
                                            Text("\(day)").tag(day)
                                        }
                                    }
                                    .pickerStyle(WheelPickerStyle())
                                    .frame(height: 100)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .animation(.easeInOut(duration: 0.3), value: isPaymentReminder)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.headline)
                    
                    TextField("Enter description", text: $description)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Save Button
                Button(action: saveExpense) {
                    Text("Save Expense")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(amount.isEmpty ? Color.gray : Color.red)
                        .cornerRadius(12)
                }
                .disabled(amount.isEmpty)
                .padding(.top, 20)
            }
            .padding()
        }
        .alert("Expense Saved", isPresented: $showingAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveExpense() {
        // Validate amount
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        
        // TODO: Implement Core Data saving after ExpenseEntity is generated
        let message = "Expense of Rs.\(String(format: "%.2f", amountValue)) will be saved once Core Data is set up!"
        alertMessage = message
        showingAlert = true
    }
    
    private func convertStringToRecurringFrequency(_ frequency: String) -> ExpenseRecurrenceFrequency {
        switch frequency {
        case "Daily":
            return .daily
        case "Weekly":
            return .weekly
        case "Monthly":
            return .monthly
        case "Yearly":
            return .yearly
        default:
            return .monthly
        }
    }
    
    private func convertStringToReminderFrequency(_ frequency: String) -> PaymentReminderFrequency {
        switch frequency {
        case "Once":
            return .once
        case "Monthly":
            return .monthly
        case "Yearly":
            return .yearly
        default:
            return .monthly
        }
    }
}

#Preview {
    SimpleExpenseEntry()
}

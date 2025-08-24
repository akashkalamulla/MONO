//
//  SimpleIncomeEntry.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import SwiftUI

// Import Income model to access IncomeCategory
import CoreData

struct SimpleIncomeEntry: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategory = "Salary"
    @State private var selectedDate = Date()
    @State private var isRecurring = false
    @State private var selectedFrequency = "Monthly"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let categories = ["Salary", "Freelance", "Business", "Investment", "Rental", "Other"]
    let frequencies = ["Weekly", "Bi-weekly", "Monthly", "Yearly"]
    
    var body: some View {
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
                
                // Recurring Income Toggle
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Recurring Income")
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
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.headline)
                    
                    TextField("Enter description", text: $description)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Spacer()
                
                // Save Button
                Button(action: saveIncome) {
                    Text("Save Income")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(amount.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(amount.isEmpty)
            }
            .padding()
            .navigationTitle("Add Income")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Income Saved", isPresented: $showingAlert) {
                Button("OK") {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text(alertMessage)
            }
    }
    
    private func saveIncome() {
        // Validate amount
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        
        // Get current user
        guard let currentUser = CoreDataStack.shared.fetchCurrentUser() else {
            alertMessage = "No logged in user found"
            showingAlert = true
            return
        }
        
        // Convert category to IncomeCategory
        let selectedIncomeCategory = IncomeCategory(
            id: UUID().uuidString,
            name: selectedCategory,
            icon: "dollarsign.circle",  // Default icon
            color: "#007AFF"  // Default color
        )
        
        // Convert frequency string to RecurrenceFrequency string
        let recurrenceFrequencyString = isRecurring ? convertStringToFrequency(selectedFrequency) : nil
        
        // Save to Core Data
        let income = CoreDataStack.shared.createIncome(
            amount: amountValue,
            category: selectedIncomeCategory,
            description: description.isEmpty ? nil : description,
            date: selectedDate,
            isRecurring: isRecurring,
            recurrenceFrequency: recurrenceFrequencyString,
            user: currentUser
        )
        
        let recurringInfo = isRecurring ? " (\(selectedFrequency))" : ""
        alertMessage = "Income of Rs.\(String(format: "%.2f", amountValue)) has been saved\(recurringInfo)!"
        showingAlert = true
    }
    
    // Helper function to convert UI string to appropriate frequency value
    private func convertStringToFrequency(_ frequency: String) -> String {
        switch frequency {
        case "Weekly":
            return "weekly"
        case "Bi-weekly":
            return "biweekly"
        case "Monthly":
            return "monthly"
        case "Yearly":
            return "yearly"
        default:
            return "monthly"
        }
    }
    
    struct SimpleIncomeEntry_Previews: PreviewProvider {
        static var previews: some View {
            SimpleIncomeEntry()
        }
    }
}

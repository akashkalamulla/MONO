//
//  SimpleIncomeEntry.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import SwiftUI

struct SimpleIncomeEntry: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var coreDataStack = CoreDataStack.shared
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
        guard let currentUser = coreDataStack.fetchCurrentUser() else {
            alertMessage = "Error: No user logged in"
            showingAlert = true
            return
        }
        
        // Find the selected category
        let incomeCategory = IncomeCategory.defaultCategories.first { $0.name == selectedCategory } ?? IncomeCategory.defaultCategories[0]
        
        // Convert frequency string to enum
        let frequency: RecurrenceFrequency? = isRecurring ? convertStringToFrequency(selectedFrequency) : nil
        
        // Save to Core Data
        do {
            let _ = coreDataStack.createIncome(
                amount: amountValue,
                category: incomeCategory,
                description: description.isEmpty ? nil : description,
                date: selectedDate,
                isRecurring: isRecurring,
                recurrenceFrequency: frequency,
                user: currentUser
            )
            
            let recurringInfo = isRecurring ? " (\(selectedFrequency))" : ""
            alertMessage = "Income of Rs.\(String(format: "%.2f", amountValue)) saved successfully\(recurringInfo)!"
            showingAlert = true
            
        } catch {
            alertMessage = "Error saving income: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func convertStringToFrequency(_ frequency: String) -> RecurrenceFrequency {
        switch frequency {
        case "Weekly":
            return .weekly
        case "Bi-weekly":
            return .biweekly
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
    SimpleIncomeEntry()
}

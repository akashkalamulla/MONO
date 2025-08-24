//
//  SimpleExpenseEntry.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import SwiftUI
import CoreData

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
    @State private var isForDependent: Bool
    @State private var selectedDependentId: UUID?
    
    // Dependency injection for the dependent manager
    var dependentManager = DependentManager()
    
    // Initialize with default parameters
    init(isForDependent: Bool = false, selectedDependentId: UUID? = nil, dependentManager: DependentManager = DependentManager()) {
        _isForDependent = State(initialValue: isForDependent)
        _selectedDependentId = State(initialValue: selectedDependentId)
        self.dependentManager = dependentManager
    }
    
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
                
                // Associate with Dependent Toggle
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Associate with Dependent")
                            .font(.headline)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isForDependent)
                            .labelsHidden()
                    }
                    
                    if isForDependent && !dependentManager.dependents.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Choose Dependent")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Picker("Select Dependent", selection: $selectedDependentId) {
                                Text("None").tag(nil as UUID?)
                                ForEach(dependentManager.dependents) { dependent in
                                    Text(dependent.fullName).tag(dependent.id as UUID?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .animation(.easeInOut(duration: 0.3), value: isForDependent)
                    } else if isForDependent && dependentManager.dependents.isEmpty {
                        Text("No dependents available. Please add dependents first.")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.vertical, 8)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: isForDependent)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
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
        .navigationTitle("Add Expense")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
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
        
        guard let currentUser = coreDataStack.fetchCurrentUser() else {
            alertMessage = "Unable to find current user"
            showingAlert = true
            return
        }
        
        // Find the selected category
        let categoryObj = ExpenseCategory.defaultCategories.first { $0.name == selectedCategory } ?? 
                         ExpenseCategory.defaultCategories.last! // Use "Other" as fallback
        
        // Get frequency if recurring
        let recurrenceFreq: String? = isRecurring ? selectedFrequency.lowercased() : nil
        
        // Get reminder settings
        let reminderDay: Int32? = reminderFrequency == "Monthly" ? Int32(reminderDayOfMonth) : nil
        let reminderDate = (reminderFrequency == "Once" || reminderFrequency == "Yearly") ? self.reminderDate : nil
        
        // Create a new expense entity directly
        let context = coreDataStack.context
        let expense = NSEntityDescription.insertNewObject(forEntityName: "ExpenseEntity", into: context)
        
        // Set basic properties
        expense.setValue(UUID(), forKey: "id")
        expense.setValue(amountValue, forKey: "amount")
        expense.setValue(categoryObj.name, forKey: "category")
        expense.setValue(description.isEmpty ? nil : description, forKey: "expenseDescription")
        expense.setValue(selectedDate, forKey: "date")
        expense.setValue(isRecurring, forKey: "isRecurring")
        expense.setValue(recurrenceFreq, forKey: "recurringFrequency")
        expense.setValue(isPaymentReminder, forKey: "isPaymentReminder")
        expense.setValue(reminderDate, forKey: "reminderDate")
        expense.setValue(reminderDay != nil ? Int16(reminderDay!) : nil, forKey: "reminderDayOfMonth")
        expense.setValue(isPaymentReminder ? reminderFrequency : nil, forKey: "reminderFrequency")
        expense.setValue(isPaymentReminder, forKey: "isReminderActive")
        expense.setValue(nil, forKey: "lastReminderSent")
        expense.setValue(currentUser.id, forKey: "userID")
        expense.setValue(Date(), forKey: "createdAt")
        expense.setValue(Date(), forKey: "updatedAt")
        expense.setValue(currentUser, forKey: "user")
        
        // Set dependent ID if applicable
        if isForDependent && selectedDependentId != nil {
            expense.setValue(selectedDependentId, forKey: "dependentID")
            
            // Try to set the dependent relationship if possible
            do {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DependentEntity")
                fetchRequest.predicate = NSPredicate(format: "id == %@", selectedDependentId! as CVarArg)
                let results = try context.fetch(fetchRequest)
                if let dependentEntity = results.first {
                    expense.setValue(dependentEntity, forKey: "dependent")
                }
            } catch {
                print("Error setting dependent relationship: \(error)")
            }
        }
        
        // Save changes
        do {
            try context.save()
            
            // Create success message
            var message = "Expense of Rs.\(String(format: "%.2f", amountValue)) saved"
            
            if isForDependent && selectedDependentId != nil {
                if let dependent = dependentManager.dependents.first(where: { $0.id == selectedDependentId }) {
                    message += " and associated with \(dependent.fullName)"
                }
            }
            
            alertMessage = message
            showingAlert = true
            
        } catch {
            alertMessage = "Error saving expense: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func convertStringToRecurringFrequency(_ frequency: String) -> String {
        switch frequency {
        case "Daily":
            return "daily"
        case "Weekly":
            return "weekly"
        case "Monthly":
            return "monthly"
        case "Yearly":
            return "yearly"
        default:
            return "monthly"
        }
    }
    
    private func convertStringToReminderFrequency(_ frequency: String) -> String {
        switch frequency {
        case "Once":
            return "once"
        case "Monthly":
            return "monthly"
        case "Yearly":
            return "yearly"
        default:
            return "monthly"
        }
    }
}

struct SimpleExpenseEntry_Previews: PreviewProvider {
    static var previews: some View {
        SimpleExpenseEntry()
    }
}

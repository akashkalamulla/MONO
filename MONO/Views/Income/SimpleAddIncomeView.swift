//
//  SimpleAddIncomeView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import SwiftUI
import CoreData

struct SimpleAddIncomeView: View {
    let userEmail: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var incomeSource = ""
    @State private var selectedCategory = "Salary"
    @State private var amount = ""
    @State private var selectedDate = Date()
    @State private var notes = ""
    @State private var isRecurring = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let categories = [
        "Salary", "Freelance", "Investment", "Part-time Work",
        "Business", "Rental", "Bonus", "Commission",
        "Dividend", "Interest", "Gift Money", "Other"
    ]
    
    let categoryIcons: [String: String] = [
        "Salary": "banknote.fill",
        "Freelance": "laptopcomputer",
        "Investment": "chart.line.uptrend.xyaxis",
        "Part-time Work": "clock.fill",
        "Business": "briefcase.fill",
        "Rental": "house.fill",
        "Bonus": "star.fill",
        "Commission": "percent",
        "Dividend": "dollarsign.circle.fill",
        "Interest": "plus.circle.fill",
        "Gift Money": "gift.fill",
        "Other": "ellipsis.circle.fill"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HeaderSection()
                    
                    // Form
                    VStack(spacing: 16) {
                        SourceField()
                        CategoryPicker()
                        AmountField()
                        DatePicker("Date Received", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                        NotesField()
                        RecurringToggle()
                        SaveButton()
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
#if os(iOS)
            .navigationBarHidden(true)
#endif
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
    }
    
    @ViewBuilder
    private func HeaderSection() -> some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.primary)
            
            Spacer()
            
            Text("Add Income")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button("Cancel") { }
                .opacity(0)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func SourceField() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Income Source")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            TextField("Enter source (e.g., Company Name)", text: $incomeSource)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    @ViewBuilder
    private func CategoryPicker() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    HStack {
                        Image(systemName: categoryIcons[category] ?? "circle")
                        Text(category)
                    }
                    .tag(category)
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    @ViewBuilder
    private func AmountField() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            TextField("$0.00", text: $amount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
#if os(iOS)
                .keyboardType(.decimalPad)
#endif
        }
    }
    
    @ViewBuilder
    private func NotesField() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes (Optional)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            TextField("Add notes", text: $notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
    }
    
    @ViewBuilder
    private func RecurringToggle() -> some View {
        HStack {
            Text("Recurring Income")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isRecurring)
                .labelsHidden()
        }
    }
    
    @ViewBuilder
    private func SaveButton() -> some View {
        Button(action: saveIncome) {
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
    }
    
    private var isFormValid: Bool {
        !incomeSource.isEmpty && 
        !amount.isEmpty && 
        Double(amount.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)) != nil
    }
    
    private func saveIncome() {
        guard !userEmail.isEmpty,
              let amountDouble = Double(amount.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)) else {
            alertMessage = "Please check your input and try again."
            showingAlert = true
            return
        }
        
        isLoading = true
        
        // Create Income Entity using Core Data context
        let incomeEntity = NSEntityDescription.entity(forEntityName: "IncomeEntity", in: viewContext)!
        let income = NSManagedObject(entity: incomeEntity, insertInto: viewContext)
        
        income.setValue(incomeSource, forKey: "source")
        income.setValue(selectedCategory, forKey: "category")
        income.setValue(categoryIcons[selectedCategory] ?? "circle", forKey: "categoryIcon")
        income.setValue("green", forKey: "categoryColor")
        income.setValue(amountDouble, forKey: "amount")
        income.setValue(selectedDate, forKey: "dateReceived")
        income.setValue(Date(), forKey: "dateCreated")
        income.setValue(notes.isEmpty ? nil : notes, forKey: "notes")
        income.setValue(isRecurring, forKey: "isRecurring")
        income.setValue(isRecurring ? "Monthly" : nil, forKey: "recurringFrequency")
        
        // Fetch and link user
        let userFetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "UserEntity")
        userFetch.predicate = NSPredicate(format: "email == %@", userEmail)
        
        do {
            let users = try viewContext.fetch(userFetch)
            if let userEntity = users.first {
                income.setValue(userEntity, forKey: "user")
            }
            
            try viewContext.save()
            
            isLoading = false
            alertMessage = "Income saved successfully!"
            showingAlert = true
            
        } catch {
            isLoading = false
            alertMessage = "Failed to save income. Please try again."
            showingAlert = true
        }
    }
}

#Preview {
    SimpleAddIncomeView()
}

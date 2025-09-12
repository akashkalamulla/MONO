//
//  SimpleIncomeEntry.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import SwiftUI
import CoreData
import Foundation

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
    @State private var showingDatePicker = false
    @State private var showingHelp = false
    
    let categories = ["Salary", "Freelance", "Business", "Investment", "Rental", "Other"]
    let frequencies = ["Weekly", "Bi-weekly", "Monthly", "Yearly"]
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Amount")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.monoPrimary)
                        .padding(.leading, 4)
                        
                    HStack(spacing: 0) {
                        Text("Rs.")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.monoSecondary)
                            .padding(.leading, 20)
                            .padding(.trailing, 6)
                        
                        TextField("0.00", text: $amount)
                            .font(.system(size: 24, weight: .medium))
                            .keyboardType(.decimalPad)
                            .foregroundColor(.black)
                            .padding(.vertical, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.monoBackground)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.monoSeparator, lineWidth: 1)
                    )
                    .shadow(color: .monoShadow.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Category")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.monoPrimary)
                        .padding(.leading, 4)
                    
                    Menu {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                if selectedCategory == category {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.monoSecondary)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.monoBackground)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.monoSeparator, lineWidth: 1)
                        )
                    }
                    .shadow(color: .monoShadow.opacity(0.1), radius: 3, x: 0, y: 2)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Date")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.leading, 4)
                    
                    VStack {
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(CompactDatePickerStyle())
                        .accentColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .frame(height: 56)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(UIColor.separator), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recurring Income")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.monoPrimary)
                        .padding(.leading, 4)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("Set as recurring income")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Toggle("", isOn: $isRecurring)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .monoPrimary))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        
                        if isRecurring {
                            Divider()
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Frequency")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.monoSecondary)
                                    .padding(.horizontal, 20)
                                
                                Picker("Frequency", selection: $selectedFrequency) {
                                    ForEach(frequencies, id: \.self) { frequency in
                                        Text(frequency).tag(frequency)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .animation(.easeInOut(duration: 0.3), value: isRecurring)
                        }
                    }
                    .background(Color.monoBackground)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.monoSeparator, lineWidth: 1)
                    )
                    .shadow(color: .monoShadow.opacity(0.1), radius: 3, x: 0, y: 2)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Description (Optional)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.monoPrimary)
                        .padding(.leading, 4)
                    
                    TextField("Enter description", text: $description)
                        .font(.system(size: 17))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.monoBackground)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.monoSeparator, lineWidth: 1)
                        )
                        .shadow(color: .monoShadow.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                
                Spacer(minLength: 30)
                
                Button(action: saveIncome) {
                    Text("Save Income")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(amount.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                        .cornerRadius(28)
                        .shadow(color: amount.isEmpty ? .clear : Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .disabled(amount.isEmpty)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .navigationTitle("Add Income")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.monoPrimary)
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button("Help") {
                    showingHelp = true
                }
                .foregroundColor(.monoPrimary)
            }
        }
        .sheet(isPresented: $showingHelp) {
            NavigationView {
                IncomeHelpView()
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
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        

        let recurringInfo = isRecurring ? " (\(selectedFrequency))" : ""
        alertMessage = "Income of Rs. \(String(format: "%.2f", amountValue)) has been saved\(recurringInfo)!"
        showingAlert = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
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

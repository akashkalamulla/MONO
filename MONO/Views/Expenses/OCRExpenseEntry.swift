//
//  OCRExpenseEntry.swift
//  MONO
//
//  Created by Akash01 on 2025-08-29.
//

import SwiftUI
import CoreData

struct OCRExpenseEntry: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var coreDataStack = CoreDataStack.shared
    @StateObject private var ocrService = OCRService.shared
    
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isProcessingOCR = false
    @State private var ocrResult: OCRResult?
    @State private var showingOCRResults = false
    
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
    @State private var isForDependent: Bool = false
    @State private var selectedDependentId: UUID?
    @State private var locationName: String = ""
    @State private var showingHelp = false
    
    var dependentManager = DependentManager()
    
    let categories = ["Food & Dining", "Transportation", "Housing", "Utilities", "Shopping", "Healthcare", "Entertainment", "Education", "Other"]
    let frequencies = ["Daily", "Weekly", "Monthly", "Yearly"]
    let reminderFrequencies = ["Once", "Monthly", "Yearly"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ocrSection
                    
                    if selectedImage != nil && !isProcessingOCR {
                        if let result = ocrResult {
                            processedDataSection(result)
                        }
                        
                        manualFormSection
                    }
                }
                .padding()
            }
            .navigationTitle("Scan Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button("Help") {
                            showingHelp = true
                        }
                        
                        if selectedImage != nil && !isProcessingOCR {
                            Button("Save") {
                                saveExpense()
                            }
                            .disabled(amount.isEmpty)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingHelp) {
            NavigationView {
                ExpenseHelpView()
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImageSelectionSheet(selectedImage: $selectedImage, showingSheet: $showingImagePicker)
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                processImageWithOCR(image)
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
    
    
    private var ocrSection: some View {
        VStack(spacing: 16) {
            if selectedImage == nil {
                VStack(spacing: 20) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 8) {
                        Text("Scan Your Receipt")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Take a photo of your bill and we'll automatically extract the amount and category")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .font(.title2)
                            Text("Add Receipt Photo")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(16)
                    }
                }
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 16) {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    if isProcessingOCR {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Processing receipt...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        selectedImage = nil
                        ocrResult = nil
                        amount = ""
                        description = ""
                        selectedCategory = "Food & Dining"
                    }) {
                        Text("Retake Photo")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func processedDataSection(_ result: OCRResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Processed Successfully")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("Confidence: \(Int(result.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                if let detectedAmount = result.amount {
                    HStack {
                        Text("Amount Detected:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Rs. \(String(format: "%.2f", detectedAmount))")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                
                if let suggestedCategory = result.suggestedCategory {
                    HStack {
                        Text("Suggested Category:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(suggestedCategory)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                
                if !result.text.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Extracted Text:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text(result.text.prefix(100) + (result.text.count > 100 ? "..." : ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var manualFormSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                    .font(.headline)
                
                HStack {
                    Text("Rs.")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    TextField("0.00", text: $amount)
                        .font(.title2)
                        .keyboardType(.decimalPad)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
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
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Description (Optional)")
                    .font(.headline)
                
                TextField("Enter description", text: $description)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Date")
                    .font(.headline)
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }
    
    
    private func processImageWithOCR(_ image: UIImage) {
        isProcessingOCR = true
        
    
        if ocrService.hasEnhancedOCR {
            print("Using enhanced OCR method")
            ocrService.enhancedOCRProcessing(image) { result in
                DispatchQueue.main.async {
                    self.handleOCRResult(result)
                }
            }
        } else {

            print("Using original OCR method")
            ocrService.multiPassOCRProcessing(image) { result in
                DispatchQueue.main.async {
                    self.handleOCRResult(result)
                }
            }
        }
    }
    
    private func handleOCRResult(_ result: Result<OCRResult, Error>) {
        isProcessingOCR = false
                
        switch result {
        case .success(let initialResult):

            let validatedResult = self.ocrService.validateOCRResult(initialResult)
            self.ocrResult = validatedResult
            
            if let detectedAmount = validatedResult.amount {
                self.amount = String(format: "%.2f", detectedAmount)
            }
            
            if let suggestedCategory = validatedResult.suggestedCategory {
                self.selectedCategory = suggestedCategory
            }
            

            if let merchantName = validatedResult.merchant, !merchantName.isEmpty {
                self.description = merchantName
            } else {
                let words = validatedResult.text.components(separatedBy: .whitespacesAndNewlines)
                let firstFewWords = Array(words.prefix(5)).joined(separator: " ")
                if !firstFewWords.isEmpty {
                    self.description = firstFewWords
                }
            }
            
            if let detectedDate = validatedResult.extractedDate {
                self.selectedDate = detectedDate
            }
            
        case .failure(let error):
            self.alertMessage = "Failed to process receipt: \(error.localizedDescription)"
            self.showingAlert = true
        }
    }
    
    private func saveExpense() {
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
        
        let context = coreDataStack.context
        let expense = ExpenseEntity(context: context)
        
        expense.id = UUID()
        expense.amount = amountValue
        expense.category = selectedCategory
        expense.expenseDescription = description.isEmpty ? nil : description
        expense.date = selectedDate
        expense.isRecurring = false
        expense.recurringFrequency = nil
        expense.isPaymentReminder = false
        expense.reminderDate = nil
        expense.reminderDayOfMonth = 0
        expense.reminderFrequency = nil
        expense.isReminderActive = false
        expense.lastReminderSent = nil
        expense.userID = currentUser.id ?? UUID()
        expense.createdAt = Date()
        expense.updatedAt = Date()
        expense.user = currentUser
        
        
        do {
            try context.save()
            alertMessage = "Expense of Rs. \(String(format: "%.2f", amountValue)) saved successfully from receipt scan!"
            showingAlert = true
        } catch {
            alertMessage = "Error saving expense: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

struct OCRExpenseEntry_Previews: PreviewProvider {
    static var previews: some View {
        OCRExpenseEntry()
    }
}

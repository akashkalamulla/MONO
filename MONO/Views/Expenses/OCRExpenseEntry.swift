//
//  OCRExpenseEntry.swift
//  MONO
//
//  Created by Akash01 on 2025-08-29.
//

import SwiftUI
import CoreData
import CoreLocation
import MapKit

struct OCRExpenseEntry: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var coreDataStack = CoreDataStack.shared
    @StateObject private var ocrService = OCRService.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isProcessingOCR = false
    @State private var ocrResult: OCRResult?
    @State private var showingOCRResults = false
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategory = "Food & Dining"
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
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
    
    // Location related states - standardized
    @State private var includeLocation = false
    @State private var selectedLocation: ReminderLocation?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612), // Colombo, Sri Lanka
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    var dependentManager = DependentManager()
    
    let categories = ["Food & Dining", "Transportation", "Housing", "Utilities", "Shopping", "Healthcare", "Entertainment", "Education", "Other"]
    let frequencies = ["Daily", "Weekly", "Monthly", "Yearly"]
    let reminderFrequencies = ["Once", "Monthly", "Yearly"]
    
    private var selectedDependentName: String {
        guard let selectedId = selectedDependentId else { return "None" }
        return dependentManager.dependents.first { $0.id == selectedId }?.fullName ?? "None"
    }
    
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
                    .foregroundColor(Color.monoPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if selectedImage == nil {
                            Button("Help") {
                                showingHelp = true
                            }
                            .foregroundColor(Color.monoPrimary)
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
                        .background(Color.monoPrimary)
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
                            .foregroundColor(.monoPrimary)
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
                            .foregroundColor(.monoPrimary)
                        Spacer()
                        Text(suggestedCategory)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.monoPrimary)
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
                        .foregroundColor(.monoPrimary)

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
                    .foregroundColor(.monoPrimary)

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
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Description (Optional)")
                    .font(.headline)
                    .foregroundColor(.monoPrimary)

                TextField("Enter description", text: $description)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Date")
                    .font(.headline)
                    .foregroundColor(.monoPrimary)

                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Time")
                    .font(.headline)
                    .foregroundColor(.monoPrimary)
                
                // Keep the visible label above the picker and hide the DatePicker's internal label
                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            
            // Dependent Association Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Associate with Dependent (Optional)")
                    .font(.headline)
                    .foregroundColor(.monoPrimary)
                
                Menu {
                    Button(action: {
                        isForDependent = false
                        selectedDependentId = nil
                    }) {
                        HStack {
                            Text("None")
                            if !isForDependent {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    ForEach(dependentManager.dependents) { dependent in
                        Button(action: {
                            isForDependent = true
                            selectedDependentId = dependent.id
                        }) {
                            HStack {
                                Text(dependent.fullName)
                                if selectedDependentId == dependent.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.2")
                            .foregroundColor(.monoPrimary)
                        
                        Text(selectedDependentName)
                            .font(.system(size: 16))
                            .foregroundColor(selectedDependentName == "None" ? .gray : .primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Recurring Expense Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Recurring Expense")
                        .font(.headline)
                        .foregroundColor(.monoPrimary)
                    
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
            
            // Payment Reminder Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Payment Reminder")
                        .font(.headline)
                        .foregroundColor(.monoPrimary)
                    
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
                                
                                Stepper(value: $reminderDayOfMonth, in: 1...28) {
                                    Text("Day \(reminderDayOfMonth)")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut(duration: 0.3), value: isPaymentReminder)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Location Section
            StandardLocationPicker(includeLocation: $includeLocation, selectedLocation: $selectedLocation)
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
        
        // Combine selected date and time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        expense.date = calendar.date(from: combinedComponents) ?? selectedDate
        expense.isRecurring = isRecurring
        expense.recurringFrequency = isRecurring ? selectedFrequency.lowercased() : nil
        expense.isPaymentReminder = isPaymentReminder
        expense.reminderDate = (reminderFrequency == "Once" || reminderFrequency == "Yearly") ? reminderDate : nil
        expense.reminderDayOfMonth = reminderFrequency == "Monthly" ? Int16(reminderDayOfMonth) : 0
        expense.reminderFrequency = isPaymentReminder ? reminderFrequency : nil
        expense.isReminderActive = isPaymentReminder
        expense.lastReminderSent = nil
        expense.userID = currentUser.id ?? UUID()
        expense.createdAt = Date()
        expense.updatedAt = Date()
        expense.user = currentUser
        
        // Associate with dependent if selected
        if isForDependent && selectedDependentId != nil {
            expense.setValue(selectedDependentId, forKey: "dependentID")
            
            // Set dependent relationship in Core Data
            let context = coreDataStack.context
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DependentEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", selectedDependentId! as CVarArg)
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try context.fetch(fetchRequest)
                if let dependentEntity = results.first {
                    expense.setValue(dependentEntity, forKey: "dependent")
                }
            } catch {
                print("Error setting dependent relationship: \(error)")
            }
        }
        
        // Handle location data - standardized
        if includeLocation, let location = selectedLocation {
            expense.setValue(location.name, forKey: "locationName")
            expense.setValue(location.coordinate.latitude, forKey: "latitude")
            expense.setValue(location.coordinate.longitude, forKey: "longitude")
        }
        
        finalizeExpenseSave(expense: expense)
    }
    
    private func finalizeExpenseSave(expense: ExpenseEntity) {
        do {
            try coreDataStack.context.save()
            
            // Schedule notifications if enabled
            if isRecurring {
                let frequency = convertStringToRecurringFrequency(selectedFrequency)
                var reminderDescription = description.isEmpty ? nil : description
                
                // Add dependent information to reminder if associated
                if isForDependent && selectedDependentId != nil {
                    if let dependent = dependentManager.dependents.first(where: { $0.id == selectedDependentId }) {
                        let dependentInfo = "for \(dependent.firstName)"
                        if let existingDesc = reminderDescription {
                            reminderDescription = "\(existingDesc) (\(dependentInfo))"
                        } else {
                            reminderDescription = "\(selectedCategory) expense \(dependentInfo)"
                        }
                    }
                }
                
                notificationManager.scheduleExpenseReminder(
                    amount: expense.amount,
                    description: reminderDescription,
                    category: selectedCategory,
                    date: selectedDate,
                    isRecurring: true,
                    frequency: frequency
                )
            }
            
            if isPaymentReminder {
                let frequency = convertStringToReminderFrequency(reminderFrequency)
                var reminderScheduleDate = reminderDate
                
                if reminderFrequency == "Monthly" {
                    var components = Calendar.current.dateComponents([.year, .month], from: Date())
                    components.day = reminderDayOfMonth
                    if let newDate = Calendar.current.date(from: components) {
                        reminderScheduleDate = newDate
                        
                        if reminderScheduleDate < Date() {
                            components.month = (components.month ?? 1) + 1
                            reminderScheduleDate = Calendar.current.date(from: components) ?? Date()
                        }
                    }
                }
                
                var paymentDescription = "\(selectedCategory) payment"
                
                // Add dependent information to payment reminder if associated
                if isForDependent && selectedDependentId != nil {
                    if let dependent = dependentManager.dependents.first(where: { $0.id == selectedDependentId }) {
                        paymentDescription = "\(selectedCategory) payment for \(dependent.firstName)"
                    }
                }
                
                notificationManager.schedulePaymentReminder(
                    amount: expense.amount,
                    description: paymentDescription,
                    reminderDate: reminderScheduleDate,
                    frequency: frequency
                )
            }
            
            var message = "Expense of Rs. \(String(format: "%.2f", expense.amount)) saved successfully from receipt scan!"
            
            if isForDependent && selectedDependentId != nil {
                if let dependent = dependentManager.dependents.first(where: { $0.id == selectedDependentId }) {
                    message += "\nAssociated with: \(dependent.fullName)"
                }
            }
            
            if let locationName = expense.value(forKey: "locationName") as? String {
                message += "\nLocation: \(locationName)"
            }
            
            if isRecurring || isPaymentReminder {
                message += "\nReminder notifications have been set up."
                
                // Add dependent-specific reminder context
                if isForDependent && selectedDependentId != nil {
                    if let dependent = dependentManager.dependents.first(where: { $0.id == selectedDependentId }) {
                        message += "\nReminders will include \(dependent.firstName)'s name for easy identification."
                    }
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

struct OCRExpenseEntry_Previews: PreviewProvider {
    static var previews: some View {
        OCRExpenseEntry()
    }
}



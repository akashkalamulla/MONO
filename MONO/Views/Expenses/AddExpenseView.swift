//
//  AddExpenseView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-17.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: ExpenseType = .expenses
    @State private var selectedCategory: ExpenseCategory?
    @State private var showingAddExpenseDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("Add")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Button("Cancel") {
                        dismiss()
                    }
                    .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Type Selection Buttons
                HStack(spacing: 12) {
                    TypeSelectionButton(
                        title: "Expenses",
                        isSelected: selectedType == .expenses,
                        selectedColor: Color(hex: "#438883")
                    ) {
                        selectedType = .expenses
                    }
                    
                    TypeSelectionButton(
                        title: "Income",
                        isSelected: selectedType == .income,
                        borderColor: Color(hex: "#438883")
                    ) {
                        selectedType = .income
                    }
                    
                    TypeSelectionButton(
                        title: "Transfer",
                        isSelected: selectedType == .transfer,
                        borderColor: Color(hex: "#438883")
                    ) {
                        selectedType = .transfer
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                // Categories Grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 24) {
                        ForEach(categoriesForType(selectedType), id: \.id) { category in
                            CategoryButton(category: category) {
                                selectedCategory = category
                                showingAddExpenseDetail = true
                            }
                        }
                        
                        // Add Expenses Button
                        AddCategoryButton {
                            // Handle add new category
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                }
                
                Spacer()
            }
            .background(Color(UIColor.systemGray6))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddExpenseDetail) {
            if let category = selectedCategory {
                AddExpenseDetailView(
                    type: selectedType,
                    category: category
                )
            }
        }
    }
    
    private func categoriesForType(_ type: ExpenseType) -> [ExpenseCategory] {
        switch type {
        case .expenses:
            return ExpenseCategory.expenseCategories
        case .income:
            return ExpenseCategory.incomeCategories
        case .transfer:
            return ExpenseCategory.transferCategories
        }
    }
}

// MARK: - Type Selection Button
struct TypeSelectionButton: View {
    let title: String
    let isSelected: Bool
    let selectedColor: Color
    let borderColor: Color
    let action: () -> Void
    
    init(
        title: String,
        isSelected: Bool,
        selectedColor: Color = .clear,
        borderColor: Color = .clear,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.selectedColor = selectedColor
        self.borderColor = borderColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : borderColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? selectedColor : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.clear : borderColor, lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: ExpenseCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon Container
                RoundedRectangle(cornerRadius: 16)
                    .fill(category.color.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: category.icon)
                            .font(.system(size: 24))
                            .foregroundColor(category.color)
                    )
                
                // Category Name
                Text(category.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Add Category Button
struct AddCategoryButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon Container
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#438883"))
                    )
                
                // Category Name
                Text("Add Expenses")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#438883"))
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Models
enum ExpenseType: String, CaseIterable {
    case expenses = "Expenses"
    case income = "Income"
    case transfer = "Transfer"
}

struct ExpenseCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    
    static let expenseCategories = [
        ExpenseCategory(name: "Shopping", icon: "bag.fill", color: .blue),
        ExpenseCategory(name: "Food", icon: "fork.knife", color: .cyan),
        ExpenseCategory(name: "Phone", icon: "phone.fill", color: .blue),
        ExpenseCategory(name: "Water Bill", icon: "drop.fill", color: .cyan),
        ExpenseCategory(name: "Education", icon: "graduationcap.fill", color: .blue),
        ExpenseCategory(name: "Party", icon: "party.popper.fill", color: .red),
        ExpenseCategory(name: "Current Bill", icon: "bolt.fill", color: .yellow),
        ExpenseCategory(name: "Internet Bill", icon: "wifi", color: .blue),
        ExpenseCategory(name: "Health", icon: "cross.fill", color: .cyan),
        ExpenseCategory(name: "Groceries", icon: "cart.fill", color: .cyan),
        ExpenseCategory(name: "Clothing", icon: "tshirt.fill", color: .orange),
        ExpenseCategory(name: "Gifts", icon: "gift.fill", color: .brown)
    ]
    
    static let incomeCategories = [
        ExpenseCategory(name: "Salary", icon: "banknote.fill", color: .green),
        ExpenseCategory(name: "Freelance", icon: "laptopcomputer", color: .blue),
        ExpenseCategory(name: "Investment", icon: "chart.line.uptrend.xyaxis", color: .green),
        ExpenseCategory(name: "Business", icon: "briefcase.fill", color: .purple),
        ExpenseCategory(name: "Bonus", icon: "star.fill", color: .yellow),
        ExpenseCategory(name: "Gift Money", icon: "gift.fill", color: .pink),
        ExpenseCategory(name: "Rental", icon: "house.fill", color: .brown),
        ExpenseCategory(name: "Other", icon: "plus.circle.fill", color: .gray)
    ]
    
    static let transferCategories = [
        ExpenseCategory(name: "Bank Transfer", icon: "building.columns.fill", color: .blue),
        ExpenseCategory(name: "Cash Deposit", icon: "banknote.fill", color: .green),
        ExpenseCategory(name: "Card Payment", icon: "creditcard.fill", color: .purple),
        ExpenseCategory(name: "Mobile Payment", icon: "phone.and.waveform.fill", color: .orange),
        ExpenseCategory(name: "Online Transfer", icon: "wifi", color: .cyan),
        ExpenseCategory(name: "ATM", icon: "rectangle.portrait.and.arrow.forward", color: .gray),
        ExpenseCategory(name: "Wallet", icon: "wallet.pass.fill", color: .brown),
        ExpenseCategory(name: "Other", icon: "arrow.left.arrow.right.circle.fill", color: .indigo)
    ]
}

// MARK: - Add Expense Detail View
struct AddExpenseDetailView: View {
    let type: ExpenseType
    let category: ExpenseCategory
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var expenseManager: ExpenseManager
    
    init(type: ExpenseType, category: ExpenseCategory) {
        self.type = type
        self.category = category
        self._expenseManager = StateObject(wrappedValue: ExpenseManager(context: PersistenceController.shared.container.viewContext))
    }
    
    // Form State
    @State private var expenseName: String = ""
    @State private var amount: String = ""
    @State private var selectedDate = Date()
    @State private var notes: String = ""
    @State private var selectedLocation: String = ""
    @State private var useCurrentLocation = false
    @State private var reminderEnabled = false
    @State private var reminderDate = Date()
    
    // UI State
    @State private var showingDatePicker = false
    @State private var showingLocationPicker = false
    @State private var showingReminderPicker = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Location
    @State private var currentLocationName = "Add location"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HeaderView()
                
                // Form Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Name Field
                        NameFieldSection()
                        
                        // Amount Field
                        AmountFieldSection()
                        
                        // Date Field
                        DateFieldSection()
                        
                        // Location Field
                        LocationFieldSection()
                        
                        // Notes Field
                        NotesFieldSection()
                        
                        // Reminder Field
                        ReminderFieldSection()
                        
                        // Save Button
                        SaveButtonSection()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
                .background(Color(UIColor.systemGray6))
            }
            .navigationBarHidden(true)
        }
        .alert("Expense", isPresented: $showingAlert) {
            Button("OK") { }
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
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Add \(type.rawValue)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    // More options
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .background(Color(hex: "#438883"))
    }
    
    // MARK: - Name Field Section
    @ViewBuilder
    private func NameFieldSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NAME")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            HStack(spacing: 12) {
                // Category Icon
                RoundedRectangle(cornerRadius: 8)
                    .fill(category.color.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: category.icon)
                            .font(.system(size: 18))
                            .foregroundColor(category.color)
                    )
                
                // Name Field with Dropdown
                HStack {
                    TextField("Enter expense name", text: $expenseName)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        // Show dropdown with suggestions
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 12)
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
                    .foregroundColor(Color(hex: "#438883"))
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
            Text("DATE")
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
    
    // MARK: - Location Field Section
    @ViewBuilder
    private func LocationFieldSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LOCATION")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            Button(action: {
                showingLocationPicker = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                    
                    Text(selectedLocation.isEmpty ? "Add location" : selectedLocation)
                        .font(.system(size: 16))
                        .foregroundColor(selectedLocation.isEmpty ? .gray : .primary)
                    
                    Spacer()
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
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerSheet(
                selectedLocation: $selectedLocation,
                useCurrentLocation: $useCurrentLocation
            )
        }
    }
    
    // MARK: - Notes Field Section
    @ViewBuilder
    private func NotesFieldSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NOTES (OPTIONAL)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            TextField("Add notes...", text: $notes, axis: .vertical)
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
    
    // MARK: - Reminder Field Section
    @ViewBuilder
    private func ReminderFieldSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("REMINDER")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                
                Spacer()
                
                Toggle("", isOn: $reminderEnabled)
                    .labelsHidden()
            }
            
            if reminderEnabled {
                Button(action: {
                    showingReminderPicker = true
                }) {
                    HStack {
                        Text(formatDateTime(reminderDate))
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "bell")
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
                .sheet(isPresented: $showingReminderPicker) {
                    ReminderPickerSheet(reminderDate: $reminderDate)
                }
            }
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
            saveExpense()
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                }
                Text("Save \(type.rawValue)")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFormValid ? Color(hex: "#438883") : Color.gray)
            .cornerRadius(12)
        }
        .disabled(!isFormValid || isLoading)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helper Methods
    private var isFormValid: Bool {
        !expenseName.isEmpty && !amount.isEmpty && Double(amount.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)) != nil
    }
    
    private func setupDefaults() {
        expenseName = category.name
        if type == .expenses {
            reminderDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? Date()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    private func saveExpense() {
        guard isFormValid,
              let user = authManager.currentUser,
              let amountDouble = Double(amount.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)) else {
            return
        }
        
        isLoading = true
        
        // Get location coordinates if using current location
        Task {
            var latitude: Double? = nil
            var longitude: Double? = nil
            var locationName = selectedLocation
            
            if useCurrentLocation {
                if let coordinates = await LocationHelper.getCurrentCoordinates() {
                    latitude = coordinates.latitude
                    longitude = coordinates.longitude
                }
                locationName = await LocationHelper.getCurrentLocationName()
            }
            
            await MainActor.run {
                let success = expenseManager.addExpense(
                    name: expenseName,
                    amount: amountDouble,
                    type: type.rawValue,
                    category: category.name,
                    categoryIcon: category.icon,
                    categoryColor: category.color.description,
                    date: selectedDate,
                    location: locationName.isEmpty ? nil : locationName,
                    latitude: latitude,
                    longitude: longitude,
                    notes: notes.isEmpty ? nil : notes,
                    reminderDate: reminderEnabled ? reminderDate : nil,
                    user: user
                )
                
                isLoading = false
                
                if success {
                    alertMessage = "\(type.rawValue) saved successfully!"
                    showingAlert = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                } else {
                    alertMessage = "Failed to save \(type.rawValue.lowercased()). Please try again."
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Supporting Views
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

struct LocationPickerSheet: View {
    @Binding var selectedLocation: String
    @Binding var useCurrentLocation: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var currentLocationName = "Current Location"
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search location", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top)
                
                List {
                    // Current Location
                    Button(action: {
                        selectedLocation = currentLocationName
                        useCurrentLocation = true
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("Use Current Location")
                                    .foregroundColor(.primary)
                                Text(currentLocationName)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Sample Locations
                    ForEach(sampleLocations.filter { searchText.isEmpty || $0.lowercased().contains(searchText.lowercased()) }, id: \.self) { location in
                        Button(action: {
                            selectedLocation = location
                            useCurrentLocation = false
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                
                                Text(location)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private let sampleLocations = [
        "Home",
        "Office",
        "Grocery Store",
        "Mall",
        "Restaurant",
        "Gas Station",
        "Pharmacy",
        "Bank"
    ]
}

struct ReminderPickerSheet: View {
    @Binding var reminderDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Reminder Date & Time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.wheel)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Set Reminder")
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
    AddExpenseView()
}

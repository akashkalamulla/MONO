//
//  SimpleExpenseEntry.swift
//  MONO
//
//  Created by Akash01 on 2025-08-21.
//

import SwiftUI
import CoreData
import MapKit
import CoreLocation

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
    @State private var selectedPlacemark: CLPlacemark?
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var showMapPicker = false
    @State private var locationName: String = ""
    @State private var showingOCREntry = false
    
    var dependentManager = DependentManager()
    
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
    
                VStack(spacing: 12) {
                    Button(action: {
                        showingOCREntry = true
                    }) {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Scan Receipt")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Auto-extract amount & category")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("OR")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                }
                
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
                    Text("Date")
                        .font(.headline)
                    
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
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
            
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.headline)
                    
                    TextField("Enter description", text: $description)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Location (Optional)")
                            .font(.headline)

                        Spacer()

                        Button(action: { showMapPicker.toggle() }) {
                            Image(systemName: "mappin.and.ellipse")
                        }
                    }

                    if !locationName.isEmpty {
                        Text(locationName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("No location selected")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
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
        .sheet(isPresented: $showMapPicker) {
            MapPickerView(region: $region) { placemark in
                selectedPlacemark = placemark
                locationName = placemark.name ?? placemark.locality ?? "Selected location"
            }
        }
        .fullScreenCover(isPresented: $showingOCREntry) {
            OCRExpenseEntry()
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
        
        let categoryObj = ExpenseCategory.defaultCategories.first { $0.name == selectedCategory } ?? 
                         ExpenseCategory.defaultCategories.last! // Use "Other" as fallback
        
        let recurrenceFreq: String? = isRecurring ? selectedFrequency.lowercased() : nil
        
        let reminderDay: Int32? = reminderFrequency == "Monthly" ? Int32(reminderDayOfMonth) : nil
        let reminderDate = (reminderFrequency == "Once" || reminderFrequency == "Yearly") ? self.reminderDate : nil
        
        let context = coreDataStack.context
        let expense = NSEntityDescription.insertNewObject(forEntityName: "ExpenseEntity", into: context)
        
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
        
        if isForDependent && selectedDependentId != nil {
            expense.setValue(selectedDependentId, forKey: "dependentID")
            
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

        if let placemark = selectedPlacemark {
            expense.setValue(placemark.name ?? locationName, forKey: "locationName")
            if let coord = placemark.location?.coordinate {
                expense.setValue(coord.latitude, forKey: "latitude")
                expense.setValue(coord.longitude, forKey: "longitude")
            }
        } else if !locationName.isEmpty {
            expense.setValue(locationName, forKey: "locationName")
        }
        
        do {
            try context.save()
            
            var message = "Expense of Rs. \(String(format: "%.2f", amountValue)) saved"
            
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

struct MapPickerView: View {
    @Binding var region: MKCoordinateRegion
    var onSelect: (CLPlacemark) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var isResolving = false
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var pinnedCoordinate: CLLocationCoordinate2D?
    private let geocoder = CLGeocoder()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search for a location in Sri Lanka", text: $searchText, onCommit: {
                            searchLocation()
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if isSearching {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    if !searchResults.isEmpty {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 8) {
                                ForEach(searchResults, id: \.self) { item in
                                    Button(action: {
                                        selectSearchResult(item)
                                    }) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name ?? "Unknown")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            if let address = item.placemark.title {
                                                Text(address)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 200)
                    }
                }
                .background(Color(UIColor.systemBackground))
                
                // Map view
                ZStack {
                    Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: pinnedCoordinate != nil ? [PinnedLocation(coordinate: pinnedCoordinate!)] : []) { location in
                        MapPin(coordinate: location.coordinate, tint: .red)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .onTapGesture { location in
                        let coordinate = region.center
                        pinnedCoordinate = coordinate
                        searchResults = []
                        searchText = ""
                    }

                    if pinnedCoordinate == nil {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                            .background(Circle().fill(Color.white).frame(width: 30, height: 30))
                    }
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Select") {
                    if let coordinate = pinnedCoordinate {
                        resolvePlacemark(for: coordinate)
                    } else {
                        resolvePlacemark(for: region.center)
                    }
                }
                .disabled(isResolving)
            )
        }
    }
    
    private func searchLocation() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
            span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                isSearching = false
                if let response = response {
                    searchResults = response.mapItems
                } else {
                    searchResults = []
                }
            }
        }
    }
    
    private func selectSearchResult(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        pinnedCoordinate = coordinate
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        searchResults = []
        searchText = item.name ?? ""
    }

    private func resolvePlacemark(for coordinate: CLLocationCoordinate2D) {
        isResolving = true
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                isResolving = false
                if let placemark = placemarks?.first {
                    onSelect(placemark)
                }
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}


struct PinnedLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct SimpleExpenseEntry_Previews: PreviewProvider {
    static var previews: some View {
        SimpleExpenseEntry()
    }
}

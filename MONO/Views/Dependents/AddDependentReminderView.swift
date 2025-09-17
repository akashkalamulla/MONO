//
//  AddDependentReminderView.swift
//  MONO
//
//  Created by Akash01 on 2025-09-17.
//

import SwiftUI
import MapKit
import CoreLocation

struct AddDependentReminderView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var reminderManager: DependentReminderManager
    let dependent: Dependent
    
    @State private var paymentName: String = ""
    @State private var amount: String = ""
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var includeLocation = false
    @State private var selectedLocation: ReminderLocation?
    @State private var showingLocationPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 50))
                            .foregroundColor(.monoPrimary)
                        
                        Text("Set Custom Reminder")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.monoPrimary)
                        
                        Text("for \(dependent.fullName)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    VStack(spacing: 20) {
                        // Payment Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Payment Name")
                                .font(.headline)
                                .foregroundColor(.monoPrimary)
                            
                            TextField("e.g., School Fee, Allowance", text: $paymentName)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        // Amount
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
                        
                        // Date
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
                        
                        // Time
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Time")
                                .font(.headline)
                                .foregroundColor(.monoPrimary)
                            
                            // Show a top-aligned label and hide the DatePicker's internal label so
                            // the picker title doesn't render vertically on the side.
                            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(WheelDatePickerStyle())
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        // Location Toggle
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Include Location")
                                    .font(.headline)
                                    .foregroundColor(.monoPrimary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $includeLocation)
                                    .toggleStyle(SwitchToggleStyle(tint: .monoPrimary))
                            }
                            
                            if includeLocation {
                                VStack(spacing: 12) {
                                    Button(action: {
                                        showingLocationPicker = true
                                    }) {
                                        HStack {
                                            Image(systemName: "location")
                                                .foregroundColor(.monoPrimary)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(selectedLocation?.name ?? "Select Location")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(selectedLocation == nil ? .gray : .primary)
                                                
                                                if let address = selectedLocation?.address {
                                                    Text(address)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    // Location preview map
                                    if let location = selectedLocation {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Reminder Location")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            
                                            Map(coordinateRegion: .constant(MKCoordinateRegion(
                                                center: location.coordinate,
                                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                            )), annotationItems: [location]) { location in
                                                MapPin(coordinate: location.coordinate, tint: .red)
                                            }
                                            .frame(height: 120)
                                            .cornerRadius(12)
                                            .allowsHitTesting(false)
                                        }
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .animation(.easeInOut(duration: 0.3), value: includeLocation)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: saveReminder) {
                        Text("Set Reminder")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isFormValid ? Color.monoPrimary : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.monoPrimary)
                }
            }
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(region: $region, selectedLocation: $selectedLocation)
        }
        .alert("Reminder Set", isPresented: $showingAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            reminderManager.requestNotificationPermissions()
        }
    }
    
    private var isFormValid: Bool {
        return !paymentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !amount.isEmpty &&
               Double(amount) != nil &&
               Double(amount)! > 0
    }
    
    private func saveReminder() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        
        let reminder = DependentReminder(
            paymentName: paymentName.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amountValue,
            date: selectedDate,
            time: selectedTime,
            location: includeLocation ? selectedLocation : nil,
            dependentId: dependent.id
        )
        
        reminderManager.addReminder(reminder)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        var message = "Reminder set for \(formatter.string(from: reminder.combinedDateTime))"
        if let location = reminder.location {
            message += "\nLocation: \(location.name)"
        }
        
        alertMessage = message
        showingAlert = true
    }
}

struct LocationPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var region: MKCoordinateRegion
    @Binding var selectedLocation: ReminderLocation?
    
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var showingSearchResults = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search for a place", text: $searchText)
                        .onSubmit {
                            searchForLocations()
                        }
                    
                    if !searchText.isEmpty {
                        Button("Clear") {
                            searchText = ""
                            searchResults = []
                            showingSearchResults = false
                        }
                        .foregroundColor(.monoPrimary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                ZStack {
                    Map(coordinateRegion: $region, annotationItems: selectedLocation != nil ? [selectedLocation!] : []) { location in
                        MapPin(coordinate: location.coordinate, tint: .red)
                    }
                    .onTapGesture { location in
                        selectLocationFromMap(at: location)
                    }
                    
                    if showingSearchResults && !searchResults.isEmpty {
                        VStack {
                            Spacer()
                            
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(searchResults, id: \.self) { item in
                                        Button(action: {
                                            selectSearchResult(item)
                                        }) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(item.name ?? "Unknown")
                                                        .font(.headline)
                                                        .foregroundColor(.primary)
                                                    
                                                    if let address = item.placemark.title {
                                                        Text(address)
                                                            .font(.caption)
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(8)
                                            .shadow(radius: 2)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding()
                            }
                            .frame(maxHeight: 200)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(12)
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.monoPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.monoPrimary)
                    .disabled(selectedLocation == nil)
                }
            }
        }
    }
    
    private func searchForLocations() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                if let response = response {
                    self.searchResults = response.mapItems
                    self.showingSearchResults = true
                } else {
                    self.searchResults = []
                    self.showingSearchResults = false
                }
            }
        }
    }
    
    private func selectSearchResult(_ item: MKMapItem) {
        selectedLocation = ReminderLocation(from: item.placemark)
        region = MKCoordinateRegion(
            center: item.placemark.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        showingSearchResults = false
        searchText = ""
        searchResults = []
    }
    
    private func selectLocationFromMap(at tapLocation: CGPoint) {
        // This is a simplified implementation
        // In a real app, you'd convert the tap location to coordinates and reverse geocode
        let coordinate = region.center
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    self.selectedLocation = ReminderLocation(from: placemark)
                }
            }
        }
    }
}

#Preview {
    let sampleDependent = Dependent(
        firstName: "Emma",
        lastName: "Smith",
        relationship: "Child",
        dateOfBirth: Calendar.current.date(byAdding: .year, value: -8, to: Date()) ?? Date(),
        phoneNumber: "555-0123",
        email: "emma@example.com",
        userId: UUID()
    )
    
    AddDependentReminderView(
        reminderManager: DependentReminderManager(),
        dependent: sampleDependent
    )
}

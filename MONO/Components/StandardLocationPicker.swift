//
//  StandardLocationPicker.swift
//  MONO
//
//  Created by Akash01 on 2025-09-17.
//

import SwiftUI
import MapKit
import CoreLocation

struct StandardLocationPicker: View {
    @Binding var includeLocation: Bool
    @Binding var selectedLocation: ReminderLocation?
    @State private var showingLocationPicker = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612), 
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    var body: some View {
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
                            Text("Selected Location")
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
        .sheet(isPresented: $showingLocationPicker) {
            StandardLocationPickerView(region: $region, selectedLocation: $selectedLocation)
        }
    }
}

struct StandardLocationPickerView: View {
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
    struct PreviewWrapper: View {
        @State private var includeLocation = false
        @State private var selectedLocation: ReminderLocation?
        
        var body: some View {
            StandardLocationPicker(includeLocation: $includeLocation, selectedLocation: $selectedLocation)
                .padding()
        }
    }
    
    return PreviewWrapper()
}

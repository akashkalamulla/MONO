//
//  SharedLocationComponents.swift
//  MONO
//
//  Created by Akash01 on 2025-09-17.
//

import SwiftUI
import CoreLocation
import MapKit

// Location Manager helper class
class SimpleLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
}

// Map Picker View for selecting locations
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
                
                ZStack {
                    Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: pinnedCoordinate != nil ? [PinnedLocation(coordinate: pinnedCoordinate!)] : []) { location in
                            MapPin(coordinate: location.coordinate, tint: Color.monoPrimary)
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
                            .foregroundColor(Color.monoPrimary)
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

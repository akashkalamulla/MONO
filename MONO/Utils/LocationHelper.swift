import Foundation
import CoreLocation
import MapKit

class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationHelper()
    
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var locationName = "Current Location"
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        
        locationManager.requestLocation()
    }
    
    // MARK: - Static Helper Methods
    static func getCurrentCoordinates() async -> CLLocationCoordinate2D? {
        return await withCheckedContinuation { continuation in
            let helper = LocationHelper.shared
            
            if let location = helper.currentLocation {
                continuation.resume(returning: location.coordinate)
                return
            }
            
            helper.requestLocation()
            
            // Give it a timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                continuation.resume(returning: helper.currentLocation?.coordinate)
            }
        }
    }
    
    static func getCurrentLocationName() async -> String {
        guard let coordinates = await getCurrentCoordinates() else {
            return "Current Location"
        }
        
        return await withCheckedContinuation { continuation in
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first {
                    let name = [placemark.name, placemark.locality, placemark.administrativeArea]
                        .compactMap { $0 }
                        .joined(separator: ", ")
                    continuation.resume(returning: name.isEmpty ? "Current Location" : name)
                } else {
                    continuation.resume(returning: "Current Location")
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
        }
        
        // Get location name
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    let name = [placemark.name, placemark.locality]
                        .compactMap { $0 }
                        .joined(separator: ", ")
                    self?.locationName = name.isEmpty ? "Current Location" : name
                } else {
                    self?.locationName = "Current Location"
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

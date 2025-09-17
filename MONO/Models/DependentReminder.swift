//
//  DependentReminder.swift
//  MONO
//
//  Created by Akash01 on 2025-09-17.
//

import Foundation
import CoreLocation

struct DependentReminder: Identifiable, Codable {
    let id: UUID
    var paymentName: String
    var amount: Double
    var date: Date
    var time: Date
    var location: ReminderLocation?
    var dependentId: UUID
    var isCompleted: Bool
    var isActive: Bool
    var notificationId: String?
    var createdAt: Date
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        paymentName: String,
        amount: Double,
        date: Date,
        time: Date,
        location: ReminderLocation? = nil,
        dependentId: UUID,
        isCompleted: Bool = false,
        isActive: Bool = true,
        notificationId: String? = nil,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.paymentName = paymentName
        self.amount = amount
        self.date = date
        self.time = time
        self.location = location
        self.dependentId = dependentId
        self.isCompleted = isCompleted
        self.isActive = isActive
        self.notificationId = notificationId
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
    
    var combinedDateTime: Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combined = dateComponents
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        return calendar.date(from: combined) ?? date
    }
    
    var isOverdue: Bool {
        return !isCompleted && combinedDateTime < Date()
    }
    
    var isUpcoming: Bool {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return !isCompleted && combinedDateTime >= Date() && combinedDateTime <= tomorrow
    }
}

struct ReminderLocation: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String?
    let latitude: Double
    let longitude: Double
    
    init(id: UUID = UUID(), name: String, address: String? = nil, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from placemark: CLPlacemark) {
        self.id = UUID()
        self.name = placemark.name ?? "Selected Location"
        self.address = [
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea
        ].compactMap { $0 }.joined(separator: ", ")
        self.latitude = placemark.location?.coordinate.latitude ?? 0.0
        self.longitude = placemark.location?.coordinate.longitude ?? 0.0
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Reminder Status Extensions
extension DependentReminder {
    enum Status {
        case upcoming
        case overdue
        case completed
        case inactive
        
        var title: String {
            switch self {
            case .upcoming: return "Upcoming"
            case .overdue: return "Overdue"
            case .completed: return "Completed"
            case .inactive: return "Inactive"
            }
        }
        
        var color: String {
            switch self {
            case .upcoming: return "blue"
            case .overdue: return "red"
            case .completed: return "green"
            case .inactive: return "gray"
            }
        }
    }
    
    var status: Status {
        if !isActive {
            return .inactive
        } else if isCompleted {
            return .completed
        } else if isOverdue {
            return .overdue
        } else {
            return .upcoming
        }
    }
}

//
//  DependentReminderEntity+Extensions.swift
//  MONO
//
//  Created by Akash01 on 2025-09-17.
//

import Foundation
import CoreData

extension DependentReminderEntity {
    
    // TODO: Uncomment these when Core Data model has all required fields
    /*
    var wrappedId: UUID {
        return id ?? UUID()
    }
    
    var wrappedPaymentName: String {
        return paymentName ?? "Unknown Payment"
    }
    
    var wrappedDate: Date {
        return date ?? Date()
    }
    
    var wrappedCreatedAt: Date {
        return createdAt ?? Date()
    }
    
    var wrappedNotificationId: String? {
        return notificationId
    }
    */
    
    var hasLocation: Bool {
        return locationName != nil && locationLatitude != nil && locationLongitude != nil
    }
    
    var locationCoordinate: (latitude: Double, longitude: Double)? {
        guard locationName != nil else { return nil }
        return (latitude: locationLatitude, longitude: locationLongitude)
    }
    
    // Convert to DependentReminder model
    func toDependentReminder() -> DependentReminder? {
        // For now, use default values since Core Data model is incomplete
        // TODO: Update Core Data model to include all required fields
        
        guard let dependentEntity = dependent,
              let dependentId = dependentEntity.id else {
            return nil
        }
        
        var location: ReminderLocation? = nil
        if let locationName = locationName {
            location = ReminderLocation(
                id: UUID(),
                name: locationName,
                address: nil,
                latitude: locationLatitude,
                longitude: locationLongitude
            )
        }
        
        return DependentReminder(
            id: UUID(), // TODO: Add id field to Core Data
            paymentName: "Unknown Payment", // TODO: Add paymentName field to Core Data
            amount: 0.0, // TODO: Add amount field to Core Data
            date: Date(), // TODO: Add date field to Core Data
            time: Date(), // TODO: Add time field to Core Data
            location: location,
            dependentId: dependentId,
            isCompleted: false, // TODO: Add isCompleted field to Core Data
            isActive: true, // TODO: Add isActive field to Core Data
            notificationId: nil, // TODO: Add notificationId field to Core Data
            createdAt: Date(), // TODO: Add createdAt field to Core Data
            completedAt: nil // TODO: Add completedAt field to Core Data
        )
    }
    
    // Update from DependentReminder model
    func update(from reminder: DependentReminder) {
        // Only update fields that exist in current Core Data model
        
        // TODO: Add these fields to Core Data model:
        // self.id = reminder.id
        // self.paymentName = reminder.paymentName
        // self.amount = reminder.amount
        // self.date = reminder.combinedDateTime
        // self.isCompleted = reminder.isCompleted
        // self.completedAt = reminder.completedAt
        // self.notificationId = reminder.notificationId
        // self.createdAt = reminder.createdAt
        
        // Update location data (these fields exist)
        if let location = reminder.location {
            self.locationName = location.name
            self.locationLatitude = location.latitude
            self.locationLongitude = location.longitude
        } else {
            self.locationName = nil
            self.locationLatitude = 0.0  // Use default value instead of nil for non-optional Double
            self.locationLongitude = 0.0  // Use default value instead of nil for non-optional Double
        }
    }
}

// MARK: - Fetch Request
extension DependentReminderEntity {
    
    static func fetchRemindersForDependent(_ dependentId: UUID, context: NSManagedObjectContext) -> [DependentReminderEntity] {
        let request: NSFetchRequest<DependentReminderEntity> = DependentReminderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "dependent.id == %@", dependentId as CVarArg)
        // TODO: Uncomment when 'date' field is added to Core Data
        // request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching reminders for dependent: \(error)")
            return []
        }
    }
    
    // TODO: Uncomment these methods when Core Data model has required fields
    /*
    static func fetchActiveReminders(context: NSManagedObjectContext) -> [DependentReminderEntity] {
        let request: NSFetchRequest<DependentReminderEntity> = DependentReminderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == false")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching active reminders: \(error)")
            return []
        }
    }
    */
    
    static func fetchRemindersWithLocation(context: NSManagedObjectContext) -> [DependentReminderEntity] {
        let request: NSFetchRequest<DependentReminderEntity> = DependentReminderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "locationName != nil AND locationLatitude != nil AND locationLongitude != nil")
        // TODO: Uncomment when 'date' field is added to Core Data
        // request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching reminders with location: \(error)")
            return []
        }
    }
}

//
//  DependentReminderEntity+Extensions.swift
//  MONO
//
//  Created by Akash01 on 2025-09-17.
//

import Foundation
import CoreData

extension DependentReminderEntity {
    

    
    var hasLocation: Bool {
        return locationName != nil && locationLatitude != nil && locationLongitude != nil
    }
    
    var locationCoordinate: (latitude: Double, longitude: Double)? {
        guard locationName != nil else { return nil }
        return (latitude: locationLatitude, longitude: locationLongitude)
    }
    
    // Convert to DependentReminder model
    func toDependentReminder() -> DependentReminder? {

        
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
            id: UUID(),
            paymentName: "Unknown Payment",
            amount: 0.0,
            date: Date(),
            time: Date(),
            location: location,
            dependentId: dependentId,
            isCompleted: false,
            isActive: true,
            notificationId: nil,
            createdAt: Date(),
            completedAt: nil
        )
    }
    
    // Update from DependentReminder model
    func update(from reminder: DependentReminder) {

        if let location = reminder.location {
            self.locationName = location.name
            self.locationLatitude = location.latitude
            self.locationLongitude = location.longitude
        } else {
            self.locationName = nil
            self.locationLatitude = 0.0
            self.locationLongitude = 0.0
        }
    }
}

extension DependentReminderEntity {
    
    static func fetchRemindersForDependent(_ dependentId: UUID, context: NSManagedObjectContext) -> [DependentReminderEntity] {
        let request: NSFetchRequest<DependentReminderEntity> = DependentReminderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "dependent.id == %@", dependentId as CVarArg)

        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching reminders for dependent: \(error)")
            return []
        }
    }
    
    
    static func fetchRemindersWithLocation(context: NSManagedObjectContext) -> [DependentReminderEntity] {
        let request: NSFetchRequest<DependentReminderEntity> = DependentReminderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "locationName != nil AND locationLatitude != nil AND locationLongitude != nil")
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching reminders with location: \(error)")
            return []
        }
    }
}

//
//  DependentEntityExtensions_Backup.swift
//  MONO
//
//  Created by Akash01 on 2025-08-24.
//

/*
import Foundation
import CoreData

// MARK: - DependentEntity Core Data Extensions
extension DependentEntity {
    
    // MARK: - Convenience Methods
    
    /// Create a new DependentEntity from a Dependent model
    static func create(from dependent: Dependent, in context: NSManagedObjectContext) -> DependentEntity {
        let entity = DependentEntity(context: context)
        entity.id = dependent.id
        entity.firstName = dependent.firstName
        entity.lastName = dependent.lastName
        entity.relationship = dependent.relationship
        entity.dateOfBirth = dependent.dateOfBirth
        entity.phoneNumber = dependent.phoneNumber
        entity.email = dependent.email
        entity.isActive = dependent.isActive
        entity.dateAdded = dependent.dateAdded
        entity.userID = dependent.userId
        return entity
    }
    
    /// Convert DependentEntity to Dependent model
    func toDependent() -> Dependent? {
        guard let id = self.id,
              let firstName = self.firstName,
              let lastName = self.lastName,
              let relationship = self.relationship,
              let dateOfBirth = self.dateOfBirth,
              let dateAdded = self.dateAdded,
              let userID = self.userID else {
            return nil
        }
        
        return Dependent(
            id: id,
            firstName: firstName,
            lastName: lastName,
            relationship: relationship,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber ?? "",
            email: email ?? "",
            isActive: isActive,
            dateAdded: dateAdded,
            userId: userID
        )
    }
    
    // MARK: - Fetch Requests
    
    /// Fetch all dependents for a specific user
    static func fetchDependents(for userID: UUID, context: NSManagedObjectContext) -> [DependentEntity] {
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@", userID as CVarArg)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \DependentEntity.firstName, ascending: true),
            NSSortDescriptor(keyPath: \DependentEntity.lastName, ascending: true)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch dependents: \(error)")
            return []
        }
    }
    
    /// Fetch all active dependents for a specific user
    static func fetchActiveDependents(for userID: UUID, context: NSManagedObjectContext) -> [DependentEntity] {
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@ AND isActive == YES", userID as CVarArg)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \DependentEntity.firstName, ascending: true),
            NSSortDescriptor(keyPath: \DependentEntity.lastName, ascending: true)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch active dependents: \(error)")
            return []
        }
    }
    
    /// Find a specific dependent by ID
    static func findDependent(by id: UUID, context: NSManagedObjectContext) -> DependentEntity? {
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to find dependent: \(error)")
            return nil
        }
    }
    
    // MARK: - Validation
    
    var isValid: Bool {
        guard let firstName = firstName, !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let lastName = lastName, !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let relationship = relationship, !relationship.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              dateOfBirth != nil,
              userID != nil else {
            return false
        }
        return true
    }
}
*/

//
//  DependentEntity+Extensions.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import Foundation
import CoreData

// MARK: - DependentEntity Extensions
extension DependentEntity {
    
    // MARK: - Computed Properties
    
    /// Full name combining first and last name
    var fullName: String {
        guard let firstName = firstName, let lastName = lastName else {
            return "Unknown"
        }
        return "\(firstName) \(lastName)"
    }
    
    /// Age calculated from date of birth
    var age: Int {
        guard let dateOfBirth = dateOfBirth else { return 0 }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
    
    /// Initials from first and last name
    var initials: String {
        guard let firstName = firstName, let lastName = lastName else {
            return "?"
        }
        return "\(firstName.prefix(1))\(lastName.prefix(1))".uppercased()
    }
    
    /// Display name for the relationship
    var relationshipDisplay: String {
        return relationship?.capitalized ?? "Unknown"
    }
    
    // MARK: - Convenience Methods
    
    /// Convert DependentEntity to Dependent struct
    func toDependent() -> Dependent? {
        guard let id = self.id,
              let firstName = self.firstName,
              let lastName = self.lastName,
              let relationship = self.relationship,
              let dateCreated = self.dateCreated,
              let userId = self.user?.id else {
            return nil
        }
        
        return Dependent(
            id: id,
            firstName: firstName,
            lastName: lastName,
            relationship: relationship,
            dateOfBirth: self.dateOfBirth ?? Date(),
            phoneNumber: self.contactNumber ?? "",
            email: self.emergencyContact ?? "",
            isActive: true,
            dateAdded: dateCreated,
            userId: userId
        )
    }
    
    /// Configure DependentEntity from Dependent struct
    func configure(from dependent: Dependent, user: UserEntity) {
        self.id = dependent.id
        self.firstName = dependent.firstName
        self.lastName = dependent.lastName
        self.relationship = dependent.relationship
        self.dateOfBirth = dependent.dateOfBirth
        self.contactNumber = dependent.phoneNumber
        self.emergencyContact = dependent.email
        self.dateCreated = dependent.dateAdded
        self.user = user
    }
}

// MARK: - Core Data Fetch Requests
extension DependentEntity {
    
    /// Fetch request for dependents of a specific user
    @nonobjc public class func fetchRequest(for user: UserEntity) -> NSFetchRequest<DependentEntity> {
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DependentEntity.dateCreated, ascending: false)]
        return request
    }
    
    /// Fetch request for dependents by user ID (safer approach)
    @nonobjc public class func fetchRequestForUser(with userId: UUID) -> NSFetchRequest<DependentEntity> {
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        
        // Use a simple predicate that doesn't traverse relationships
        request.predicate = NSPredicate(value: false) // Return empty by default
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DependentEntity.dateCreated, ascending: false)]
        
        // Note: This method is deprecated - use DependentManager.loadDependent(for:) instead
        print("Warning: fetchRequestForUser is deprecated. Use DependentManager.loadDependent(for:) instead.")
        
        return request
    }
    
    /// Fetch request for a specific dependent by ID
    @nonobjc public class func fetchRequestForDependent(with dependentId: UUID) -> NSFetchRequest<DependentEntity> {
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", dependentId as CVarArg)
        request.fetchLimit = 1
        return request
    }
}
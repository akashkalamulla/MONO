//
//  Dependent.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import Foundation
import CoreData
import SwiftUI

// MARK: - Dependent Data Model
struct Dependent: Identifiable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var relationship: String
    var dateOfBirth: Date
    var phoneNumber: String
    var email: String
    var isActive: Bool
    var dateAdded: Date
    var userId: UUID // Reference to the user who added this dependent
    
    init(firstName: String, lastName: String, relationship: String, dateOfBirth: Date, phoneNumber: String = "", email: String = "", userId: UUID) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.relationship = relationship
        self.dateOfBirth = dateOfBirth
        self.phoneNumber = phoneNumber
        self.email = email
        self.isActive = true
        self.dateAdded = Date()
        self.userId = userId
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
    
    var initials: String {
        "\(firstName.prefix(1))\(lastName.prefix(1))".uppercased()
    }
}

// MARK: - Dependent Manager
class DependentManager: ObservableObject {
    @Published var dependent: Dependent? = nil // Changed from array to single dependent
    private let coreDataStack = CoreDataStack.shared
    
    // Computed property for backward compatibility with views that expect an array
    var dependents: [Dependent] {
        if let dependent = dependent {
            return [dependent]
        } else {
            return []
        }
    }
    
    init() {
        // Clean up any orphaned dependents that might cause issues
        coreDataStack.cleanupOrphanedDependents()
        // Don't load dependent automatically - let views load them for specific users
    }
    
    // MARK: - Core Data Operations
    
    func loadDependent(for userId: UUID? = nil) {
        let context = coreDataStack.context
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        
        // If userId is provided, filter by user ID (safer approach)
        if let userId = userId {
            request.predicate = NSPredicate(format: "user.id == %@", userId as CVarArg)
        } else {
            // If no userId provided, don't load anything to avoid errors
            DispatchQueue.main.async {
                self.dependent = nil
            }
            return
        }
        
        // Add sort descriptors and limit to 1
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DependentEntity.dateCreated, ascending: false)]
        request.fetchLimit = 1 // Only get one dependent since it's now one-to-one
        
        do {
            let dependentEntities = try context.fetch(request)
            let convertedDependent = dependentEntities.first?.toDependent()
            
            DispatchQueue.main.async {
                self.dependent = convertedDependent
            }
        } catch {
            print("Error loading dependent: \(error)")
            DispatchQueue.main.async {
                self.dependent = nil
            }
        }
    }
    
    func addDependent(_ dependent: Dependent) -> Bool {
        let context = coreDataStack.context
        
        // First, find the user
        let userRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        userRequest.predicate = NSPredicate(format: "id == %@", dependent.userId as CVarArg)
        
        do {
            let users = try context.fetch(userRequest)
            guard let user = users.first else {
                print("User not found")
                return false
            }
            
            // Check if user already has a dependent (one-to-one relationship)
            if user.dependent != nil {
                print("User already has a dependent. Please update or delete the existing one first.")
                return false
            }
            
            // Create new dependent entity
            let dependentEntity = DependentEntity(context: context)
            dependentEntity.id = dependent.id
            dependentEntity.firstName = dependent.firstName
            dependentEntity.lastName = dependent.lastName
            dependentEntity.relationship = dependent.relationship
            dependentEntity.dateOfBirth = dependent.dateOfBirth
            dependentEntity.contactNumber = dependent.phoneNumber
            dependentEntity.emergencyContact = dependent.email
            dependentEntity.dateCreated = dependent.dateAdded
            dependentEntity.user = user
            
            try context.save()
            
            // Reload dependent
            loadDependent(for: dependent.userId)
            return true
            
        } catch {
            print("Error adding dependent: \(error)")
            return false
        }
    }
    
    func updateDependent(_ dependent: Dependent) -> Bool {
        let context = coreDataStack.context
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", dependent.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            guard let entity = entities.first else { return false }
            
            entity.firstName = dependent.firstName
            entity.lastName = dependent.lastName
            entity.relationship = dependent.relationship
            entity.dateOfBirth = dependent.dateOfBirth
            entity.contactNumber = dependent.phoneNumber
            entity.emergencyContact = dependent.email
            
            try context.save()
            
            // Reload dependent
            loadDependent(for: dependent.userId)
            return true
            
        } catch {
            print("Error updating dependent: \(error)")
            return false
        }
    }
    
    func deleteDependent(_ dependent: Dependent) -> Bool {
        let context = coreDataStack.context
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", dependent.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            guard let entity = entities.first else { return false }
            
            context.delete(entity)
            try context.save()
            
            // Reload dependent
            loadDependent(for: dependent.userId)
            return true
            
        } catch {
            print("Error deleting dependent: \(error)")
            return false
        }
    }
    
    func toggleDependentStatus(_ dependent: Dependent) -> Bool {
        var updatedDependent = dependent
        updatedDependent.isActive.toggle()
        return updateDependent(updatedDependent)
    }
}

// MARK: - Helper Extensions
extension Dependent {
    init(id: UUID, firstName: String, lastName: String, relationship: String, dateOfBirth: Date, phoneNumber: String, email: String, isActive: Bool, dateAdded: Date, userId: UUID) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.relationship = relationship
        self.dateOfBirth = dateOfBirth
        self.phoneNumber = phoneNumber
        self.email = email
        self.isActive = isActive
        self.dateAdded = dateAdded
        self.userId = userId
    }
}

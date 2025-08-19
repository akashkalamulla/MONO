//
//  UserEntity+Extensions.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import Foundation
import CoreData

extension UserEntity {
    
    // Convenience initializer
    convenience init(context: NSManagedObjectContext, firstName: String, lastName: String, email: String, phoneNumber: String? = nil) {
        self.init(context: context)
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.dateCreated = Date()
        self.isLoggedIn = false
    }
    
    // Computed properties with safe unwrapping
    var safeFirstName: String {
        return firstName ?? ""
    }
    
    var safeLastName: String {
        return lastName ?? ""
    }
    
    var safeEmail: String {
        return email ?? ""
    }
    
    var safePhoneNumber: String {
        return phoneNumber ?? ""
    }
    
    var safeId: UUID {
        return id ?? UUID()
    }
    
    var safeDateCreated: Date {
        return dateCreated ?? Date()
    }
    
    // Full name computed property
    var fullName: String {
        return "\(safeFirstName) \(safeLastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Validation methods
    var isValidEmail: Bool {
        return safeEmail.contains("@") && !safeEmail.isEmpty
    }
    
    var hasValidName: Bool {
        return !safeFirstName.isEmpty && !safeLastName.isEmpty
    }
    
    // Static fetch requests - Core Data auto-generates fetchRequest(), so we use custom names
    static func createFetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }
    
    static func fetchCurrentUser(context: NSManagedObjectContext) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isLoggedIn == %@", NSNumber(value: true))
        request.fetchLimit = 1
        
        do {
            let users = try context.fetch(request)
            return users.first
        } catch {
            print("Error fetching current user: \(error)")
            return nil
        }
    }
    
    static func fetchUser(byEmail email: String, context: NSManagedObjectContext) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        request.fetchLimit = 1
        
        do {
            let users = try context.fetch(request)
            return users.first
        } catch {
            print("Error fetching user by email: \(error)")
            return nil
        }
    }
    
    static func userExists(email: String, context: NSManagedObjectContext) -> Bool {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Error checking if user exists: \(error)")
            return false
        }
    }
}

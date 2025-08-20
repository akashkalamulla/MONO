//
//  CoreDataStack.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import CoreData
import Foundation

class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MONO")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Data Cleanup
    
    func cleanupOrphanedDependents() {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user == nil")
        
        do {
            let orphanedDependents = try context.fetch(request)
            for dependent in orphanedDependents {
                context.delete(dependent)
            }
            if !orphanedDependents.isEmpty {
                save()
                print("Cleaned up \(orphanedDependents.count) orphaned dependents")
            }
        } catch {
            print("Error cleaning up orphaned dependents: \(error)")
        }
    }
    
    // MARK: - User Management
    
    func createUser(firstName: String, lastName: String, email: String, phoneNumber: String?) -> UserEntity {
        let user = UserEntity(context: context)
        user.id = UUID()
        user.firstName = firstName
        user.lastName = lastName
        user.email = email
        user.phoneNumber = phoneNumber
        user.dateCreated = Date()
        user.isLoggedIn = false
        
        save()
        return user
    }
    
    func fetchUser(by email: String) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        request.fetchLimit = 1
        
        do {
            let users = try context.fetch(request)
            return users.first
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }
    
    func fetchCurrentUser() -> UserEntity? {
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
    
    func loginUser(_ user: UserEntity) {
        // First, logout all other users
        logoutAllUsers()
        
        // Then login this user
        user.isLoggedIn = true
        save()
    }
    
    func logoutAllUsers() {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isLoggedIn == %@", NSNumber(value: true))
        
        do {
            let users = try context.fetch(request)
            for user in users {
                user.isLoggedIn = false
            }
            save()
        } catch {
            print("Error logging out users: \(error)")
        }
    }
    
    func deleteUser(_ user: UserEntity) {
        context.delete(user)
        save()
    }
    
    func userExists(email: String) -> Bool {
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
    
    // MARK: - Income Management
    
    func addIncome(
        source: String,
        category: String,
        categoryIcon: String,
        categoryColor: String,
        amount: Double,
        dateReceived: Date,
        description: String?,
        notes: String?,
        isRecurring: Bool,
        recurringFrequency: String?,
        user: UserEntity
    ) -> Bool {
        
        let income = NSEntityDescription.insertNewObject(forEntityName: "IncomeEntity", into: context) as! NSManagedObject
        income.setValue(UUID(), forKey: "id")
        income.setValue(source, forKey: "source")
        income.setValue(category, forKey: "category")
        income.setValue(categoryIcon, forKey: "categoryIcon")
        income.setValue(categoryColor, forKey: "categoryColor")
        income.setValue(amount, forKey: "amount")
        income.setValue(dateReceived, forKey: "dateReceived")
        income.setValue(Date(), forKey: "dateCreated")
        income.setValue(description, forKey: "incomeDescription")
        income.setValue(notes, forKey: "notes")
        income.setValue(isRecurring, forKey: "isRecurring")
        income.setValue(recurringFrequency, forKey: "recurringFrequency")
        income.setValue(user, forKey: "user")
        
        do {
            try context.save()
            return true
        } catch {
            print("Error saving income: \(error)")
            return false
        }
    }
    
    func fetchIncomes(for user: UserEntity) -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "IncomeEntity")
        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [NSSortDescriptor(key: "dateReceived", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching incomes: \(error)")
            return []
        }
    }
}

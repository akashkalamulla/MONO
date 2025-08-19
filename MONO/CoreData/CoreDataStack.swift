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
}

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

        logoutAllUsers()
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
    
    
    func createIncome(
        amount: Double,
        category: IncomeCategory,
        description: String?,
        date: Date,
        isRecurring: Bool,
        recurrenceFrequency: String?,
        user: UserEntity
    ) -> IncomeEntity {
        let income = IncomeEntity(context: context)
        income.id = UUID()
        income.amount = amount
        income.categoryId = category.id
        income.categoryName = category.name
        income.categoryIcon = category.icon
        income.categoryColor = category.color
        income.incomeDescription = description
        income.date = date
        income.isRecurring = isRecurring
        income.recurrenceFrequency = recurrenceFrequency
        income.createdAt = Date()
        income.updatedAt = Date()
        income.user = user
        
        save()
        return income
    }
    
    func fetchIncomes(for user: UserEntity) -> [IncomeEntity] {
        let request: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \IncomeEntity.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching incomes: \(error)")
            return []
        }
    }
    
    func deleteIncome(_ income: IncomeEntity) {
        context.delete(income)
        save()
    }
    
    func updateIncome(_ income: IncomeEntity) {
        income.updatedAt = Date()
        save()
    }
    
    func fetchExpenses(for dependentID: UUID) -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "ExpenseEntity")
        request.predicate = NSPredicate(format: "dependentID == %@", dependentID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching expenses for dependent: \(error)")
            return []
        }
    }
    
    func createExpense(
        amount: Double,
        category: ExpenseCategory,
        description: String?,
        date: Date,
        isRecurring: Bool,
        recurrenceFrequency: String?,
        hasPaymentReminder: Bool,
        reminderDate: Date?,
        reminderDayOfMonth: Int32?,
        reminderFrequency: String?,
   
    locationName: String? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil,
        user: UserEntity,
        dependentID: UUID? = nil
    ) -> ExpenseEntity {
        let expense = ExpenseEntity(context: context)
        expense.id = UUID()
        expense.amount = amount
        expense.category = category.name
        expense.expenseDescription = description
        expense.date = date
        expense.isRecurring = isRecurring
        expense.recurringFrequency = recurrenceFrequency
        expense.isPaymentReminder = hasPaymentReminder
        expense.reminderDate = reminderDate
        expense.reminderDayOfMonth = Int16(reminderDayOfMonth ?? 0)
        expense.reminderFrequency = reminderFrequency
        expense.isReminderActive = hasPaymentReminder
        expense.lastReminderSent = nil
        expense.userID = user.id ?? UUID()
        expense.setValue(dependentID, forKey: "dependentID")
        if let locationName = locationName {
            expense.setValue(locationName, forKey: "locationName")
        }
        if let lat = latitude {
            expense.setValue(lat, forKey: "latitude")
        }
        if let lon = longitude {
            expense.setValue(lon, forKey: "longitude")
        }
        expense.createdAt = Date()
        expense.updatedAt = Date()
        expense.user = user
        
        
        if let dependentID = dependentID {
            do {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DependentEntity")
                fetchRequest.predicate = NSPredicate(format: "id == %@", dependentID as CVarArg)
                fetchRequest.fetchLimit = 1
                
                let results = try context.fetch(fetchRequest)
                if let dependentEntity = results.first {
                    expense.setValue(dependentEntity, forKey: "dependent")
                }
            } catch {
                print("Error fetching dependent: \(error)")
            }
        }
        
        save()
        return expense
    }
    
    func fetchExpenses(for user: UserEntity) -> [ExpenseEntity] {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching expenses: \(error)")
            return []
        }
    }
    
    func deleteExpense(_ expense: ExpenseEntity) {
        context.delete(expense)
        save()
    }
    
    func updateExpense(_ expense: ExpenseEntity) {
        expense.updatedAt = Date()
        save()
    }
    
    
    func fetchIncomes(for user: UserEntity, from startDate: Date, to endDate: Date) -> [IncomeEntity] {
        let request: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@ AND date >= %@ AND date <= %@", user, startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \IncomeEntity.date, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching incomes for date range: \(error)")
            return []
        }
    }
    
    func fetchExpenses(for user: UserEntity, from startDate: Date, to endDate: Date) -> [ExpenseEntity] {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@ AND date >= %@ AND date <= %@", user, startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching expenses for date range: \(error)")
            return []
        }
    }
}

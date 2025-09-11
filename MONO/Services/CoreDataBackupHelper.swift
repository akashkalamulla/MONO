import Foundation
import CoreData

class CoreDataBackupHelper {
    static let shared = CoreDataBackupHelper()
    
    private init() {}
    
    func fetchUserForBackup(userEmail: String) -> UserBackupRecord? {
        guard let userEntity = CoreDataStack.shared.fetchUser(by: userEmail) else {
            return nil
        }
        
        return UserBackupRecord(
            id: userEntity.safeId.uuidString,
            firstName: userEntity.safeFirstName,
            lastName: userEntity.safeLastName,
            email: userEntity.safeEmail,
            phoneNumber: userEntity.safePhoneNumber.isEmpty ? nil : userEntity.safePhoneNumber,
            dateCreated: userEntity.safeDateCreated,
            isLoggedIn: userEntity.isLoggedIn
        )
    }
    
    func fetchIncomesForBackup(userEmail: String) -> [IncomeBackupRecord] {
        guard let userEntity = CoreDataStack.shared.fetchUser(by: userEmail) else {
            return []
        }
        
        let incomes = CoreDataStack.shared.fetchIncomes(for: userEntity)
        
        return incomes.map { income in
            IncomeBackupRecord(
                id: (income.id ?? UUID()).uuidString,
                amount: income.amount,
                categoryId: income.categoryId ?? "",
                categoryName: income.categoryName ?? "",
                categoryIcon: income.categoryIcon ?? "",
                categoryColor: income.categoryColor ?? "",
                incomeDescription: income.incomeDescription,
                date: income.date ?? Date(),
                isRecurring: income.isRecurring,
                recurrenceFrequency: income.recurrenceFrequency,
                createdAt: income.createdAt ?? Date(),
                updatedAt: income.updatedAt ?? Date()
            )
        }
    }
    
    func fetchExpensesForBackup(userEmail: String) -> [ExpenseBackupRecord] {
        guard let userEntity = CoreDataStack.shared.fetchUser(by: userEmail) else {
            return []
        }
        
        let context = CoreDataStack.shared.context
        
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", userEntity)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)]
        
        do {
            let expenses = try context.fetch(request)
            
            return expenses.map { expense in
                ExpenseBackupRecord(
                    id: (expense.id ?? UUID()).uuidString,
                    amount: expense.amount,
                    category: expense.category ?? "",
                    expenseDescription: expense.expenseDescription,
                    date: expense.date ?? Date(),
                    isRecurring: expense.isRecurring,
                    recurringFrequency: expense.recurringFrequency,
                    isPaymentReminder: expense.isPaymentReminder,
                    isReminderActive: expense.isReminderActive,
                    reminderDate: expense.reminderDate,
                    reminderFrequency: expense.reminderFrequency,
                    reminderDayOfMonth: expense.reminderDayOfMonth,
                    lastReminderSent: expense.lastReminderSent,
                    locationName: expense.locationName,
                    latitude: expense.latitude == 0 ? nil : expense.latitude,
                    longitude: expense.longitude == 0 ? nil : expense.longitude,
                    dependentID: expense.dependentID?.uuidString,
                    userID: (expense.userID ?? UUID()).uuidString,
                    createdAt: expense.createdAt ?? Date(),
                    updatedAt: expense.updatedAt ?? Date()
                )
            }
        } catch {
            print("Error fetching expenses for backup: \(error)")
            return []
        }
    }
    
    func fetchDependentsForBackup(userEmail: String) -> [DependentBackupRecord] {
        guard let userEntity = CoreDataStack.shared.fetchUser(by: userEmail) else {
            return []
        }
        
        let context = CoreDataStack.shared.context
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@", userEntity.safeId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DependentEntity.firstName, ascending: true)]
        
        do {
            let dependents = try context.fetch(request)
            
            return dependents.map { dependent in
                DependentBackupRecord(
                    id: (dependent.id ?? UUID()).uuidString,
                    firstName: dependent.firstName ?? "",
                    lastName: dependent.lastName ?? "",
                    relationship: dependent.relationship ?? "",
                    dateOfBirth: dependent.dateOfBirth ?? Date(),
                    phoneNumber: dependent.phoneNumber ?? "",
                    email: dependent.email ?? "",
                    isActive: dependent.isActive,
                    dataAdded: dependent.dataAdded ?? Date(),
                    userID: (dependent.userID ?? UUID()).uuidString
                )
            }
        } catch {
            print("Error fetching dependents for backup: \(error)")
            return []
        }
    }
}

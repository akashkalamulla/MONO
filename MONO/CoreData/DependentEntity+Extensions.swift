import Foundation
import CoreData

extension DependentEntity {
    
    convenience init(context: NSManagedObjectContext, from dependent: Dependent, userId: UUID) {
        self.init(context: context)
        self.id = dependent.id
        self.firstName = dependent.firstName
        self.lastName = dependent.lastName
        self.relationship = dependent.relationship
        self.dateOfBirth = dependent.dateOfBirth
        self.phoneNumber = dependent.phoneNumber
        self.email = dependent.email
        self.isActive = dependent.isActive
        self.dateAdded = dependent.dateAdded
        self.userId = userId
    }
    
    func toDependent() -> Dependent {
        return Dependent(
            id: self.id ?? UUID(),
            firstName: self.firstName ?? "",
            lastName: self.lastName ?? "",
            relationship: self.relationship ?? "",
            dateOfBirth: self.dateOfBirth ?? Date(),
            phoneNumber: self.phoneNumber ?? "",
            email: self.email ?? "",
            isActive: self.isActive,
            dateAdded: self.dateAdded ?? Date()
        )
    }
    
    func update(from dependent: Dependent) {
        self.firstName = dependent.firstName
        self.lastName = dependent.lastName
        self.relationship = dependent.relationship
        self.dateOfBirth = dependent.dateOfBirth
        self.phoneNumber = dependent.phoneNumber
        self.email = dependent.email
        self.isActive = dependent.isActive
    }
    
    var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
    }
    
    var age: Int {
        guard let dateOfBirth = dateOfBirth else { return 0 }
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        return ageComponents.year ?? 0
    }
}

extension DependentEntity {
    
    static func fetchDependentsForUser(_ userId: UUID, in context: NSManagedObjectContext) -> [DependentEntity] {
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching dependents: \(error)")
            return []
        }
    }
    
    static func fetchActiveDependentsForUser(_ userId: UUID, in context: NSManagedObjectContext) -> [DependentEntity] {
        let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@ AND isActive == true", userId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching active dependents: \(error)")
            return []
        }
    }
}

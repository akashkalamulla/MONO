import Foundation
import CoreData

// Dependent model represents a family member or person you're responsible for
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
    
    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    var age: Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        return ageComponents.year ?? 0
    }
    
    var initials: String {
        "\(firstName.prefix(1))\(lastName.prefix(1))".uppercased()
    }
    
    init(id: UUID = UUID(), firstName: String, lastName: String, relationship: String, dateOfBirth: Date, phoneNumber: String = "", email: String = "", isActive: Bool = true, dateAdded: Date = Date()) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.relationship = relationship
        self.dateOfBirth = dateOfBirth
        self.phoneNumber = phoneNumber
        self.email = email
        self.isActive = isActive
        self.dateAdded = dateAdded
    }
}

// Manages all dependent-related operations and data
@MainActor
class DependentManager: ObservableObject {
    @Published var dependents: [Dependent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let coreDataStack: CoreDataStack
    private var context: NSManagedObjectContext {
        return coreDataStack.context
    }
    
    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }
    
    func loadDependents(for userId: UUID) {
        isLoading = true
        errorMessage = nil
        
        do {
            let dependentEntities = DependentEntity.fetchDependentsForUser(userId, in: context)
            self.dependents = dependentEntities.map { $0.toDependent() }
            isLoading = false
        } catch {
            errorMessage = "Failed to load dependents: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func addDependent(_ dependent: Dependent, for userId: UUID) {
        do {
            let _ = DependentEntity(context: context, from: dependent, userId: userId)
            try context.save()
            loadDependents(for: userId)
        } catch {
            errorMessage = "Failed to add dependent: \(error.localizedDescription)"
        }
    }
    
    func updateDependent(_ dependent: Dependent, for userId: UUID) {
        do {
            let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", dependent.id as CVarArg)
            
            if let dependentEntity = try context.fetch(request).first {
                dependentEntity.update(from: dependent)
                try context.save()
                loadDependents(for: userId)
            }
        } catch {
            errorMessage = "Failed to update dependent: \(error.localizedDescription)"
        }
    }
    
    func deleteDependent(_ dependent: Dependent, for userId: UUID) {
        do {
            let request: NSFetchRequest<DependentEntity> = DependentEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", dependent.id as CVarArg)
            
            if let dependentEntity = try context.fetch(request).first {
                context.delete(dependentEntity)
                try context.save()
                loadDependents(for: userId)
            }
        } catch {
            errorMessage = "Failed to delete dependent: \(error.localizedDescription)"
        }
    }
    
    func toggleDependentStatus(_ dependent: Dependent, for userId: UUID) {
        var updatedDependent = dependent
        updatedDependent.isActive.toggle()
        updateDependent(updatedDependent, for: userId)
    }
    
    var activeDependents: [Dependent] {
        return dependents.filter { $0.isActive }
    }
    
    var inactiveDependents: [Dependent] {
        return dependents.filter { !$0.isActive }
    }
    
    var totalDependents: Int {
        return dependents.count
    }
    
    var activeDependentsCount: Int {
        return activeDependents.count
    }
    
    func searchDependents(_ searchText: String, for userId: UUID) -> [Dependent] {
        if searchText.isEmpty {
            return dependents
        }
        
        return dependents.filter { dependent in
            dependent.fullName.localizedCaseInsensitiveContains(searchText) ||
            dependent.relationship.localizedCaseInsensitiveContains(searchText) ||
            dependent.email.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func getDependentsByRelationship(_ relationship: String, for userId: UUID) -> [Dependent] {
        return dependents.filter { $0.relationship == relationship }
    }
}

//
//  Dependent.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import Foundation
import CoreData

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
    @Published var dependents: [Dependent] = []
    private let coreDataStack = CoreDataStack.shared
    
    init() {
        loadDependents()
    }
    
    // MARK: - Core Data Operations (Temporary in-memory implementation)
    
    func loadDependents(for userId: UUID? = nil) {
        // Temporary: Load from in-memory storage
        // TODO: Implement Core Data loading once entity is properly generated
        DispatchQueue.main.async {
            // For now, keep existing in-memory dependents or create sample data
            print("Loading dependents for user: \(userId?.uuidString ?? "all")")
        }
    }
    
    func addDependent(_ dependent: Dependent) -> Bool {
        // Temporary: Add to in-memory storage
        DispatchQueue.main.async {
            self.dependents.append(dependent)
        }
        return true
    }
    
    func updateDependent(_ dependent: Dependent) -> Bool {
        // Temporary: Update in-memory storage
        DispatchQueue.main.async {
            if let index = self.dependents.firstIndex(where: { $0.id == dependent.id }) {
                self.dependents[index] = dependent
            }
        }
        return true
    }
    
    func deleteDependent(_ dependent: Dependent) -> Bool {
        // Temporary: Delete from in-memory storage
        DispatchQueue.main.async {
            self.dependents.removeAll { $0.id == dependent.id }
        }
        return true
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

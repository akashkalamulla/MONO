//
//  Dependent.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import Foundation
import CoreData


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
    var userId: UUID
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


class DependentManager: ObservableObject {
    @Published var dependents: [Dependent] = []
    private let userDefaults = UserDefaults.standard
    private let dependentsKey = "SavedDependents"
    
    init() {
        loadDependents()
    }
    
    
    func loadDependents(for userId: UUID? = nil) {
        guard let userId = userId else {
           
            loadAllDependents()
            return
        }
        
        if let data = userDefaults.data(forKey: dependentsKey),
           let allDependents = try? JSONDecoder().decode([Dependent].self, from: data) {
            let userDependents = allDependents.filter { $0.userId == userId }
            
            DispatchQueue.main.async {
                self.dependents = userDependents
                print("Loaded \(userDependents.count) dependents for user: \(userId)")
            }
        } else {
            DispatchQueue.main.async {
                self.dependents = []
                print("No dependents found for user: \(userId)")
            }
        }
    }
    
    private func loadAllDependents() {
        if let data = userDefaults.data(forKey: dependentsKey),
           let allDependents = try? JSONDecoder().decode([Dependent].self, from: data) {
            DispatchQueue.main.async {
                self.dependents = allDependents
                print("Loaded \(allDependents.count) total dependents")
            }
        } else {
            DispatchQueue.main.async {
                self.dependents = []
                print("No dependents found")
            }
        }
    }
    
    func addDependent(_ dependent: Dependent) -> Bool {
        do {
        
            var allDependents: [Dependent] = []
            if let data = userDefaults.data(forKey: dependentsKey),
               let existingDependents = try? JSONDecoder().decode([Dependent].self, from: data) {
                allDependents = existingDependents
            }
            
          
            allDependents.append(dependent)
            
          
            let data = try JSONEncoder().encode(allDependents)
            userDefaults.set(data, forKey: dependentsKey)
            userDefaults.synchronize()
            
            DispatchQueue.main.async {
                self.dependents.append(dependent)
            }
            
            print("Successfully added dependent: \(dependent.fullName)")
            return true
        } catch {
            print("Failed to add dependent: \(error)")
            return false
        }
    }
    
    func updateDependent(_ dependent: Dependent) -> Bool {
        do {
          
            guard let data = userDefaults.data(forKey: dependentsKey),
                  var allDependents = try? JSONDecoder().decode([Dependent].self, from: data) else {
                return false
            }
            
         
            if let index = allDependents.firstIndex(where: { $0.id == dependent.id }) {
                allDependents[index] = dependent
                
                let updatedData = try JSONEncoder().encode(allDependents)
                userDefaults.set(updatedData, forKey: dependentsKey)
                userDefaults.synchronize()
                
                DispatchQueue.main.async {
                    if let localIndex = self.dependents.firstIndex(where: { $0.id == dependent.id }) {
                        self.dependents[localIndex] = dependent
                    }
                }
                
                print("Successfully updated dependent: \(dependent.fullName)")
                return true
            }
            return false
        } catch {
            print("Failed to update dependent: \(error)")
            return false
        }
    }
    
    func deleteDependent(_ dependent: Dependent) -> Bool {
        do {
            guard let data = userDefaults.data(forKey: dependentsKey),
                  var allDependents = try? JSONDecoder().decode([Dependent].self, from: data) else {
                return false
            }
            allDependents.removeAll { $0.id == dependent.id }
            let updatedData = try JSONEncoder().encode(allDependents)
            userDefaults.set(updatedData, forKey: dependentsKey)
            userDefaults.synchronize()
            
            DispatchQueue.main.async {
                self.dependents.removeAll { $0.id == dependent.id }
            }
            
            print("Successfully deleted dependent: \(dependent.fullName)")
            return true
        } catch {
            print("Failed to delete dependent: \(error)")
            return false
        }
    }
    
    func toggleDependentStatus(_ dependent: Dependent) -> Bool {
        var updatedDependent = dependent
        updatedDependent.isActive.toggle()
        return updateDependent(updatedDependent)
    }
    

    
    func getDependents(for userId: UUID) -> [Dependent] {
        if let data = userDefaults.data(forKey: dependentsKey),
           let allDependents = try? JSONDecoder().decode([Dependent].self, from: data) {
            return allDependents.filter { $0.userId == userId }
        }
        return []
    }
    
    func clearAllDependents() {
        userDefaults.removeObject(forKey: dependentsKey)
        userDefaults.synchronize()
        
        DispatchQueue.main.async {
            self.dependents = []
        }
        print("Cleared all dependents")
    }
}


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

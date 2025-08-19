//
//  User.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import Foundation
import CoreData

// MARK: - User Data Transfer Object
struct User: Identifiable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String?
    var dateCreated: Date
    var isLoggedIn: Bool
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    init(from userEntity: UserEntity) {
        self.id = userEntity.id ?? UUID()
        self.firstName = userEntity.firstName ?? ""
        self.lastName = userEntity.lastName ?? ""
        self.email = userEntity.email ?? ""
        self.phoneNumber = userEntity.phoneNumber
        self.dateCreated = userEntity.dateCreated ?? Date()
        self.isLoggedIn = userEntity.isLoggedIn
    }
    
    init(firstName: String, lastName: String, email: String, phoneNumber: String? = nil) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.dateCreated = Date()
        self.isLoggedIn = false
    }
}

// MARK: - Authentication Manager with Core Data
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let coreDataStack = CoreDataStack.shared
    
    init() {
        checkForLoggedInUser()
    }
    
    // Check if there's a logged-in user when the app starts
    private func checkForLoggedInUser() {
        if let userEntity = coreDataStack.fetchCurrentUser() {
            self.currentUser = User(from: userEntity)
            self.isAuthenticated = true
        }
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay for demonstration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.performLogin(email: email, password: password)
        }
    }
    
    private func performLogin(email: String, password: String) {
        // Basic validation
        guard email.contains("@"), password.count >= 6 else {
            self.errorMessage = "Invalid email or password"
            self.isLoading = false
            return
        }
        
        // Check if user exists in Core Data
        if let userEntity = coreDataStack.fetchUser(by: email) {
            // In a real app, you would verify the password hash here
            // For now, we'll assume the login is successful if user exists
            
            // Login the user
            coreDataStack.loginUser(userEntity)
            
            // Update UI state
            self.currentUser = User(from: userEntity)
            self.isAuthenticated = true
            self.isLoading = false
            
        } else {
            // User doesn't exist - create a demo user for testing
            // In a real app, this would be an error
            let newUserEntity = coreDataStack.createUser(
                firstName: "Demo",
                lastName: "User",
                email: email,
                phoneNumber: nil
            )
            
            coreDataStack.loginUser(newUserEntity)
            
            self.currentUser = User(from: newUserEntity)
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    func register(firstName: String, lastName: String, email: String, phoneNumber: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.performRegistration(
                firstName: firstName,
                lastName: lastName,
                email: email,
                phoneNumber: phoneNumber,
                password: password
            )
        }
    }
    
    private func performRegistration(firstName: String, lastName: String, email: String, phoneNumber: String, password: String) {
        // Basic validation
        guard email.contains("@"),
              password.count >= 6,
              !firstName.isEmpty,
              !lastName.isEmpty else {
            self.errorMessage = "Please check all fields and try again"
            self.isLoading = false
            return
        }
        
        // Check if user already exists
        if coreDataStack.userExists(email: email) {
            self.errorMessage = "An account with this email already exists"
            self.isLoading = false
            return
        }
        
        // Create new user in Core Data
        let newUserEntity = coreDataStack.createUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber
        )
        
        // In a real app, you would:
        // 1. Hash the password and store it
        // 2. Send verification email
        // 3. Create user account on server
        
        // Login the new user
        coreDataStack.loginUser(newUserEntity)
        
        // Update UI state
        self.currentUser = User(from: newUserEntity)
        self.isAuthenticated = true
        self.isLoading = false
    }
    
    func logout() {
        // Logout user in Core Data
        coreDataStack.logoutAllUsers()
        
        // Update UI state
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
    }
    
    func deleteAccount() {
        guard let currentUser = currentUser else { return }
        
        // Find and delete user from Core Data
        if let userEntity = coreDataStack.fetchUser(by: currentUser.email) {
            coreDataStack.deleteUser(userEntity)
        }
        
        // Update UI state
        self.currentUser = nil
        self.isAuthenticated = false
        self.errorMessage = nil
    }
    
    // MARK: - User Profile Updates
    
    func updateUserProfile(firstName: String, lastName: String, phoneNumber: String?) {
        guard let currentUser = currentUser else { return }
        
        // Find user in Core Data and update
        if let userEntity = coreDataStack.fetchUser(by: currentUser.email) {
            userEntity.firstName = firstName
            userEntity.lastName = lastName
            userEntity.phoneNumber = phoneNumber
            
            coreDataStack.save()
            
            // Update current user state
            self.currentUser = User(from: userEntity)
        }
    }
}

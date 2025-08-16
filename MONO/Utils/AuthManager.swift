//
//  AuthManager.swift
//  MONO
//
//  Created by Akash01 on 2025-08-16.
//

import Foundation
import CoreData
import SwiftUI

class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        checkLoginStatus()
    }
    
    // MARK: - Registration
    func registerUser(username: String, email: String, password: String, name: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        // Check if user already exists (by email or username)
        if userExists(email: email) {
            errorMessage = "User with this email already exists"
            isLoading = false
            completion(false)
            return
        }
        
        if usernameExists(username: username) {
            errorMessage = "Username is already taken"
            isLoading = false
            completion(false)
            return
        }
        
        // Create new user
        let newUser = User(context: viewContext)
        newUser.username = username
        newUser.email = email
        newUser.password = password // In production, hash this password
        newUser.name = name
        newUser.createdAt = Date()
        
        do {
            try viewContext.save()
            isLoading = false
            completion(true)
        } catch {
            errorMessage = "Failed to register user: \(error.localizedDescription)"
            isLoading = false
            completion(false)
        }
    }
    
    // MARK: - Login
    func loginUser(emailOrUsername: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        // Allow login with either email or username
        request.predicate = NSPredicate(format: "(email == %@ OR username == %@) AND password == %@", emailOrUsername, emailOrUsername, password)
        
        do {
            let users = try viewContext.fetch(request)
            print("Found \(users.count) users matching credentials")
            if let user = users.first {
                print("Login successful for user: \(user.username ?? "unknown")")
                currentUser = user
                isLoggedIn = true
                saveLoginStatus(userId: user.objectID.uriRepresentation().absoluteString)
                isLoading = false
                completion(true)
            } else {
                print("No matching users found")
                errorMessage = "Invalid email/username or password"
                isLoading = false
                completion(false)
            }
        } catch {
            print("Login error: \(error)")
            errorMessage = "Login failed: \(error.localizedDescription)"
            isLoading = false
            completion(false)
        }
    }
    
    // MARK: - Logout
    func logout() {
        currentUser = nil
        isLoggedIn = false
        clearLoginStatus()
    }
    
    // MARK: - Helper Methods
    
    // Test function - you can call this to create a test user
    func createTestUser() {
        let testUser = User(context: viewContext)
        testUser.username = "testuser"
        testUser.name = "Test User"
        testUser.email = "test@test.com"
        testUser.password = "123456"
        testUser.createdAt = Date()
        
        do {
            try viewContext.save()
            print("Test user created successfully")
        } catch {
            print("Failed to create test user: \(error)")
        }
    }
    
    private func userExists(email: String) -> Bool {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try viewContext.fetch(request)
            return !users.isEmpty
        } catch {
            return false
        }
    }
    
    private func usernameExists(username: String) -> Bool {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", username)
        
        do {
            let users = try viewContext.fetch(request)
            return !users.isEmpty
        } catch {
            return false
        }
    }
    
    private func saveLoginStatus(userId: String) {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(userId, forKey: "currentUserId")
    }
    
    private func clearLoginStatus() {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "currentUserId")
    }
    
    private func checkLoginStatus() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        guard isLoggedIn,
              let userIdString = UserDefaults.standard.string(forKey: "currentUserId"),
              let userIdURL = URL(string: userIdString),
              let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: userIdURL) else {
            return
        }
        
        do {
            let user = try viewContext.existingObject(with: objectID) as? User
            currentUser = user
            self.isLoggedIn = true
        } catch {
            clearLoginStatus()
        }
    }
}

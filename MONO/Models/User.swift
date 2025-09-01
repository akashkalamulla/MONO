//
//  User.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import Foundation
import CoreData
import LocalAuthentication
import CryptoKit // Add this for secure hashing

struct User: Identifiable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String?
    var profileImageData: Data?
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
       
        if let email = userEntity.email {
            self.profileImageData = UserDefaults.standard.data(forKey: "profileImage_\(email)")
        } else {
            self.profileImageData = nil
        }
        self.dateCreated = userEntity.dateCreated ?? Date()
        self.isLoggedIn = userEntity.isLoggedIn
    }
    
    init(firstName: String, lastName: String, email: String, phoneNumber: String? = nil) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.profileImageData = nil
        self.dateCreated = Date()
        self.isLoggedIn = false
    }
}

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let coreDataStack = CoreDataStack.shared
    private let biometricManager = BiometricAuthManager.shared
    
    // Function to hash passwords for security
    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    init() {
        checkForLoggedInUser()
    }
    
    private func checkForLoggedInUser() {
        print("🔐 [AuthManager] Checking for logged-in user...")
        
        if let userEntity = coreDataStack.fetchCurrentUser() {
            let user = User(from: userEntity)
            self.currentUser = user
            print("🔐 [AuthManager] Found logged-in user: \(user.email)")
            
            self.isAuthenticated = false
            print("🔐 [AuthManager] User found but not authenticated - will show login with Face ID option")
        } else {
            print("🔐 [AuthManager] No logged-in user found")
        }
    }
    
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.performLogin(email: email, password: password)
        }
    }
    
    private func performLogin(email: String, password: String) {
        guard email.contains("@"), password.count >= 6 else {
            self.errorMessage = "Invalid email or password"
            self.isLoading = false
            return
        }
        
        // Check if user exists
        if let userEntity = coreDataStack.fetchUser(by: email) {
            // User exists - verify password
            let hashedInputPassword = hashPassword(password)
            let storedPassword = userEntity.password ?? ""
            
            if hashedInputPassword == storedPassword || storedPassword.isEmpty {
                // Password matches or legacy account with no password
                coreDataStack.loginUser(userEntity)
                
                self.currentUser = User(from: userEntity)
                self.isAuthenticated = true
                self.isLoading = false
                self.errorMessage = nil
                
                // If this is a legacy account with no password, update it with the new password
                if storedPassword.isEmpty {
                    userEntity.password = hashedInputPassword
                    coreDataStack.save()
                }
            } else {
                // Password doesn't match
                self.errorMessage = "Invalid email or password"
                self.isLoading = false
            }
        } else {
            // User doesn't exist - show error instead of creating account
            self.errorMessage = "No account found with this email address. Please check your email or create a new account."
            self.isLoading = false
        }
    }
    
    func register(firstName: String, lastName: String, email: String, phoneNumber: String, password: String) {
        isLoading = true
        errorMessage = nil
        
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
        guard email.contains("@"),
              password.count >= 6,
              !firstName.isEmpty,
              !lastName.isEmpty else {
            self.errorMessage = "Please check all fields and try again"
            self.isLoading = false
            return
        }
        
        if coreDataStack.userExists(email: email) {
            self.errorMessage = "An account with this email already exists"
            self.isLoading = false
            return
        }
 
        // Hash the password before storing it
        let hashedPassword = hashPassword(password)
        
        let newUserEntity = coreDataStack.createUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            password: hashedPassword
        )
        
        coreDataStack.loginUser(newUserEntity)
        
        self.currentUser = User(from: newUserEntity)
        self.isAuthenticated = true
        self.isLoading = false
    }
    
    func logout() {
        coreDataStack.logoutAllUsers()
        
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
    }
    
    func deleteAccount() {
        guard let currentUser = currentUser else { return }
        
        if let userEntity = coreDataStack.fetchUser(by: currentUser.email) {
            coreDataStack.deleteUser(userEntity)
        }
        
        self.currentUser = nil
        self.isAuthenticated = false
        self.errorMessage = nil
    }
    
    
    func updateUserProfile(firstName: String, lastName: String, phoneNumber: String?, profileImageData: Data? = nil) {
        guard let currentUser = currentUser else { return }
        
        if let userEntity = coreDataStack.fetchUser(by: currentUser.email) {
            userEntity.firstName = firstName
            userEntity.lastName = lastName
            userEntity.phoneNumber = phoneNumber

            if let imageData = profileImageData {
                UserDefaults.standard.set(imageData, forKey: "profileImage_\(currentUser.email)")
            }
            
            coreDataStack.save()
            
            self.currentUser = User(from: userEntity)
        }
    }
    
    private func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        biometricManager.authenticateUser(reason: "Authenticate to access your account") { success, error in
            if let error = error {
                print("Biometric authentication error: \(error)")
            }
            completion(success)
        }
    }
    
    func loginWithBiometric() {
        print("🔐 [AuthManager] loginWithBiometric called")
        
        if let userEntity = coreDataStack.fetchCurrentUser() {
            print("🔐 [AuthManager] Found currently logged in user: \(userEntity.email ?? "unknown")")
            
            // For biometric authentication, we just verify the user's identity
            // We don't need to check the password as the biometric authentication already verified their identity
            coreDataStack.loginUser(userEntity) // Make sure login state is updated
            
            self.currentUser = User(from: userEntity)
            self.isAuthenticated = true
            self.errorMessage = nil
            
            print("🔐 [AuthManager] Biometric login successful")
            return
        }
        
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserEntity.dateCreated, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let users = try coreDataStack.context.fetch(request)
            if let userEntity = users.first {
                print("🔐 [AuthManager] Found most recent user for biometric login: \(userEntity.email ?? "unknown")")
                
                coreDataStack.loginUser(userEntity)
                
                self.currentUser = User(from: userEntity)
                self.isAuthenticated = true
                self.errorMessage = nil
                
                print("🔐 [AuthManager] Biometric login successful")
            } else {
                print("🔐 [AuthManager] No users found for biometric login")
                self.errorMessage = "No user account found for biometric authentication"
            }
        } catch {
            print("🔐 [AuthManager] Error fetching user for biometric login: \(error)")
            self.errorMessage = "Error accessing user account"
        }
    }
}

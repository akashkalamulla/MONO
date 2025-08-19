import Foundation
import CoreData

// User model for the app
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

// Handles user authentication and account management
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let coreDataStack = CoreDataStack.shared
    
    init() {
        checkForLoggedInUser()
    }
    
    private func checkForLoggedInUser() {
        if let userEntity = coreDataStack.fetchCurrentUser() {
            self.currentUser = User(from: userEntity)
            self.isAuthenticated = true
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
        
        if let userEntity = coreDataStack.fetchUser(by: email) {
            
            coreDataStack.loginUser(userEntity)
            
            self.currentUser = User(from: userEntity)
            self.isAuthenticated = true
            self.isLoading = false
            
        } else {
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
        
        let newUserEntity = coreDataStack.createUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber
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
    
    func updateUserProfile(firstName: String, lastName: String, phoneNumber: String?) {
        guard let currentUser = currentUser else { return }
        
        if let userEntity = coreDataStack.fetchUser(by: currentUser.email) {
            userEntity.firstName = firstName
            userEntity.lastName = lastName
            userEntity.phoneNumber = phoneNumber
            
            coreDataStack.save()
            
            self.currentUser = User(from: userEntity)
        }
    }
}

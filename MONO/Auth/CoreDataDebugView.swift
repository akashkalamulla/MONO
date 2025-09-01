//
//  CoreDataDebugView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import SwiftUI
import CoreData
import CryptoKit

struct CoreDataDebugView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserEntity.dateCreated, ascending: false)],
        animation: .default)
    private var users: FetchedResults<UserEntity>
    
    var body: some View {
        NavigationView {
            List {
                Section("All Users (\(users.count))") {
                    ForEach(users, id: \.id) { user in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(user.fullName)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button("Reset Password") {
                                    resetPassword(for: user)
                                }
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                                
                                if user.isLoggedIn {
                                    Text("LOGGED IN")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                }
                            }
                            
                            Text(user.safeEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if !user.safePhoneNumber.isEmpty {
                                Text(user.safePhoneNumber)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Display password hash for debugging
                            Text("Password: \(user.password ?? "No password set")")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            Text("Created: \(user.safeDateCreated, formatter: dateFormatter)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete(perform: deleteUsers)
                }
                
                Section("Debug Actions") {
                    Button("Create Test User") {
                        createTestUser()
                    }
                    
                    Button("Logout All Users") {
                        logoutAllUsers()
                    }
                    
                    Button("Clear All Data") {
                        clearAllData()
                    }
                    .foregroundColor(.red)
                    
                    Button("Test Login Authentication") {
                        testLoginAuthentication()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Core Data Debug")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func createTestUser() {
        withAnimation {
            let newUser = UserEntity(context: viewContext)
            newUser.id = UUID()
            newUser.firstName = "Test"
            newUser.lastName = "User \(Int.random(in: 1...1000))"
            newUser.email = "test\(Int.random(in: 1...1000))@example.com"
            newUser.phoneNumber = "+1234567890"
            newUser.dateCreated = Date()
            newUser.isLoggedIn = false
            
            do {
                try viewContext.save()
            } catch {
                print("Error creating test user: \(error)")
            }
        }
    }
    
    private func logoutAllUsers() {
        withAnimation {
            for user in users {
                user.isLoggedIn = false
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error logging out users: \(error)")
            }
        }
    }
    
    private func clearAllData() {
        withAnimation {
            for user in users {
                viewContext.delete(user)
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error clearing data: \(error)")
            }
        }
    }
    
    private func deleteUsers(offsets: IndexSet) {
        withAnimation {
            offsets.map { users[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting users: \(error)")
            }
        }
    }
    
    private func testLoginAuthentication() {
        // Check if there are any users
        guard !users.isEmpty else {
            print("No users found in database")
            return
        }
        
        // Create the authentication manager
        let authManager = AuthenticationManager()
        
        // Test for each user
        for user in users {
            // Generate a test password
            let testPassword = "Password123"
            let hashedPassword = hashPassword(testPassword)
            
            print("📊 Testing login for: \(user.safeEmail)")
            print("📊 Current stored password hash: \(user.password ?? "None")")
            
            // Try to log in with both the hashed and unhashed password
            print("📊 Testing with direct password: \(testPassword)")
            print("📊 Testing with hashed password: \(hashedPassword)")
            
            // Set a test password temporarily for diagnostic purposes
            user.password = hashedPassword
            
            do {
                try viewContext.save()
                print("📊 Updated user password for testing")
            } catch {
                print("📊 Error updating password: \(error)")
            }
            
            print("📊 If you try to login now with email: \(user.safeEmail) and password: \(testPassword)")
            print("📊 It should work. If not, there may be an issue with the hashing function.")
        }
    }
    
    // Simple password hashing function (same as in AuthenticationManager)
    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func resetPassword(for user: UserEntity) {
        // Set to a known default password - "Password123"
        let defaultPassword = "Password123"
        let hashedPassword = hashPassword(defaultPassword)
        
        withAnimation {
            user.password = hashedPassword
            
            do {
                try viewContext.save()
                print("Password reset for user \(user.safeEmail) to '\(defaultPassword)'")
            } catch {
                print("Error resetting password: \(error)")
            }
        }
    }
}

#Preview {
    CoreDataDebugView()
        .environment(\.managedObjectContext, CoreDataStack.shared.context)
}

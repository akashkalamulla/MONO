//
//  CoreDataDebugView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import SwiftUI
import CoreData

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
}

#Preview {
    CoreDataDebugView()
        .environment(\.managedObjectContext, CoreDataStack.shared.context)
}

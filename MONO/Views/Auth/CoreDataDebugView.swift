import SwiftUI
import CoreData

struct CoreDataDebugView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Core Data Debug")
                    .font(.title)
                    .padding()
                
                Text("Database is working!")
                    .foregroundColor(.green)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Debug")
        }
    }
}
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
                            
                            // Show dependents count
                            if let userDependents = user.dependents {
                                Text("Dependents: \(userDependents.count)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete(perform: deleteUsers)
                }
                
                Section("All Dependents (\(dependents.count))") {
                    ForEach(dependents, id: \.id) { dependent in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(dependent.safeFirstName) \(dependent.safeLastName)")
                                    .font(.headline)
                                
                                Spacer()
                                
                                if dependent.isActive {
                                    Text("ACTIVE")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                } else {
                                    Text("INACTIVE")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                }
                            }
                            
                            Text("Relationship: \(dependent.safeRelationship)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if !dependent.safeEmail.isEmpty {
                                Text("Email: \(dependent.safeEmail)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if !dependent.safePhoneNumber.isEmpty {
                                Text("Phone: \(dependent.safePhoneNumber)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("DOB: \(dependent.safeDateOfBirth, formatter: dateFormatter)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Added: \(dependent.safeDateAdded, formatter: dateFormatter)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // Show which user owns this dependent
                            if let owner = dependent.user {
                                Text("Owner: \(owner.fullName)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete(perform: deleteDependents)
                }
                
                Section("Debug Actions") {
                    Button("Create Test User") {
                        createTestUser()
                    }
                    
                    Button("Create Test Dependent") {
                        createTestDependent()
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
    
    private func createTestDependent() {
        withAnimation {
            // Get the first user or create one
            let user = users.first ?? {
                let newUser = UserEntity(context: viewContext)
                newUser.id = UUID()
                newUser.firstName = "Test"
                newUser.lastName = "User"
                newUser.email = "test@example.com"
                newUser.phoneNumber = "+1234567890"
                newUser.dateCreated = Date()
                newUser.isLoggedIn = true
                return newUser
            }()
            
            let dependent = DependentEntity(context: viewContext)
            dependent.id = UUID()
            dependent.firstName = "Test"
            dependent.lastName = "Dependent \(Int.random(in: 1...1000))"
            dependent.relationship = ["Spouse", "Child", "Parent", "Sibling"].randomElement() ?? "Other"
            dependent.dateOfBirth = Calendar.current.date(byAdding: .year, value: -Int.random(in: 1...50), to: Date()) ?? Date()
            dependent.phoneNumber = "+1987654321"
            dependent.email = "dependent\(Int.random(in: 1...1000))@example.com"
            dependent.isActive = Bool.random()
            dependent.dateAdded = Date()
            dependent.user = user
            
            do {
                try viewContext.save()
            } catch {
                print("Error creating test dependent: \(error)")
            }
        }
    }
    
    private func deleteDependents(offsets: IndexSet) {
        withAnimation {
            offsets.map { dependents[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting dependents: \(error)")
            }
        }
    }
    
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
            // Delete all dependents first (due to relationships)
            for dependent in dependents {
                viewContext.delete(dependent)
            }
            
            // Then delete all users
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

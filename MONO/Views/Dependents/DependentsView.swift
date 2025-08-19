//
//  DependentsView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import SwiftUI

struct DependentsView: View {
    @ObservedObject var dependentManager: DependentManager
    @ObservedObject var authManager: AuthenticationManager
    @State private var showingAddDependent = false
    @State private var searchText = ""
    
    var filteredDependents: [Dependent] {
        if searchText.isEmpty {
            return dependentManager.dependents
        } else {
            return dependentManager.dependents.filter { dependent in
                dependent.fullName.localizedCaseInsensitiveContains(searchText) ||
                dependent.relationship.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if dependentManager.dependents.isEmpty {
                    EmptyDependentsView {
                        showingAddDependent = true
                    }
                } else {
                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Dependents List
                    List {
                        ForEach(filteredDependents) { dependent in
                            DependentRowView(dependent: dependent, dependentManager: dependentManager)
                        }
                        .onDelete(perform: deleteDependent)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Dependents")
            .navigationBarItems(
                trailing: Button(action: { showingAddDependent = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.monoPrimary)
                }
            )
        }
        .sheet(isPresented: $showingAddDependent) {
            AddDependentView(dependentManager: dependentManager, authManager: authManager)
        }
        .onAppear {
            if let currentUser = authManager.currentUser {
                dependentManager.loadDependents(for: currentUser.id)
            }
        }
    }
    
    private func deleteDependent(at offsets: IndexSet) {
        for index in offsets {
            let dependent = filteredDependents[index]
            _ = dependentManager.deleteDependent(dependent)
            if let currentUser = authManager.currentUser {
                dependentManager.loadDependents(for: currentUser.id)
            }
        }
    }
}

// MARK: - Dependent Row View
struct DependentRowView: View {
    let dependent: Dependent
    @ObservedObject var dependentManager: DependentManager
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(dependent.isActive ? Color.monoPrimary.opacity(0.2) : Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    Text(dependent.initials)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(dependent.isActive ? .monoPrimary : .gray)
                }
                
                // Information
                VStack(alignment: .leading, spacing: 4) {
                    Text(dependent.fullName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(dependent.isActive ? .monoPrimary : .gray)
                        .lineLimit(1)
                    
                    Text(dependent.relationship)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("Age: \(dependent.age)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Status and Arrow
                VStack(spacing: 8) {
                    if !dependent.isActive {
                        Text("Inactive")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            DependentDetailView(dependent: dependent, dependentManager: dependentManager)
        }
    }
}

// MARK: - Empty State View
struct EmptyDependentsView: View {
    let onAddDependent: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "person.2.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Dependents Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.monoPrimary)
                
                Text("Add family members to manage their expenses")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: onAddDependent) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add First Dependent")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(Color.monoPrimary)
                .cornerRadius(25)
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search dependents...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    let authManager = AuthenticationManager()
    authManager.currentUser = User(firstName: "John", lastName: "Doe", email: "john@example.com")
    authManager.isAuthenticated = true
    
    let dependentManager = DependentManager()
    
    return DependentsView(dependentManager: dependentManager, authManager: authManager)
}

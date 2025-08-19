//
//  DependentDetailView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import SwiftUI

struct DependentDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let dependent: Dependent
    @ObservedObject var dependentManager: DependentManager
    let currentUser: User
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(dependent.isActive ? Color.monoPrimary.opacity(0.2) : Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                            
                            Text(dependent.initials)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(dependent.isActive ? .monoPrimary : .gray)
                        }
                        
                        VStack(spacing: 4) {
                            Text(dependent.fullName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.monoPrimary)
                            
                            Text(dependent.relationship)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            
                            if !dependent.isActive {
                                Text("Inactive")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.top)
                    
                    // Information Cards
                    VStack(spacing: 16) {
                        InfoCard(title: "Personal Information") {
                            VStack(spacing: 12) {
                                InfoRow(label: "Age", value: "\(dependent.age) years old")
                                InfoRow(label: "Date of Birth", value: formatDate(dependent.dateOfBirth))
                                InfoRow(label: "Added on", value: formatDate(dependent.dateAdded))
                            }
                        }
                        
                        if !dependent.phoneNumber.isEmpty || !dependent.email.isEmpty {
                            InfoCard(title: "Contact Information") {
                                VStack(spacing: 12) {
                                    if !dependent.phoneNumber.isEmpty {
                                        InfoRow(label: "Phone", value: dependent.phoneNumber)
                                    }
                                    if !dependent.email.isEmpty {
                                        InfoRow(label: "Email", value: dependent.email)
                                    }
                                }
                            }
                        }
                        
                        // Expense Summary Card (Placeholder for future feature)
                        InfoCard(title: "Expense Summary") {
                            VStack(spacing: 12) {
                                InfoRow(label: "Total Expenses", value: "$0.00")
                                InfoRow(label: "This Month", value: "$0.00")
                                InfoRow(label: "Last Expense", value: "No expenses yet")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: { showingEditView = true }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Details")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.monoPrimary)
                            .cornerRadius(25)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Button(action: toggleActiveStatus) {
                            HStack {
                                Image(systemName: dependent.isActive ? "pause.circle" : "play.circle")
                                Text(dependent.isActive ? "Deactivate" : "Activate")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.monoPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.monoPrimary, lineWidth: 1)
                            )
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button(action: { showingDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Dependent")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .sheet(isPresented: $showingEditView) {
            EditDependentView(dependent: dependent, dependentManager: dependentManager, currentUser: currentUser)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Dependent"),
                message: Text("Are you sure you want to delete \(dependent.fullName)? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteDependent()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func toggleActiveStatus() {
        dependentManager.toggleDependentStatus(dependent, for: currentUser.id)
        // Note: In a real app, you'd refresh the view or use @State to track changes
    }
    
    private func deleteDependent() {
        dependentManager.deleteDependent(dependent, for: currentUser.id)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Info Card
struct InfoCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.monoPrimary)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.monoPrimary)
        }
    }
}

#Preview {
    let sampleDependent = Dependent(
        firstName: "Emma",
        lastName: "Smith",
        relationship: "Child",
        dateOfBirth: Calendar.current.date(byAdding: .year, value: -8, to: Date()) ?? Date(),
        phoneNumber: "555-0123",
        email: "emma@example.com"
    )
    
    let sampleUser = User(
        firstName: "John",
        lastName: "Doe",
        email: "john@example.com",
        phoneNumber: "555-0123"
    )
    
    DependentDetailView(
        dependent: sampleDependent,
        dependentManager: DependentManager(),
        currentUser: sampleUser
    )
}

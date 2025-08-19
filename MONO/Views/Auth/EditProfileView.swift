//
//  EditProfileView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var phoneNumber: String
    @State private var isLoading = false
    
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
        self._firstName = State(initialValue: authManager.currentUser?.firstName ?? "")
        self._lastName = State(initialValue: authManager.currentUser?.lastName ?? "")
        self._phoneNumber = State(initialValue: authManager.currentUser?.phoneNumber ?? "")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Avatar
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.monoPrimary.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(firstName.prefix(1).uppercased())
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.monoPrimary)
                            )
                        
                        Button(action: {
                            // Handle photo change
                        }) {
                            Text("Change Photo")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.monoPrimary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Edit Form
                    VStack(spacing: 20) {
                        // First Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            TextField("Enter first name", text: $firstName)
                                .textFieldStyle(CustomTextFieldStyle())
                                .textInputAutocapitalization(.words)
                        }
                        
                        // Last Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            TextField("Enter last name", text: $lastName)
                                .textFieldStyle(CustomTextFieldStyle())
                                .textInputAutocapitalization(.words)
                        }
                        
                        // Email (Read-only)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            Text(authManager.currentUser?.email ?? "")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Phone Number
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone Number")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            TextField("Enter phone number", text: $phoneNumber)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.phonePad)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Save Button
                    Button(action: saveProfile) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(isLoading ? "Saving..." : "Save Changes")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            hasChanges ? Color.monoPrimary : Color.gray
                        )
                        .cornerRadius(25)
                    }
                    .disabled(!hasChanges || isLoading)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.monoPrimary)
                }
            }
        }
    }
    
    private var hasChanges: Bool {
        firstName != (authManager.currentUser?.firstName ?? "") ||
        lastName != (authManager.currentUser?.lastName ?? "") ||
        phoneNumber != (authManager.currentUser?.phoneNumber ?? "")
    }
    
    private func saveProfile() {
        isLoading = true
        
        // Simulate save delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            authManager.updateUserProfile(
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber
            )
            
            isLoading = false
            dismiss()
        }
    }
}

#Preview {
    let authManager = AuthenticationManager()
    authManager.currentUser = User(firstName: "John", lastName: "Doe", email: "john@example.com")
    
    return EditProfileView(authManager: authManager)
}

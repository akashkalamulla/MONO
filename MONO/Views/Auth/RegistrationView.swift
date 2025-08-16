//
//  RegistrationView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-16.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var username = ""
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "#438883"))
                        
                        Text("Join MONO and start managing your finances smartly")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 32)
                    
                    // Form
                    VStack(spacing: 20) {
                        CustomTextField(title: "Username", text: $username)
                        
                        CustomTextField(title: "Full Name", text: $name)
                        
                        CustomTextField(title: "Email", text: $email, keyboardType: .emailAddress)
                        
                        CustomTextField(title: "Password", text: $password, isSecure: true)
                        
                        CustomTextField(title: "Confirm Password", text: $confirmPassword, isSecure: true)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 32)
                    
                    // Register Button
                    Button(action: {
                        registerUser()
                    }) {
                        if authManager.isLoading {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Creating Account...")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Text("Create Account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "#438883"))
                    .cornerRadius(25)
                    .padding(.horizontal, 32)
                    .padding(.top, 30)
                    .disabled(authManager.isLoading)
                    
                    // Login Link
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Sign In")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#438883"))
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .background(Color(UIColor.systemGray6))
            .navigationBarHidden(true)
        }
        .alert("Registration", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("successful") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func registerUser() {
        // Validation
        guard !username.isEmpty else {
            showError("Please enter a username")
            return
        }
        
        guard !name.isEmpty else {
            showError("Please enter your full name")
            return
        }
        
        guard !email.isEmpty else {
            showError("Please enter your email")
            return
        }
        
        guard isValidEmail(email) else {
            showError("Please enter a valid email address")
            return
        }
        
        guard !password.isEmpty else {
            showError("Please enter a password")
            return
        }
        
        guard password.count >= 6 else {
            showError("Password must be at least 6 characters")
            return
        }
        
        guard password == confirmPassword else {
            showError("Passwords do not match")
            return
        }
        
        // Register user
        authManager.registerUser(username: username, email: email, password: password, name: name) { success in
            if success {
                alertMessage = "Registration successful! You can now sign in."
                showAlert = true
            } else {
                showError(authManager.errorMessage)
            }
        }
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

#Preview {
    PreviewWrapper {
        RegistrationView()
    }
}

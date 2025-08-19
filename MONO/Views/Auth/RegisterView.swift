//
//  RegisterView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var agreeToTerms = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.monoPrimary)
                        
                        Text("Join mono for smarter spending")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    // Registration Form
                    VStack(spacing: 18) {
                        // Name Fields
                        HStack(spacing: 12) {
                            // First Name
                            VStack(alignment: .leading, spacing: 6) {
                                Text("First Name")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.monoPrimary)
                                
                                TextField("First name", text: $firstName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .textInputAutocapitalization(.words)
                            }
                            
                            // Last Name
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Last Name")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.monoPrimary)
                                
                                TextField("Last name", text: $lastName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .textInputAutocapitalization(.words)
                            }
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                        }
                        
                        // Phone Number Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Phone Number")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            TextField("Enter your phone number", text: $phoneNumber)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.phonePad)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            HStack {
                                if showPassword {
                                    TextField("Create password", text: $password)
                                } else {
                                    SecureField("Create password", text: $password)
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .textFieldStyle(CustomTextFieldStyle())
                            
                            // Password requirements
                            if !password.isEmpty {
                                VStack(alignment: .leading, spacing: 2) {
                                    PasswordRequirement(
                                        text: "At least 6 characters",
                                        isMet: password.count >= 6
                                    )
                                    PasswordRequirement(
                                        text: "Contains letters and numbers",
                                        isMet: password.range(of: ".*[A-Za-z].*", options: .regularExpression) != nil &&
                                               password.range(of: ".*[0-9].*", options: .regularExpression) != nil
                                    )
                                }
                                .padding(.top, 4)
                            }
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Confirm Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            HStack {
                                if showConfirmPassword {
                                    TextField("Confirm password", text: $confirmPassword)
                                } else {
                                    SecureField("Confirm password", text: $confirmPassword)
                                }
                                
                                Button(action: {
                                    showConfirmPassword.toggle()
                                }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .textFieldStyle(CustomTextFieldStyle())
                            
                            // Password match indicator
                            if !confirmPassword.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(passwordsMatch ? .green : .red)
                                        .font(.system(size: 12))
                                    
                                    Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                                        .font(.system(size: 12))
                                        .foregroundColor(passwordsMatch ? .green : .red)
                                }
                                .padding(.top, 4)
                            }
                        }
                        
                        // Terms and Conditions
                        HStack(alignment: .top, spacing: 8) {
                            Button(action: {
                                agreeToTerms.toggle()
                            }) {
                                Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                    .foregroundColor(agreeToTerms ? .monoPrimary : .gray)
                                    .font(.system(size: 20))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("I agree to the ")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray) +
                                Text("Terms of Service")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.monoPrimary) +
                                Text(" and ")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray) +
                                Text("Privacy Policy")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.monoPrimary)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 30)
                    
                    // Error Message
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 30)
                    }
                    
                    // Register Button
                    Button(action: {
                        authManager.register(
                            firstName: firstName,
                            lastName: lastName,
                            email: email,
                            phoneNumber: phoneNumber,
                            password: password
                        )
                    }) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(authManager.isLoading ? "Creating Account..." : "Create Account")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            isFormValid ? Color.monoPrimary : Color.gray
                        )
                        .cornerRadius(25)
                    }
                    .disabled(!isFormValid || authManager.isLoading)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 30)
                    
                    // Sign In Link
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Sign In")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.monoPrimary)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .background(Color(UIColor.systemGray6))
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
        .onChange(of: authManager.isAuthenticated) {
            if authManager.isAuthenticated {
                dismiss()
            }
        }
    }
    
    private var passwordsMatch: Bool {
        password == confirmPassword && !password.isEmpty
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        passwordsMatch &&
        agreeToTerms
    }
}

// MARK: - Password Requirement Component
struct PasswordRequirement: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .gray)
                .font(.system(size: 12))
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(isMet ? .green : .gray)
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthenticationManager())
}

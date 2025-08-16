//
//  LoginView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-16.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authManager: AuthManager
    
    @State private var emailOrUsername = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var showRegistration = false
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Welcome Back")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "#438883"))
                        
                        Text("Sign in to your MONO account")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 32)
                    
                    // Form
                    VStack(spacing: 20) {
                        CustomTextField(title: "Email or Username", text: $emailOrUsername, keyboardType: .emailAddress)
                        
                        CustomTextField(title: "Password", text: $password, isSecure: true)
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button(action: {
                                // TODO: Implement forgot password
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "#438883"))
                            }
                        }
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 32)
                    
                    // Login Button
                    Button(action: {
                        loginUser()
                    }) {
                        if authManager.isLoading {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Signing In...")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Text("Sign In")
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
                    
                    // Register Link
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showRegistration = true
                        }) {
                            Text("Sign Up")
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
        .alert("Login Error", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(authManager.errorMessage)
        }
        .sheet(isPresented: $showRegistration) {
            RegistrationView()
                .environmentObject(authManager)
        }
        .onChange(of: authManager.isLoggedIn) { isLoggedIn in
            print("Login state changed: \(isLoggedIn)")
            if isLoggedIn {
                print("User logged in successfully, closing login view")
                isPresented = false
            }
        }
    }
    
    private func loginUser() {
        guard !emailOrUsername.isEmpty else {
            authManager.errorMessage = "Please enter your email or username"
            showAlert = true
            return
        }
        
        guard !password.isEmpty else {
            authManager.errorMessage = "Please enter your password"
            showAlert = true
            return
        }
        
        authManager.loginUser(emailOrUsername: emailOrUsername, password: password) { success in
            if !success {
                showAlert = true
            }
        }
    }
}

#Preview {
    PreviewWrapper {
        LoginView(isPresented: .constant(true))
    }
}

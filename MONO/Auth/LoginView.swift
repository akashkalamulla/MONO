import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @StateObject private var biometricManager = BiometricAuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showRegister = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.monoPrimary)
                        
                        Text("Sign in to your account")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)
                    
                    if biometricManager.isAvailable && biometricManager.isBiometricEnabled {
                        VStack(spacing: 16) {
                            Button(action: {
                                authenticateWithFaceID()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: biometricManager.biometricIcon)
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Sign in with \(biometricManager.biometricTypeDescription)")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        if biometricManager.isSimulator {
                                            Text("(Simulator Mode)")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.monoPrimary, Color.monoPrimary.opacity(0.85)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 30)
                            
                            HStack {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray.opacity(0.3))
                                
                                Text("or")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                            .padding(.horizontal, 30)
                        }
                    }
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                        }
                        
    
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            HStack {
                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    
        
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 30)
                    }
                    
            
                    Button(action: {
                        authManager.login(email: email, password: password)
                    }) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(authManager.isLoading ? "Signing In..." : "Sign In")
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
                    
                
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showRegister = true
                        }) {
                            Text("Sign Up")
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
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
        .onChange(of: authManager.isAuthenticated) {
            if authManager.isAuthenticated {
                dismiss()
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 6
    }
    
    private func authenticateWithFaceID() {
        print("🔐 [LoginView] Face ID button tapped")
        
        biometricManager.authenticateUser(reason: "Sign in to your account with \(biometricManager.biometricTypeDescription)") { success, error in
            DispatchQueue.main.async {
                if success {
                    print("🔐 [LoginView] Face ID authentication successful")
                    // Sign in with the last logged-in user
                    authManager.loginWithBiometric()
                } else {
                    print("🔐 [LoginView] Face ID authentication failed: \(error ?? "Unknown error")")
                    authManager.errorMessage = error ?? "Biometric authentication failed"
                }
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}

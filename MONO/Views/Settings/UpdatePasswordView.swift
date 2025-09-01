import SwiftUI
import UIKit

struct UpdatePasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.monoPrimary)
                        
                        Text("Change Password")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.monoPrimary)
                        
                        Text("Enter your current password and choose a new secure password")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Password")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            HStack {
                                if showCurrentPassword {
                                    TextField("Enter current password", text: $currentPassword)
                                } else {
                                    SecureField("Enter current password", text: $currentPassword)
                                }
                                
                                Button(action: {
                                    showCurrentPassword.toggle()
                                }) {
                                    Image(systemName: showCurrentPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Password")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            HStack {
                                if showNewPassword {
                                    TextField("Enter new password", text: $newPassword)
                                } else {
                                    SecureField("Enter new password", text: $newPassword)
                                }
                                
                                Button(action: {
                                    showNewPassword.toggle()
                                }) {
                                    Image(systemName: showNewPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                            
                            PasswordStrengthIndicator(password: newPassword)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm New Password")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.monoPrimary)
                            
                            HStack {
                                if showConfirmPassword {
                                    TextField("Confirm new password", text: $confirmPassword)
                                } else {
                                    SecureField("Confirm new password", text: $confirmPassword)
                                }
                                
                                Button(action: {
                                    showConfirmPassword.toggle()
                                }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                            
                            if !confirmPassword.isEmpty {
                                HStack {
                                    Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(passwordsMatch ? .green : .red)
                                    
                                    Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                                        .font(.system(size: 14))
                                        .foregroundColor(passwordsMatch ? .green : .red)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: updatePassword) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Updating...")
                            } else {
                                Text("Update Password")
                            }
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isValidInput ? Color.monoPrimary : Color.gray)
                        .cornerRadius(25)
                    }
                    .disabled(!isValidInput || isLoading)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                if alertTitle == "Success" {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var passwordsMatch: Bool {
        return newPassword == confirmPassword && !confirmPassword.isEmpty
    }
    
    private var isValidInput: Bool {
        return !currentPassword.isEmpty &&
               !newPassword.isEmpty &&
               !confirmPassword.isEmpty &&
               passwordsMatch &&
               isPasswordStrong(newPassword)
    }
    
    private func isPasswordStrong(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d@$!%*?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    private func updatePassword() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            alertTitle = "Success"
            alertMessage = "Your password has been updated successfully."
            showAlert = true
            
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
        }
    }
}

struct PasswordStrengthIndicator: View {
    let password: String
    
    private var strength: PasswordStrength {
        if password.isEmpty {
            return .none
        } else if password.count < 6 {
            return .weak
        } else if password.count < 8 || !hasUppercase || !hasLowercase || !hasNumber {
            return .medium
        } else {
            return .strong
        }
    }
    
    private var hasUppercase: Bool {
        return password.rangeOfCharacter(from: .uppercaseLetters) != nil
    }
    
    private var hasLowercase: Bool {
        return password.rangeOfCharacter(from: .lowercaseLetters) != nil
    }
    
    private var hasNumber: Bool {
        return password.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    var body: some View {
        if !password.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Rectangle()
                            .fill(index < strength.rawValue ? strength.color : Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .cornerRadius(2)
                    }
                }
                
                Text(strength.description)
                    .font(.system(size: 12))
                    .foregroundColor(strength.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    RequirementRow(met: password.count >= 8, text: "At least 8 characters")
                    RequirementRow(met: hasUppercase, text: "One uppercase letter")
                    RequirementRow(met: hasLowercase, text: "One lowercase letter")
                    RequirementRow(met: hasNumber, text: "One number")
                }
            }
        }
    }
}

struct RequirementRow: View {
    let met: Bool
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12))
                .foregroundColor(met ? .green : .gray)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(met ? .green : .gray)
        }
    }
}

enum PasswordStrength: Int, CaseIterable {
    case none = 0
    case weak = 1
    case medium = 2
    case strong = 3
    
    var description: String {
        switch self {
        case .none:
            return ""
        case .weak:
            return "Weak password"
        case .medium:
            return "Medium password"
        case .strong:
            return "Strong password"
        }
    }
    
    var color: Color {
        switch self {
        case .none:
            return .clear
        case .weak:
            return .red
        case .medium:
            return .orange
        case .strong:
            return .green
        }
    }
}

#Preview {
    UpdatePasswordView()
}

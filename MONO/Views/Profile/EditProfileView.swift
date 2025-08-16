//
//  EditProfileView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-16.
//

import SwiftUI
import CoreData

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var username: String = ""
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var isEditing = false
    @State private var showingChangePassword = false
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    // Validation states
    @State private var usernameError = ""
    @State private var nameError = ""
    @State private var emailError = ""
    @State private var passwordError = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Image Section
                    ProfileImageSection()
                    
                    // Profile Information Form
                    if isEditing {
                        EditingForm()
                    } else {
                        DisplayForm()
                    }
                    
                    // Password Section
                    if isEditing {
                        ChangePasswordSection()
                    }
                    
                    // Action Buttons
                    ActionButtons()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if isEditing {
                            loadUserData()
                            isEditing = false
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                        }
                        .disabled(isLoading)
                    } else {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            loadUserData()
        }
        .alert("Profile Update", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .overlay {
            if isLoading {
                LoadingOverlay()
            }
        }
    }
    
    // MARK: - Profile Image Section
    @ViewBuilder
    private func ProfileImageSection() -> some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color(hex: "#438883").opacity(0.1))
                .frame(width: 120, height: 120)
                .overlay(
                    Text(name.prefix(1).uppercased())
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(Color(hex: "#438883"))
                )
            
            Button(action: {
                showingImagePicker = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14))
                    Text("Change Profile Photo")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(Color(hex: "#438883"))
            }
        }
    }
    
    // MARK: - Display Form (Read-only)
    @ViewBuilder
    private func DisplayForm() -> some View {
        VStack(spacing: 16) {
            ProfileDisplayRow(label: "Username", value: username, icon: "person.circle")
            ProfileDisplayRow(label: "Full Name", value: name, icon: "person.text.rectangle")
            ProfileDisplayRow(label: "Email", value: email, icon: "envelope")
            
            // Additional info
            if let user = authManager.currentUser {
                ProfileDisplayRow(
                    label: "Member Since", 
                    value: formatDate(user.createdAt), 
                    icon: "calendar"
                )
            }
        }
    }
    
    // MARK: - Editing Form
    @ViewBuilder
    private func EditingForm() -> some View {
        VStack(spacing: 20) {
            // Username Field
            VStack(alignment: .leading, spacing: 8) {
                ProfileEditField(
                    label: "Username",
                    text: $username,
                    icon: "person.circle",
                    error: usernameError
                )
                .onChange(of: username) { _ in
                    validateUsername()
                }
            }
            
            // Name Field
            VStack(alignment: .leading, spacing: 8) {
                ProfileEditField(
                    label: "Full Name",
                    text: $name,
                    icon: "person.text.rectangle",
                    error: nameError
                )
                .onChange(of: name) { _ in
                    validateName()
                }
            }
            
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                ProfileEditField(
                    label: "Email",
                    text: $email,
                    icon: "envelope",
                    keyboardType: .emailAddress,
                    error: emailError
                )
                .onChange(of: email) { _ in
                    validateEmail()
                }
            }
        }
    }
    
    // MARK: - Change Password Section
    @ViewBuilder
    private func ChangePasswordSection() -> some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Text("Change Password")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Button(showingChangePassword ? "Hide" : "Change") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingChangePassword.toggle()
                        if !showingChangePassword {
                            currentPassword = ""
                            newPassword = ""
                            confirmPassword = ""
                            passwordError = ""
                        }
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#438883"))
            }
            
            if showingChangePassword {
                VStack(spacing: 16) {
                    ProfileEditField(
                        label: "Current Password",
                        text: $currentPassword,
                        icon: "lock",
                        isSecure: true
                    )
                    
                    ProfileEditField(
                        label: "New Password",
                        text: $newPassword,
                        icon: "lock.fill",
                        isSecure: true
                    )
                    
                    ProfileEditField(
                        label: "Confirm Password",
                        text: $confirmPassword,
                        icon: "lock.fill",
                        isSecure: true,
                        error: passwordError
                    )
                    .onChange(of: confirmPassword) { _ in
                        validatePasswords()
                    }
                    .onChange(of: newPassword) { _ in
                        validatePasswords()
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // MARK: - Action Buttons
    @ViewBuilder
    private func ActionButtons() -> some View {
        VStack(spacing: 12) {
            if isEditing {
                HStack(spacing: 12) {
                    Button(action: {
                        loadUserData()
                        isEditing = false
                        showingChangePassword = false
                        clearErrors()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#438883"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#438883"), lineWidth: 2)
                            )
                    }
                    
                    Button(action: {
                        saveChanges()
                    }) {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            }
                            Text("Save Changes")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color(hex: "#438883") : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isLoading)
                }
            } else {
                Button(action: {
                    isEditing = true
                }) {
                    Text("Edit Profile")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#438883"))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // MARK: - Validation
    private var isFormValid: Bool {
        !username.isEmpty && !name.isEmpty && !email.isEmpty &&
        usernameError.isEmpty && nameError.isEmpty && emailError.isEmpty &&
        (showingChangePassword ? passwordError.isEmpty && !newPassword.isEmpty : true)
    }
    
    private func validateUsername() {
        usernameError = ""
        if username.isEmpty {
            usernameError = "Username is required"
        } else if username.count < 3 {
            usernameError = "Username must be at least 3 characters"
        } else if username.contains(" ") {
            usernameError = "Username cannot contain spaces"
        }
    }
    
    private func validateName() {
        nameError = ""
        if name.isEmpty {
            nameError = "Name is required"
        } else if name.count < 2 {
            nameError = "Name must be at least 2 characters"
        }
    }
    
    private func validateEmail() {
        emailError = ""
        if email.isEmpty {
            emailError = "Email is required"
        } else if !isValidEmail(email) {
            emailError = "Please enter a valid email address"
        }
    }
    
    private func validatePasswords() {
        passwordError = ""
        if showingChangePassword {
            if !newPassword.isEmpty && newPassword.count < 6 {
                passwordError = "Password must be at least 6 characters"
            } else if newPassword != confirmPassword {
                passwordError = "Passwords do not match"
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func clearErrors() {
        usernameError = ""
        nameError = ""
        emailError = ""
        passwordError = ""
    }
    
    // MARK: - Data Operations
    private func loadUserData() {
        username = authManager.currentUser?.username ?? ""
        name = authManager.currentUser?.name ?? ""
        email = authManager.currentUser?.email ?? ""
    }
    
    private func saveChanges() {
        guard isFormValid else { return }
        
        isLoading = true
        
        // Validate all fields first
        validateUsername()
        validateName()
        validateEmail()
        if showingChangePassword {
            validatePasswords()
        }
        
        guard isFormValid else {
            isLoading = false
            return
        }
        
        // Check if username or email already exists (except current user)
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "(username == %@ OR email == %@) AND self != %@",
            username, email, authManager.currentUser!
        )
        
        do {
            let existingUsers = try viewContext.fetch(fetchRequest)
            if !existingUsers.isEmpty {
                let existingUser = existingUsers.first!
                if existingUser.username == username {
                    usernameError = "Username already exists"
                }
                if existingUser.email == email {
                    emailError = "Email already exists"
                }
                isLoading = false
                return
            }
        } catch {
            alertMessage = "Error checking existing users: \(error.localizedDescription)"
            showingAlert = true
            isLoading = false
            return
        }
        
        // Update user data
        guard let currentUser = authManager.currentUser else {
            isLoading = false
            return
        }
        
        currentUser.username = username
        currentUser.name = name
        currentUser.email = email
        
        // Update password if changed
        if showingChangePassword && !newPassword.isEmpty {
            // Verify current password first
            if currentUser.password != currentPassword {
                passwordError = "Current password is incorrect"
                isLoading = false
                return
            }
            currentUser.password = newPassword
        }
        
        // Save to Core Data
        do {
            try viewContext.save()
            
            // Update AuthManager
            authManager.currentUser = currentUser
            
            // Show success and close editing
            alertMessage = "Profile updated successfully!"
            showingAlert = true
            isEditing = false
            showingChangePassword = false
            clearErrors()
            
        } catch {
            alertMessage = "Failed to update profile: \(error.localizedDescription)"
            showingAlert = true
        }
        
        isLoading = false
    }
}

// MARK: - Profile Display Row
struct ProfileDisplayRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#438883"))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                
                Text(value.isEmpty ? "Not set" : value)
                    .font(.system(size: 16))
                    .foregroundColor(value.isEmpty ? .gray : .primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Profile Edit Field
struct ProfileEditField: View {
    let label: String
    @Binding var text: String
    let icon: String
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    let error: String
    
    init(
        label: String,
        text: Binding<String>,
        icon: String,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        error: String = ""
    ) {
        self.label = label
        self._text = text
        self.icon = icon
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.error = error
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#438883"))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    
                    if isSecure {
                        SecureField("Enter \(label.lowercased())", text: $text)
                            .font(.system(size: 16))
                            .textContentType(.password)
                    } else {
                        TextField("Enter \(label.lowercased())", text: $text)
                            .font(.system(size: 16))
                            .keyboardType(keyboardType)
                            .textContentType(keyboardType == .emailAddress ? .emailAddress : .none)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(error.isEmpty ? Color.clear : Color.red, lineWidth: 1)
            )
            
            if !error.isEmpty {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(.leading, 40)
            }
        }
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .foregroundColor(Color(hex: "#438883"))
                
                Text("Updating Profile...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
        }
    }
}

#Preview {
    PreviewWrapper {
        EditProfileView()
    }
}

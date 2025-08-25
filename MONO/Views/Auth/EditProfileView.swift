//
//  EditProfileView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var phoneNumber: String
    @State private var isLoading = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showImagePicker = false
    
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
        self._firstName = State(initialValue: authManager.currentUser?.firstName ?? "")
        self._lastName = State(initialValue: authManager.currentUser?.lastName ?? "")
        self._phoneNumber = State(initialValue: authManager.currentUser?.phoneNumber ?? "")
        // Load existing profile image if available
        if let imageData = authManager.currentUser?.profileImageData {
            self._selectedImageData = State(initialValue: imageData)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Avatars porfile pic
                    VStack(spacing: 16) {
                        Button(action: {
                            showImagePicker = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.monoPrimary.opacity(0.8),
                                                Color.monoPrimary.opacity(0.6)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .shadow(color: Color.monoPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                if let imageData = selectedImageData,
                                   let uiImage = UIImage(data: imageData) {
                                    // show selected/saved image
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .shadow(color: Color.monoPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                                } else {
                                    // Default static profile icon
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                
                                // Camera icon overlay
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Circle()
                                            .fill(Color.monoPrimary)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.white)
                                            )
                                            .offset(x: -8, y: -8)
                                    }
                                }
                                .frame(width: 120, height: 120)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        VStack(spacing: 8) {
                            Text("Profile Picture")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.monoPrimary)
                            
                            Text("Tap to change photo")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
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
        .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }
    
    private var hasChanges: Bool {
        firstName != (authManager.currentUser?.firstName ?? "") ||
        lastName != (authManager.currentUser?.lastName ?? "") ||
        phoneNumber != (authManager.currentUser?.phoneNumber ?? "") ||
        selectedImageData != authManager.currentUser?.profileImageData
    }
    
    private func saveProfile() {
        isLoading = true
        
        // Simulate save delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            authManager.updateUserProfile(
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                profileImageData: selectedImageData
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

//
//  ProfileView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-16.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingLogoutAlert = false
    @State private var showingAccountInfo = false
    @State private var showingPersonalProfile = false
    @State private var showingMessageCenter = false
    @State private var showingLoginSecurity = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with profile image
                VStack(spacing: 0) {
                    // Profile Header Background
                    Rectangle()
                        .fill(Color(hex: "#438883"))
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 16) {
                                // Profile Image
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Circle()
                                            .fill(Color.orange.opacity(0.2))
                                            .frame(width: 90, height: 90)
                                            .overlay(
                                                // User Avatar or Initials
                                                Group {
                                                    if let name = authManager.currentUser?.name, !name.isEmpty {
                                                        Text(String(name.prefix(1)).uppercased())
                                                            .font(.system(size: 32, weight: .bold))
                                                            .foregroundColor(Color.orange)
                                                    } else {
                                                        Image(systemName: "person.fill")
                                                            .font(.system(size: 32))
                                                            .foregroundColor(Color.orange)
                                                    }
                                                }
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                
                                // User Name
                                Text(authManager.currentUser?.name ?? "User")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 40)
                        )
                }
                
                // Profile Options List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Account Info
                        ProfileMenuItem(
                            icon: "person.circle",
                            title: "Account info",
                            showChevron: true
                        ) {
                            showingAccountInfo = true
                        }
                        
                        ProfileMenuDivider()
                        
                        // Personal Profile
                        ProfileMenuItem(
                            icon: "person.2",
                            title: "Personal profile",
                            showChevron: true
                        ) {
                            showingPersonalProfile = true
                        }
                        
                        ProfileMenuDivider()
                        
                        // Message Center
                        ProfileMenuItem(
                            icon: "envelope",
                            title: "Message center",
                            showChevron: true
                        ) {
                            showingMessageCenter = true
                        }
                        
                        ProfileMenuDivider()
                        
                        // Login and Security
                        ProfileMenuItem(
                            icon: "shield",
                            title: "Login and security",
                            showChevron: true
                        ) {
                            showingLoginSecurity = true
                        }
                        
                        ProfileMenuDivider()
                        
                        // Settings
                        ProfileMenuItem(
                            icon: "gear",
                            title: "Settings",
                            showChevron: true
                        ) {
                            showingSettings = true
                        }
                        
                        ProfileMenuDivider()
                        
                        // Logout Button
                        ProfileMenuItem(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Logout",
                            showChevron: false,
                            titleColor: .red,
                            iconColor: .red
                        ) {
                            showingLogoutAlert = true
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, -50) // Overlap with header
                }
                .background(Color(UIColor.systemGray6))
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("profile")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Notification action
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(Color(hex: "#438883"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .navigationBarHidden(true)
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .sheet(isPresented: $showingAccountInfo) {
            AccountInfoView()
        }
        .sheet(isPresented: $showingPersonalProfile) {
            PersonalProfileView()
        }
        .sheet(isPresented: $showingMessageCenter) {
            MessageCenterView()
        }
        .sheet(isPresented: $showingLoginSecurity) {
            LoginSecurityView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - Profile Menu Item
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let showChevron: Bool
    let titleColor: Color
    let iconColor: Color
    let action: () -> Void
    
    init(
        icon: String,
        title: String,
        showChevron: Bool = true,
        titleColor: Color = .primary,
        iconColor: Color = .gray,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.showChevron = showChevron
        self.titleColor = titleColor
        self.iconColor = iconColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                // Title
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(titleColor)
                
                Spacer()
                
                // Chevron
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Profile Menu Divider
struct ProfileMenuDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 0.5)
            .padding(.leading, 60) // Align with text, not icon
    }
}

// MARK: - Account Info View
struct AccountInfoView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Profile Image Section
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color(hex: "#438883").opacity(0.1))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(authManager.currentUser?.name?.prefix(1).uppercased() ?? "U")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(Color(hex: "#438883"))
                        )
                    
                    Button(action: {
                        // Change photo action
                    }) {
                        Text("Change Photo")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#438883"))
                    }
                }
                .padding(.top, 20)
                
                // Account Information
                VStack(spacing: 16) {
                    AccountInfoRow(label: "Username", value: authManager.currentUser?.username ?? "")
                    AccountInfoRow(label: "Name", value: authManager.currentUser?.name ?? "")
                    AccountInfoRow(label: "Email", value: authManager.currentUser?.email ?? "")
                    AccountInfoRow(label: "Member since", value: formatDate(authManager.currentUser?.createdAt))
                }
                
                Spacer()
                
                // Edit Button
                Button(action: {
                    showingEditProfile = true
                }) {
                    Text("Edit Profile")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#438883"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Account Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Account Info Row
struct AccountInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(8)
        .padding(.horizontal, 20)
    }
}

// MARK: - Placeholder Views
struct PersonalProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Personal Profile")
                    .font(.title2)
                    .padding()
                
                Text("This feature will be implemented soon.")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("Personal Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MessageCenterView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Message Center")
                    .font(.title2)
                    .padding()
                
                Text("No messages at this time.")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("Message Center")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LoginSecurityView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Login and Security")
                    .font(.title2)
                    .padding()
                
                Text("Security settings will be available here.")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("Login & Security")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PreviewWrapper {
        ProfileView()
    }
}

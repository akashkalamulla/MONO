//
//  AuthenticatedView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import SwiftUI

struct AuthenticatedView: View {
    @ObservedObject var authManager: AuthenticationManager
    
    var body: some View {
        TabView {
            DashboardView(authManager: authManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            TransactionsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transactions")
                }
            
            BudgetView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Budget")
                }
            
            ProfileView(authManager: authManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.monoPrimary)
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @ObservedObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome back,")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            
                            Text(authManager.currentUser?.firstName ?? "User")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.monoPrimary)
                        }
                        
                        Spacer()
                        
                        // Profile Avatar
                        Circle()
                            .fill(Color.monoPrimary.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(authManager.currentUser?.firstName.prefix(1) ?? "U")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.monoPrimary)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Balance Card
                    VStack(spacing: 16) {
                        Text("Total Balance")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("$2,847.50")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("Income")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                Text("$3,250.00")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack {
                                Text("Expenses")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                Text("$402.50")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.monoPrimary, Color.monoSecondary]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.monoPrimary)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            QuickActionButton(
                                icon: "plus.circle.fill",
                                title: "Add Income",
                                action: { /* Add income */ }
                            )
                            
                            QuickActionButton(
                                icon: "minus.circle.fill",
                                title: "Add Expense",
                                action: { /* Add expense */ }
                            )
                            
                            QuickActionButton(
                                icon: "chart.bar.fill",
                                title: "View Report",
                                action: { /* View report */ }
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.monoPrimary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.monoPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

// MARK: - Placeholder Views
struct TransactionsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "list.bullet")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("Transactions")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.monoPrimary)
                
                Text("Track your income and expenses")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("Transactions")
        }
    }
}

struct BudgetView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("Budget")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.monoPrimary)
                
                Text("Plan and manage your budget")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("Budget")
        }
    }
}

struct ProfileView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var showEditProfile = false
    @State private var showDebugView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Profile Header
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.monoPrimary.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(authManager.currentUser?.firstName.prefix(1) ?? "U")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.monoPrimary)
                        )
                    
                    VStack(spacing: 4) {
                        Text(authManager.currentUser?.fullName ?? "Unknown User")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.monoPrimary)
                        
                        Text(authManager.currentUser?.email ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                // Profile Options
                VStack(spacing: 0) {
                    ProfileOption(icon: "person.fill", title: "Edit Profile") {
                        showEditProfile = true
                    }
                    ProfileOption(icon: "bell.fill", title: "Notifications") { }
                    ProfileOption(icon: "lock.fill", title: "Privacy & Security") { }
                    ProfileOption(icon: "questionmark.circle.fill", title: "Help & Support") { }
                    
                    #if DEBUG
                    ProfileOption(icon: "hammer.fill", title: "Debug Core Data") {
                        showDebugView = true
                    }
                    #endif
                }
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Logout Button
                Button(action: {
                    authManager.logout()
                }) {
                    Text("Sign Out")
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
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(authManager: authManager)
        }
        .sheet(isPresented: $showDebugView) {
            CoreDataDebugView()
        }
    }
}

struct ProfileOption: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.monoPrimary)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.monoPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

#Preview {
    let authManager = AuthenticationManager()
    authManager.currentUser = User(firstName: "John", lastName: "Doe", email: "john@example.com")
    authManager.isAuthenticated = true
    
    return AuthenticatedView(authManager: authManager)
}

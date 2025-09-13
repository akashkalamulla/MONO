//
//  AuthenticatedView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import Foundation
import SwiftUI

struct AuthenticatedView: View {
    @ObservedObject var authManager: AuthenticationManager
    @StateObject private var dependentManager = DependentManager()
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        TabView {
            DashboardView(authManager: authManager, dependentManager: dependentManager, notificationManager: notificationManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            FinanceView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Finance")
                }
            
            ExpenseLocationMapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Locations")
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Statistics")
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

struct DashboardView: View {
    @ObservedObject var authManager: AuthenticationManager
    @ObservedObject var dependentManager: DependentManager
    @ObservedObject var notificationManager: NotificationManager
    @StateObject private var coreDataStack = CoreDataStack.shared
    @State private var showIncomeView = false
    @State private var showExpenseView = false
    @State private var showOCRExpenseView = false
    @State private var showAddDependent = false
    @State private var selectedDependent: Dependent?
    @State private var showDependentDetail = false
    @State private var showAllDependents = false
    @State private var totalIncome: Double = 0
    @State private var totalExpenses: Double = 0
    @State private var totalBalance: Double = 0
    @State private var showNotifications = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
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
                        
                        Button(action: {
                            showNotifications = true
                        }) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.monoPrimary)
                                .overlay(
                                    // Notification badge - only show if there are unread notifications
                                    Group {
                                        if notificationManager.hasUnreadNotifications {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 8, height: 8)
                                                .offset(x: 8, y: -8)
                                        }
                                    }
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        Text("Total Balance")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(formatCurrency(totalBalance))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("Income")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                Text(formatCurrency(totalIncome))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack {
                                Text("Expenses")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                Text(formatCurrency(totalExpenses))
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
                    
                    if !dependentManager.dependents.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            if dependentManager.dependents.filter({ $0.isActive }).isEmpty {
                                VStack(spacing: 8) {
                                    Text("No dependents added yet")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    Button("Add First Dependent") {
                                        showAddDependent = true
                                    }
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.monoPrimary)
                                }
                                .padding()
                            } else {
                                HStack {
                                    Text("Recent Dependents")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Text("\(dependentManager.dependents.filter { $0.isActive }.count)")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.monoPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 4)
                                        .background(Color.monoPrimary.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(dependentManager.dependents.filter { $0.isActive }.prefix(5)) { dependent in
                                            DependentSummaryCard(dependent: dependent) {
                                                print("🔄 [DashboardView] Tapping dependent: \(dependent.firstName)")
                                                selectedDependent = dependent
                                                showDependentDetail = true
                                                print("🔄 [DashboardView] showDependentDetail set to: \(showDependentDetail)")
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                Button(action: {
                                    showAllDependents = true
                                }) {
                                    HStack {
                                        Text("See All Dependents")
                                            .font(.system(size: 14, weight: .medium))
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(.monoPrimary)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.monoPrimary)
                            .padding(.horizontal)
                        
                        // First row - 3 buttons horizontally
                        HStack(spacing: 15) {
                            // Add Income Button
                            Button(action: { showIncomeView = true }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.monoPrimary)
                                    
                                    Text("Add Income")
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
                            
                            // Add Expense Button
                            Button(action: { showExpenseView = true }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.monoPrimary)
                                    
                                    Text("Add Expense")
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
                            
                            // Scan Receipt Button
                            Button(action: { showOCRExpenseView = true }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 24))
                                        .foregroundColor(.monoPrimary)
                                    
                                    Text("Scan Receipt")
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
                        .padding(.horizontal)
                        
                        // Second row - Full width Add Dependent button
                        Button(action: { showAddDependent = true }) {
                            VStack(spacing: 8) {
                                Image(systemName: "person.2.badge.plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(.monoPrimary)
                                
                                Text("Add Dependent")
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
                        .padding(.horizontal)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            if let currentUser = authManager.currentUser {
                dependentManager.loadDependents(for: currentUser.id)
                loadFinancialData()
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated, let currentUser = authManager.currentUser {
                print("🔄 [AuthenticatedView] User authenticated, loading dependents for user: \(currentUser.id)")
                dependentManager.loadDependents(for: currentUser.id)
                loadFinancialData()
            }
        }
        .onChange(of: authManager.currentUser?.id) { _, userId in
            if let userId = userId {
                print("🔄 [AuthenticatedView] Current user changed, loading dependents for user: \(userId)")
                dependentManager.loadDependents(for: userId)
                loadFinancialData()
            }
        }
        .sheet(isPresented: $showIncomeView, onDismiss: {
            loadFinancialData()
        }) {
            NavigationView {
                SimpleIncomeEntry()
            }
        }
        .sheet(isPresented: $showExpenseView, onDismiss: {
            loadFinancialData()
        }) {
            NavigationView {
                SimpleExpenseEntry()
            }
        }
        .fullScreenCover(isPresented: $showOCRExpenseView, onDismiss: {
            loadFinancialData()
        }) {
            OCRExpenseEntry()
        }
        .sheet(isPresented: $showAddDependent) {
            AddDependentView(dependentManager: dependentManager, authManager: authManager)
        }
        .sheet(isPresented: $showDependentDetail) {
            NavigationView {
                if let selectedDependent = selectedDependent {
                    DependentDetailView(
                        dependent: selectedDependent,
                        dependentManager: dependentManager
                    )
                } else {

                    let testDependent = Dependent(
                        firstName: "Test",
                        lastName: "User",
                        relationship: "Child",
                        dateOfBirth: Calendar.current.date(byAdding: .year, value: -10, to: Date()) ?? Date(),
                        phoneNumber: "123-456-7890",
                        email: "test@example.com",
                        userId: UUID()
                    )
                    DependentDetailView(
                        dependent: testDependent,
                        dependentManager: dependentManager
                    )
                }
            }
        }
        .sheet(isPresented: $showAllDependents) {
            NavigationView {
                DependentsView(dependentManager: dependentManager, authManager: authManager)
            }
        }
        .sheet(isPresented: $showNotifications) {
            NotificationView()
        }
    }
    
    private func loadFinancialData() {
        guard let currentUserEntity = coreDataStack.fetchCurrentUser() else {
            print("Error: No current user found")
            return
        }
        
        let incomeEntities = coreDataStack.fetchIncomes(for: currentUserEntity)
        totalIncome = incomeEntities.reduce(0) { $0 + $1.amount }

        let expenseEntities = coreDataStack.fetchExpenses(for: currentUserEntity)
        totalExpenses = expenseEntities.reduce(0) { $0 + $1.amount }
        
        totalBalance = totalIncome - totalExpenses
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rs. "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "Rs. 0.00"
    }
}

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
                
                Text("Track your expenses and budget")
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
    @State private var showPrivacySecurity = false
    @State private var showHelpSupport = false
    @State private var showBackupView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
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
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.monoPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        if let imageData = authManager.currentUser?.profileImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(color: Color.monoPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text(authManager.currentUser?.fullName ?? "Unknown User")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.monoPrimary)
                        
                        Text(authManager.currentUser?.email ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(spacing: 0) {
                    ProfileOption(icon: "person.fill", title: "Edit Profile") {
                        showEditProfile = true
                    }
                    ProfileOption(icon: "bell.fill", title: "Notifications") { }
                    ProfileOption(icon: "lock.fill", title: "Privacy & Security") {
                        showPrivacySecurity = true
                    }
                    ProfileOption(icon: "questionmark.circle.fill", title: "Help & Support") {
                        showHelpSupport = true
                    }
                    ProfileOption(icon: "arrow.clockwise", title: "Backup & Sync") {
                        showBackupView = true
                    }
                }
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal)
                
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
        .sheet(isPresented: $showPrivacySecurity) {
            PrivacySecurityView()
        }
        .sheet(isPresented: $showHelpSupport) {
            HelpSupportView()
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

struct DependentSummaryCard: View {
    let dependent: Dependent
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.monoPrimary.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(dependent.initials)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.monoPrimary)
                )
            
            VStack(spacing: 2) {
                Text(dependent.firstName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.monoPrimary)
                    .lineLimit(1)
                
                Text(dependent.relationship)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 80)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(isPressed ? 0.2 : 0.1), radius: isPressed ? 5 : 3, x: 0, y: isPressed ? 3 : 1)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            print("🔄 [DependentCard] Tapped dependent: \(dependent.firstName)")
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}



#Preview {
    let authManager = AuthenticationManager()
    authManager.currentUser = User(firstName: "John", lastName: "Doe", email: "john@example.com")
    authManager.isAuthenticated = true
    
    return AuthenticatedView(authManager: authManager)
        .environmentObject(AuthenticationManager())
}

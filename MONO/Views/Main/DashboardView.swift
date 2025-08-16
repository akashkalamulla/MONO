//
//  DashboardView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-16.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Main Content
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header Card with Balance
                            BalanceHeaderCard(user: authManager.currentUser)
                                .padding(.horizontal, 16)
                                .padding(.top, 20)
                            
                            // Main Content Area
                            VStack(spacing: 24) {
                                // Dependents Section
                                DependentsSection()
                                
                                // Income History Section
                                IncomeHistorySection()
                                
                                // Spending History Section
                                SpendingHistorySection()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                            .padding(.bottom, 100) // Space for tab bar
                        }
                    }
                    
                    Spacer()
                    
                    // Bottom Tab Bar
                    CustomTabBar()
                }
                .background(Color(UIColor.systemGray6))
            }
            .navigationBarHidden(true)
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
}

// MARK: - Balance Header Card
struct BalanceHeaderCard: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with greeting and notification
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Good afternoon,")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(user?.name ?? "User")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: {
                    // Notification action
                }) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            // Total Balance
            VStack(spacing: 8) {
                HStack {
                    Text("Total Balance")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Image(systemName: "chevron.up")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Text("Rs 2,548.00")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 16)
            
            // Income and Expenses
            HStack(spacing: 0) {
                // Income
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Income")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("Rs 58,840.00")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Expenses
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Expenses")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("Rs 35,284.00")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
        .background(Color(hex: "#438883"))
        .cornerRadius(16)
    }
}

// MARK: - Dependents Section
struct DependentsSection: View {
    var body: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Text("Dependents")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // See all dependents
                }) {
                    Text("See all")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            // Dependents List
            HStack(spacing: 16) {
                // Add Dependent Button
                VStack(spacing: 8) {
                    Circle()
                        .fill(Color(hex: "#438883"))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 2) {
                        Text("Add")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("Dependent")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 80)
                
                // Sample Dependent
                VStack(spacing: 8) {
                    Circle()
                        .fill(Color.red.opacity(0.8))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text("SK")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 2) {
                        Text("Son")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("kasun")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 80)
                
                Spacer()
            }
        }
    }
}

// MARK: - Income History Section
struct IncomeHistorySection: View {
    var body: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Text("Income History")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // See all income
                }) {
                    Text("See all")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            // Income Items
            VStack(spacing: 12) {
                IncomeHistoryRow(
                    title: "Upwork",
                    date: "Today",
                    amount: "+ $ 850.00",
                    icon: "briefcase.fill",
                    iconColor: .green
                )
                
                IncomeHistoryRow(
                    title: "Salary",
                    date: "Jan 30, 2022",
                    amount: "+ Rs. 75,000.00",
                    icon: "banknote.fill",
                    iconColor: .blue
                )
            }
        }
    }
}

// MARK: - Spending History Section
struct SpendingHistorySection: View {
    var body: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Text("Spending History")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // See all spending
                }) {
                    Text("See all")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            // Spending Items
            VStack(spacing: 12) {
                SpendingHistoryRow(
                    title: "Current Bill",
                    date: "Jan 30, 2022",
                    amount: "- Rs. 5,000.00",
                    icon: "bolt.fill",
                    iconColor: .orange
                )
            }
        }
    }
}

// MARK: - Income History Row
struct IncomeHistoryRow: View {
    let title: String
    let date: String
    let amount: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(iconColor.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount
            Text(amount)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Spending History Row
struct SpendingHistoryRow: View {
    let title: String
    let date: String
    let amount: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(iconColor.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount
            Text(amount)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @State private var selectedTab = 0
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == 0,
                color: Color(hex: "#438883")
            ) {
                selectedTab = 0
            }
            
            TabBarItem(
                icon: "chart.line.uptrend.xyaxis",
                title: "Statistics",
                isSelected: selectedTab == 1,
                color: .gray
            ) {
                selectedTab = 1
            }
            
            TabBarItem(
                icon: "plus.circle.fill",
                title: "Add Expenses",
                isSelected: selectedTab == 2,
                color: .gray,
                isCenter: true
            ) {
                selectedTab = 2
            }
            
            TabBarItem(
                icon: "location.fill",
                title: "Location",
                isSelected: selectedTab == 3,
                color: .gray
            ) {
                selectedTab = 3
            }
            
            TabBarItem(
                icon: "person.circle.fill",
                title: "profile",
                isSelected: selectedTab == 4,
                color: .gray
            ) {
                selectedTab = 4
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 34) // Safe area bottom
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let color: Color
    let isCenter: Bool
    let action: () -> Void
    
    init(icon: String, title: String, isSelected: Bool, color: Color, isCenter: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.isSelected = isSelected
        self.color = color
        self.isCenter = isCenter
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: isCenter ? 24 : 20, weight: .medium))
                    .foregroundColor(isSelected ? Color(hex: "#438883") : color)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? Color(hex: "#438883") : color)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    PreviewWrapper {
        DashboardView()
    }
}

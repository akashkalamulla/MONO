//
//  UserGuideDetailViews.swift
//  MONO
//
//  Created by Akash01 on 2025-09-03.
//

import SwiftUI

struct GuideHeader: View {
    let title: String
    let iconName: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.system(size: 36))
                .foregroundColor(iconColor)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading, 8)
        }
        .padding(.bottom)
    }
}

struct GuideStep: View {
    let number: Int
    let title: String
    let description: String
    let iconName: String?
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Text("\(number)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct GuideInfoBox: View {
    let title: String
    let content: String
    let color: Color
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
            }
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}


struct GettingStartedView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHeader(
                    title: "Getting Started",
                    iconName: "play.circle.fill",
                    iconColor: .green
                )
                
                Text("Welcome to MONO! Follow these steps to set up your account and start managing your finances effectively.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                GuideStep(
                    number: 1,
                    title: "Create Your Account",
                    description: "Start by registering a new account with your email address, or sign in with your existing credentials if you already have an account.",
                    iconName: "person.crop.circle.fill.badge.plus"
                )
                
                GuideStep(
                    number: 2,
                    title: "Set Up Your Profile",
                    description: "Add your personal details and preferences. This helps us customize the app experience for your specific needs.",
                    iconName: "person.text.rectangle"
                )
                
                GuideStep(
                    number: 3,
                    title: "Enable Security Features",
                    description: "Configure biometric authentication (Face ID or Touch ID) to keep your financial information secure and easily accessible.",
                    iconName: "faceid"
                )
                
                GuideInfoBox(
                    title: "Pro Tip",
                    content: "Take a few minutes to explore the app's navigation. The main tabs at the bottom provide quick access to all major features.",
                    color: .green,
                    iconName: "lightbulb.fill"
                )
                
                Divider()
                    .padding(.vertical)
                
                Text("Initial Setup Checklist")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    ChecklistItem(text: "Create account")
                    ChecklistItem(text: "Add profile information")
                    ChecklistItem(text: "Set up biometric security")
                    ChecklistItem(text: "Add first income source")
                    ChecklistItem(text: "Add recurring expenses")
                }
            }
            .padding()
        }
        .navigationTitle("Getting Started")
    }
}

struct ManagingIncomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHeader(
                    title: "Managing Income",
                    iconName: "dollarsign.circle.fill",
                    iconColor: .blue
                )
                
                Text("Track and categorize all your income sources to get a clear picture of your financial inflows.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                GuideStep(
                    number: 1,
                    title: "Add a New Income Source",
                    description: "Navigate to the Income tab and tap the '+' button in the top right corner to add a new income entry.",
                    iconName: "plus.circle.fill"
                )
                
                GuideStep(
                    number: 2,
                    title: "Enter Income Details",
                    description: "Specify the amount, source, frequency (one-time, weekly, monthly, etc.), and date received.",
                    iconName: "list.bullet.rectangle"
                )
                
                GuideStep(
                    number: 3,
                    title: "Categorize Your Income",
                    description: "Select a category (e.g., Salary, Freelance, Investment, etc.) to organize your income streams.",
                    iconName: "tag.fill"
                )
                
                GuideStep(
                    number: 4,
                    title: "Set Up Recurring Income",
                    description: "For regular income like salary, set it as recurring so you don't have to add it manually each time.",
                    iconName: "arrow.clockwise.circle.fill"
                )
                
                GuideInfoBox(
                    title: "Income Insights",
                    content: "Use the Income Analysis view to see patterns in your earnings and identify opportunities for income growth.",
                    color: .blue,
                    iconName: "chart.bar.fill"
                )
                
                Divider()
                    .padding(.vertical)
                
                Text("Income Categories")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    CategoryPill(name: "Salary", color: .blue)
                    CategoryPill(name: "Freelance", color: .purple)
                    CategoryPill(name: "Investments", color: .green)
                    CategoryPill(name: "Rental Income", color: .orange)
                    CategoryPill(name: "Business", color: .red)
                    CategoryPill(name: "Other", color: .gray)
                }
            }
            .padding()
        }
        .navigationTitle("Managing Income")
    }
}

struct TrackingExpensesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHeader(
                    title: "Tracking Expenses",
                    iconName: "minus.circle.fill",
                    iconColor: .red
                )
                
                Text("Monitor and control your spending by tracking all your expenses in one place.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                GuideStep(
                    number: 1,
                    title: "Record a New Expense",
                    description: "Tap the '+' button on the Expenses tab to add a new expense. For quick entry, use the OCR feature to scan receipts.",
                    iconName: "camera.fill"
                )
                
                GuideStep(
                    number: 2,
                    title: "Categorize Expenses",
                    description: "Assign each expense to a category like Groceries, Utilities, or Entertainment to better understand where your money goes.",
                    iconName: "folder.fill"
                )
                
                GuideStep(
                    number: 3,
                    title: "Add Location Data",
                    description: "Optionally, add location information to your expenses to track spending by place and view on the map.",
                    iconName: "mappin.circle.fill"
                )
                
                GuideStep(
                    number: 4,
                    title: "Set Budgets",
                    description: "Create monthly budgets for different expense categories to help control spending and reach financial goals.",
                    iconName: "banknote.fill"
                )
                
                GuideInfoBox(
                    title: "Smart Tip",
                    content: "Take photos of receipts right away - this makes expense tracking more accurate and helps you claim tax deductions if applicable.",
                    color: .red,
                    iconName: "lightbulb.fill"
                )
                
                Divider()
                    .padding(.vertical)
                
                Text("Expense Categories")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    CategoryPill(name: "Housing", color: .blue)
                    CategoryPill(name: "Groceries", color: .green)
                    CategoryPill(name: "Transportation", color: .orange)
                    CategoryPill(name: "Utilities", color: .purple)
                    CategoryPill(name: "Entertainment", color: .pink)
                    CategoryPill(name: "Healthcare", color: .red)
                    CategoryPill(name: "Education", color: .yellow)
                    CategoryPill(name: "Shopping", color: .mint)
                }
            }
            .padding()
        }
        .navigationTitle("Tracking Expenses")
    }
}

struct AddingDependentsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHeader(
                    title: "Adding Dependents",
                    iconName: "person.2.circle.fill",
                    iconColor: .purple
                )
                
                Text("Include family members in your financial planning and track expenses for each person separately.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                GuideStep(
                    number: 1,
                    title: "Add a Dependent",
                    description: "Go to the Dependents tab and tap 'Add Dependent' to create a profile for a family member.",
                    iconName: "person.badge.plus"
                )
                
                GuideStep(
                    number: 2,
                    title: "Enter Dependent Details",
                    description: "Add their name, relationship to you, date of birth, and optionally a photo.",
                    iconName: "person.text.rectangle"
                )
                
                GuideStep(
                    number: 3,
                    title: "Track Dependent-Specific Expenses",
                    description: "When adding expenses, you can assign them to a specific dependent to track costs for each family member.",
                    iconName: "creditcard.fill"
                )
                
                GuideStep(
                    number: 4,
                    title: "Set Dependent Budgets",
                    description: "Create separate budgets for each dependent to manage spending allocations for different family members.",
                    iconName: "chart.pie.fill"
                )
                
                GuideInfoBox(
                    title: "Family Planning",
                    content: "Use the Dependents feature to plan for future expenses like education, healthcare, and other family-related costs.",
                    color: .purple,
                    iconName: "calendar.badge.clock"
                )
                
                Divider()
                    .padding(.vertical)
                
                Text("Dependent Expense Categories")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    CategoryPill(name: "Education", color: .blue)
                    CategoryPill(name: "Healthcare", color: .red)
                    CategoryPill(name: "Clothing", color: .purple)
                    CategoryPill(name: "Activities", color: .green)
                    CategoryPill(name: "Allowance", color: .orange)
                    CategoryPill(name: "Other", color: .gray)
                }
            }
            .padding()
        }
        .navigationTitle("Adding Dependents")
    }
}


struct SecurityFeaturesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHeader(
                    title: "Security Features",
                    iconName: "shield.fill",
                    iconColor: .orange
                )
                
                Text("Keep your financial data safe and secure with MONO's built-in security features.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                GuideStep(
                    number: 1,
                    title: "Enable Biometric Authentication",
                    description: "Go to Settings > Privacy & Security and toggle on Face ID or Touch ID for secure and convenient access to your account.",
                    iconName: "faceid"
                )
                
                GuideStep(
                    number: 2,
                    title: "Set Up a Strong Password",
                    description: "Create a unique password with at least 8 characters, including numbers, symbols, and mixed case letters.",
                    iconName: "lock.fill"
                )
                
                GuideStep(
                    number: 3,
                    title: "Configure Data Backup",
                    description: "Enable automatic backups to iCloud to ensure your financial data is never lost and can be restored if needed.",
                    iconName: "icloud.fill"
                )
                
                GuideStep(
                    number: 4,
                    title: "Control Data Sharing",
                    description: "Manage what information is shared for analytics and personalization in the Privacy settings.",
                    iconName: "hand.raised.fill"
                )
                
                GuideInfoBox(
                    title: "Security Reminder",
                    content: "MONO never stores your bank credentials. We use bank-level encryption to protect all your sensitive information.",
                    color: .orange,
                    iconName: "exclamationmark.shield.fill"
                )
                
                Divider()
                    .padding(.vertical)
                
                Text("Security Best Practices")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    ChecklistItem(text: "Update the app regularly")
                    ChecklistItem(text: "Never share your password")
                    ChecklistItem(text: "Enable app lock when not in use")
                    ChecklistItem(text: "Review account activity regularly")
                    ChecklistItem(text: "Use secure networks for financial tasks")
                }
            }
            .padding()
        }
        .navigationTitle("Security Features")
    }
}


struct ReportsStatisticsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHeader(
                    title: "Reports & Statistics",
                    iconName: "chart.bar.fill",
                    iconColor: .indigo
                )
                
                Text("Analyze your financial data with powerful reports and visual statistics to make informed decisions.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                GuideStep(
                    number: 1,
                    title: "View Monthly Summary",
                    description: "Access the Statistics tab to see your monthly income vs. expenses, savings rate, and budget adherence.",
                    iconName: "calendar"
                )
                
                GuideStep(
                    number: 2,
                    title: "Analyze Spending Trends",
                    description: "Explore spending patterns over time with interactive charts showing your expenses by category or time period.",
                    iconName: "chart.xyaxis.line"
                )
                
                GuideStep(
                    number: 3,
                    title: "Track Financial Goals",
                    description: "Monitor progress toward savings goals, debt reduction, or other financial objectives you've set.",
                    iconName: "flag.fill"
                )
                
                GuideStep(
                    number: 4,
                    title: "Generate Custom Reports",
                    description: "Create personalized reports for specific date ranges, categories, or dependents to gain deeper insights.",
                    iconName: "doc.text.magnifyingglass"
                )
                
                GuideInfoBox(
                    title: "Data Insights",
                    content: "Look for the AI-powered insights feature that highlights unusual spending patterns and suggests ways to improve your financial health.",
                    color: .indigo,
                    iconName: "sparkles"
                )
                
                Divider()
                    .padding(.vertical)
                
                Text("Available Report Types")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ReportTypePill(name: "Monthly Summary", iconName: "calendar")
                    ReportTypePill(name: "Category Analysis", iconName: "folder")
                    ReportTypePill(name: "Savings Report", iconName: "arrow.up.right")
                    ReportTypePill(name: "Budget Tracking", iconName: "chart.pie")
                    ReportTypePill(name: "Tax Report", iconName: "doc.text")
                    ReportTypePill(name: "Annual Overview", iconName: "clock.arrow.circlepath")
                }
            }
            .padding()
        }
        .navigationTitle("Reports & Statistics")
    }
}


struct ChecklistItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text(text)
                .font(.body)
        }
    }
}

struct CategoryPill: View {
    let name: String
    let color: Color
    
    var body: some View {
        Text(name)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(16)
    }
}

struct ReportTypePill: View {
    let name: String
    let iconName: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.system(size: 12))
            
            Text(name)
                .font(.system(size: 14, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.indigo)
        .cornerRadius(16)
    }
}


struct UserGuideDetailViews_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GettingStartedView()
        }
    }
}

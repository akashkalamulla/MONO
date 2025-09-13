//
//  HelpSupportView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-23.
//

import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingFAQ = false
    @State private var showingUserGuide = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingVideoTutorials = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {

                if !searchText.isEmpty {
                    Section {
                        SearchResultsView(searchText: searchText)
                    }
                } else {
  
                    Section {
                        QuickHelpRow(
                            icon: "questionmark.circle.fill",
                            iconColor: .blue,
                            title: "Frequently Asked Questions",
                            subtitle: "Find answers to common questions"
                        ) {
                            showingFAQ = true
                        }
                        
                        QuickHelpRow(
                            icon: "book.fill",
                            iconColor: .green,
                            title: "User Guide",
                            subtitle: "Learn how to use MONO effectively"
                        ) {
                            showingUserGuide = true
                        }
                        
                        QuickHelpRow(
                            icon: "play.circle.fill",
                            iconColor: .orange,
                            title: "Video Tutorials",
                            subtitle: "Watch step-by-step guides"
                        ) {
                            showingVideoTutorials = true
                        }
                    } header: {
                        Text("Quick Help")
                    }
                    
              
                    // Contact & support entry removed — handled externally or by other feedback flows
                    
             
                    Section {
                        QuickHelpRow(
                            icon: "star.fill",
                            iconColor: .orange,
                            title: "Rate Our App",
                            subtitle: "Share your experience on the App Store"
                        ) {
                            rateApp()
                        }
                    } header: {
                        Text("Feedback")
                    }
                    
               
                    Section {
                        QuickHelpRow(
                            icon: "person.circle.fill",
                            iconColor: .blue,
                            title: "Account Help",
                            subtitle: "Manage your account settings"
                        ) {
                         
                        }
                        
                        QuickHelpRow(
                            icon: "shield.fill",
                            iconColor: .green,
                            title: "Privacy Policy",
                            subtitle: "Learn how we protect your data"
                        ) {
                            showingPrivacyPolicy = true
                        }
                        
                        QuickHelpRow(
                            icon: "doc.text.fill",
                            iconColor: .blue,
                            title: "Terms of Service",
                            subtitle: "Read our terms and conditions"
                        ) {
                            showingTermsOfService = true
                        }
                    } header: {
                        Text("Legal & Privacy")
                    }
                    
                    Section {
                        AppInfoRow(label: "App Version", value: "1.0.0")
                        AppInfoRow(label: "Build Number", value: "2025.08.23")
                        AppInfoRow(label: "Last Updated", value: formatDate(Date()))
                        AppInfoRow(label: "Developer", value: "MONO Team")
                        
                        QuickHelpRow(
                            icon: "info.circle.fill",
                            iconColor: .blue,
                            title: "What's New",
                            subtitle: "See the latest features and updates"
                        ) {
                        }
                    } header: {
                        Text("App Information")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search help topics...")
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingFAQ) {
            FAQView()
        }
        .sheet(isPresented: $showingUserGuide) {
            UserGuideView()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingTermsOfService) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showingVideoTutorials) {
            VideoTutorialsView()
        }
        .alert("Support", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    

    // callSupport removed — phone support handled externally
    
    private func rateApp() {
        guard let appStoreURL = URL(string: "https://apps.apple.com/app/id123456789?action=write-review") else {
            alertMessage = "Unable to open App Store"
            showingAlert = true
            return
        }
        
        UIApplication.shared.open(appStoreURL)
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


struct QuickHelpRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct AppInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}


struct SearchResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search Results for \"\(searchText)\"")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            ForEach(mockSearchResults(for: searchText), id: \.self) { result in
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(result.snippet)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func mockSearchResults(for query: String) -> [SearchResult] {
        let allResults = [
            SearchResult(title: "How to add income", snippet: "Learn how to track your income in MONO app..."),
            SearchResult(title: "Managing expenses", snippet: "Tips for categorizing and tracking your expenses..."),
            SearchResult(title: "Setting up dependents", snippet: "Add family members to your financial planning..."),
            SearchResult(title: "Security settings", snippet: "Configure biometric authentication and passwords..."),
            SearchResult(title: "Privacy controls", snippet: "Manage your data and privacy preferences...")
        ]
        
        return allResults.filter { result in
            result.title.localizedCaseInsensitiveContains(query) ||
            result.snippet.localizedCaseInsensitiveContains(query)
        }
    }
}

struct SearchResult: Hashable {
    let title: String
    let snippet: String
}

struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let faqItems = [
        FAQItem(
            question: "How do I add my income information?",
            answer: "To add income, go to the Income tab and tap the '+' button. Fill in your income details including amount, frequency, and source."
        ),
        FAQItem(
            question: "How do I track my expenses?",
            answer: "Navigate to the Expenses tab and tap 'Add Expense'. Select a category, enter the amount, and add any notes if needed."
        ),
        FAQItem(
            question: "Can I add family members as dependents?",
            answer: "Yes! Go to the Dependents section and tap 'Add Dependent'. You can add family members and track their expenses separately."
        ),
        FAQItem(
            question: "How do I enable biometric authentication?",
            answer: "Go to Settings > Privacy & Security > Biometric Authentication and toggle it on. You'll need to authenticate once to enable it."
        ),
        FAQItem(
            question: "Is my financial data secure?",
            answer: "Yes, we use bank-level encryption and never store sensitive information on our servers. All data is encrypted and stored locally on your device."
        ),
        FAQItem(
            question: "How do I backup my data?",
            answer: "Your data is automatically backed up to iCloud if you have it enabled. You can also export your data from Settings > Export Data."
        )
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(faqItems.indices, id: \.self) { index in
                    FAQItemView(item: faqItems[index])
                }
            }
            .navigationTitle("Frequently Asked Questions")
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

struct FAQItem {
    let question: String
    let answer: String
}

struct FAQItemView: View {
    let item: FAQItem
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(item.question)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(item.answer)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// ContactSupportView removed — contact flows handled externally or removed per request

struct UserGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let guideItems = [
        GuideItem(
            title: "Getting Started",
            subtitle: "Set up your account and preferences",
            icon: "play.circle.fill",
            color: .green
        ),
        GuideItem(
            title: "Managing Income",
            subtitle: "Track and categorize your income sources",
            icon: "dollarsign.circle.fill",
            color: .blue
        ),
        GuideItem(
            title: "Tracking Expenses",
            subtitle: "Monitor and control your spending",
            icon: "minus.circle.fill",
            color: .red
        ),
        GuideItem(
            title: "Adding Dependents",
            subtitle: "Include family members in your planning",
            icon: "person.2.circle.fill",
            color: .purple
        ),
        GuideItem(
            title: "Security Features",
            subtitle: "Keep your data safe and secure",
            icon: "shield.fill",
            color: .orange
        ),
        GuideItem(
            title: "Reports & Statistics",
            subtitle: "Analyze your financial data",
            icon: "chart.bar.fill",
            color: .indigo
        )
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(guideItems.indices, id: \.self) { index in
                    GuideItemView(item: guideItems[index])
                }
            }
            .navigationTitle("User Guide")
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

struct GuideItem {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct GuideItemView: View {
    let item: GuideItem
    
    private var destination: AnyView {
        switch item.title {
        case "Getting Started":
            return AnyView(GettingStartedView())
        case "Managing Income":
            return AnyView(ManagingIncomeView())
        case "Tracking Expenses":
            return AnyView(TrackingExpensesView())
        case "Adding Dependents":
            return AnyView(AddingDependentsView())
        case "Security Features":
            return AnyView(SecurityFeaturesView())
        case "Reports & Statistics":
            return AnyView(ReportsStatisticsView())
        default:
            return AnyView(EmptyView())
        }
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                Image(systemName: item.icon)
                    .font(.system(size: 24))
                    .foregroundColor(item.color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(item.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// ReportBugView and FeatureRequestView removed per request

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Group {
                        PrivacySection(
                            title: "Information We Collect",
                            content: "We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support."
                        )
                        
                        PrivacySection(
                            title: "How We Use Your Information",
                            content: "We use your information to provide, maintain, and improve our services, process transactions, and communicate with you."
                        )
                        
                        PrivacySection(
                            title: "Data Security",
                            content: "We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction."
                        )
                        
                        PrivacySection(
                            title: "Your Rights",
                            content: "You have the right to access, update, or delete your personal information. You can also object to certain processing of your data."
                        )
                    }
                    
                    Text("Last updated: August 23, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
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

struct PrivacySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Group {
                        TermsSection(
                            title: "Acceptance of Terms",
                            content: "By using MONO, you agree to be bound by these Terms of Service and all applicable laws and regulations."
                        )
                        
                        TermsSection(
                            title: "Use License",
                            content: "You are granted a limited, non-exclusive license to use MONO for personal, non-commercial purposes in accordance with these terms."
                        )
                        
                        TermsSection(
                            title: "User Responsibilities",
                            content: "You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account."
                        )
                        
                        TermsSection(
                            title: "Limitation of Liability",
                            content: "MONO shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service."
                        )
                    }
                    
                    Text("Last updated: August 23, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Terms of Service")
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

struct TermsSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    HelpSupportView()
}

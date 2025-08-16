//
//  SettingsView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-16.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var notificationsEnabled = true
    @State private var biometricEnabled = false
    @State private var darkModeEnabled = false
    @State private var showingEditProfile = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    var body: some View {
        NavigationView {
            Form {
                // Account Section
                Section {
                    NavigationLink(destination: AccountInfoView()) {
                        Label("Profile Information", systemImage: "person.circle")
                    }
                    
                    NavigationLink(destination: ChangePasswordView()) {
                        Label("Change Password", systemImage: "key")
                    }
                    
                    NavigationLink(destination: EmailPreferencesView()) {
                        Label("Email Preferences", systemImage: "envelope")
                    }
                } header: {
                    Text("Account")
                }
                
                // Privacy & Security
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Push Notifications", systemImage: "bell")
                    }
                    
                    Toggle(isOn: $biometricEnabled) {
                        Label("Face ID & Passcode", systemImage: "faceid")
                    }
                    
                    Button(action: {
                        showingPrivacyPolicy = true
                    }) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        showingTermsOfService = true
                    }) {
                        Label("Terms of Service", systemImage: "doc.text")
                            .foregroundColor(.primary)
                    }
                } header: {
                    Text("Privacy & Security")
                }
                
                // App Preferences
                Section {
                    Toggle(isOn: $darkModeEnabled) {
                        Label("Dark Mode", systemImage: "moon")
                    }
                    
                    NavigationLink(destination: LanguageSettingsView()) {
                        HStack {
                            Label("Language", systemImage: "globe")
                            Spacer()
                            Text("English")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink(destination: CurrencySettingsView()) {
                        HStack {
                            Label("Currency", systemImage: "dollarsign.circle")
                            Spacer()
                            Text("USD ($)")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Preferences")
                }
                
                // Support
                Section {
                    NavigationLink(destination: HelpCenterView()) {
                        Label("Help Center", systemImage: "questionmark.circle")
                    }
                    
                    Button(action: contactSupport) {
                        Label("Contact Us", systemImage: "envelope.circle")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: rateApp) {
                        Label("Rate App", systemImage: "star")
                            .foregroundColor(.primary)
                    }
                } header: {
                    Text("Support")
                }
                
                // Account Management
                Section {
                    Button(action: exportData) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete Account", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Account Management")
                }
                
                // App Info
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2025.08.16")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("MONO Team")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingTermsOfService) {
            TermsOfServiceView()
        }
    }
    
    // MARK: - Action Methods
    private func contactSupport() {
        // Open mail app or contact form
        if let url = URL(string: "mailto:support@monoapp.com") {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        // Open App Store rating
        if let url = URL(string: "https://apps.apple.com/app/id123456789?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    private func exportData() {
        // Export user data
        print("Exporting user data...")
    }
    
    private func deleteAccount() {
        // Delete account logic
        print("Deleting account...")
    }
}

// MARK: - Placeholder Views for Navigation
struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section {
                SecureField("Current Password", text: .constant(""))
                SecureField("New Password", text: .constant(""))
                SecureField("Confirm Password", text: .constant(""))
            } header: {
                Text("Change Password")
            } footer: {
                Text("Password must be at least 6 characters long.")
            }
            
            Section {
                Button("Update Password") {
                    // Update password logic
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EmailPreferencesView: View {
    @State private var marketingEmails = true
    @State private var securityAlerts = true
    @State private var weeklyReports = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Marketing Emails", isOn: $marketingEmails)
                Toggle("Security Alerts", isOn: $securityAlerts)
                Toggle("Weekly Reports", isOn: $weeklyReports)
            } header: {
                Text("Email Notifications")
            } footer: {
                Text("Choose which emails you'd like to receive.")
            }
        }
        .navigationTitle("Email Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LanguageSettingsView: View {
    @State private var selectedLanguage = "English"
    private let languages = ["English", "Spanish", "French", "German", "Chinese", "Japanese"]
    
    var body: some View {
        Form {
            Section {
                ForEach(languages, id: \.self) { language in
                    HStack {
                        Text(language)
                        Spacer()
                        if language == selectedLanguage {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedLanguage = language
                    }
                }
            } header: {
                Text("Language")
            }
        }
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CurrencySettingsView: View {
    @State private var selectedCurrency = "USD ($)"
    private let currencies = ["USD ($)", "EUR (€)", "GBP (£)", "JPY (¥)", "CAD (C$)", "AUD (A$)"]
    
    var body: some View {
        Form {
            Section {
                ForEach(currencies, id: \.self) { currency in
                    HStack {
                        Text(currency)
                        Spacer()
                        if currency == selectedCurrency {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedCurrency = currency
                    }
                }
            } header: {
                Text("Currency")
            }
        }
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpCenterView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink("Getting Started", destination: HelpArticleView(title: "Getting Started"))
                NavigationLink("Account & Profile", destination: HelpArticleView(title: "Account & Profile"))
                NavigationLink("Privacy & Security", destination: HelpArticleView(title: "Privacy & Security"))
                NavigationLink("Troubleshooting", destination: HelpArticleView(title: "Troubleshooting"))
            } header: {
                Text("Help Topics")
            }
            
            Section {
                Button("Contact Support") {
                    // Contact support
                }
            } header: {
                Text("Need More Help?")
            }
        }
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpArticleView: View {
    let title: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("This is a help article about \(title).")
                    .font(.body)
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                    .font(.body)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Last updated: August 16, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information...")
                        .font(.body)
                    
                    // Add more privacy policy content here
                    
                    Spacer()
                }
                .padding()
            }
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

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms of Service")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Last updated: August 16, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("By using MONO, you agree to these terms and conditions...")
                        .font(.body)
                    
                    // Add more terms content here
                    
                    Spacer()
                }
                .padding()
            }
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
        SettingsView()
    }
}

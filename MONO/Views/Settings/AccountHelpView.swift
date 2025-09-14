import SwiftUI

struct AccountHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Account Help")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    
                    Text("Manage your account settings and troubleshoot common issues. Below are some helpful topics to get you started.")
                        .foregroundColor(.secondary)
                    
                    Group {
                        HelpSection(title: "Updating Profile", content: "To update your profile, go to Settings > Profile and edit your name, email, or profile picture.")
                        HelpSection(title: "Resetting Password", content: "If you forgot your password, use the 'Forgot password' flow on the login screen to request a reset email.")
                        HelpSection(title: "Two-Factor Authentication", content: "Enable two-factor authentication in Security settings to add an extra layer of protection to your account.")
                        HelpSection(title: "Deleting Your Account", content: "If you want to delete your account, contact support. Deleted accounts cannot be recovered.")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Account Help")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct HelpSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AccountHelpView()
}

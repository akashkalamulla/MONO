import SwiftUI

struct PrivacySecurityView: View {
    @StateObject private var biometricManager = BiometricAuthManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingPasswordUpdate = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    BiometricAuthenticationRow()
                } header: {
                    Text("Biometric Authentication")
                } footer: {
                    if biometricManager.isAvailable {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Use \(biometricManager.biometricTypeDescription) to quickly and securely access your account.")
                            
                            #if targetEnvironment(simulator)
                            Text("⚠️ Simulator Mode: Face ID simulation enabled for testing")
                                .foregroundColor(.orange)
                                .font(.caption)
                            #endif
                        }
                    } else {
                        Text(biometricManager.errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    PasswordSecurityRow()
                } header: {
                    Text("Password Security")
                } footer: {
                    Text("Keep your account secure by using a strong password.")
                }
                
                Section {
                    PrivacySettingsRows()
                } header: {
                    Text("Privacy Settings")
                } footer: {
                    Text("Control how your data is used and stored.")
                }
            }
            .navigationTitle("Privacy & Security")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            biometricManager.checkBiometricAvailability()
        }
        .alert("Biometric Authentication", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingPasswordUpdate) {
            UpdatePasswordView()
        }
    }
}

struct BiometricAuthenticationRow: View {
    @StateObject private var biometricManager = BiometricAuthManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isToggleEnabled = true
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(biometricManager.isAvailable ? Color.monoPrimary.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: biometricManager.biometricIcon)
                    .font(.system(size: 20))
                    .foregroundColor(biometricManager.isAvailable ? .monoPrimary : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(biometricManager.biometricTypeDescription)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    #if targetEnvironment(simulator)
                    Text("(Simulator)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                    #endif
                }
                
                Text(biometricManager.isAvailable ? "Secure and convenient access" : "Not available")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { biometricManager.isBiometricEnabled },
                set: { newValue in
                    handleBiometricToggle(newValue)
                }
            ))
            .disabled(!biometricManager.isAvailable || !isToggleEnabled)
        }
        .padding(.vertical, 4)
        .alert("Biometric Authentication", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleBiometricToggle(_ enabled: Bool) {
        isToggleEnabled = false
        
        if enabled {
            biometricManager.enableBiometricAuth { success, error in
                DispatchQueue.main.async {
                    isToggleEnabled = true
                    if !success {
                        alertMessage = error ?? "Failed to enable biometric authentication"
                        showingAlert = true
                    } else {
                        alertMessage = "\(biometricManager.biometricTypeDescription) has been enabled successfully!"
                        showingAlert = true
                    }
                }
            }
        } else {
            biometricManager.disableBiometricAuth()
            alertMessage = "\(biometricManager.biometricTypeDescription) has been disabled."
            showingAlert = true
            isToggleEnabled = true
        }
    }
}

struct PasswordSecurityRow: View {
    @State private var showingPasswordUpdate = false
    
    var body: some View {
        Button(action: {
            showingPasswordUpdate = true
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "key.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Change Password")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("Update your account password")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingPasswordUpdate) {
            UpdatePasswordView()
        }
    }
}

struct PrivacySettingsRows: View {
    var body: some View {
        Group {
            PrivacySettingRow(
                icon: "shield.fill",
                iconColor: .green,
                title: "Security Audit",
                subtitle: "Review security settings",
                action: {  }
            )
        }
    }
}

struct PrivacySettingRow: View {
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

#Preview {
    PrivacySecurityView()
}

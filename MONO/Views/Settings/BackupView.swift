import SwiftUI
import Foundation
import UserNotifications

struct BackupView: View {
    let userEmail: String
    @ObservedObject private var backupService = BackupService.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Backup Status") {
                    // OCR record count is maintained in BackupService's local storage; not exposed as a simple count here.
                    HStack {
                        Text("OCR Records")
                        Spacer()
                        Text("—")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Last Backup")
                        Spacer()
                        if let lastBackup = backupService.lastBackupDate {
                            Text(lastBackup, style: .relative)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Never")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Backup Actions") {
                    Button("Create Backup") {
                        createBackup()
                    }
                    Button("Send Test Notification") {
                        let content = UNMutableNotificationContent()
                        content.title = "MONO Test"
                        content.body = "This is a local notification test."
                        content.sound = .default
                        content.badge = 1

                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                        let req = UNNotificationRequest(identifier: "mono_debug_local", content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(req) { error in
                            if let err = error { print("Error scheduling local notif:", err) }
                        }
                    }
                }
                
                Section {
                    EmptyView()
                } footer: {
                    Text("This is a simplified backup demo. OCR records are counted and backup dates are tracked locally.")
                }
            }
            .navigationTitle("Backup & Sync")
            .alert("Backup", isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func createBackup() {
        Task {
            do {
                let url = try await backupService.createBackup(for: userEmail)
                alertMessage = "Backup created successfully: \(url.lastPathComponent)"
            } catch {
                alertMessage = "Failed to create backup: \(error.localizedDescription)"
            }
            showingAlert = true
        }
    }
    
    // kept for debug during development — adds a fake OCR record locally
    private func addTestRecord() {
        BackupService.shared.saveOCRResult(amount: 1.0, text: "Test", category: "Other", confidence: 1.0, merchant: "Test Merchant", date: Date(), userEmail: userEmail)
        alertMessage = "Test OCR record added."
        showingAlert = true
    }
}

#Preview {
    BackupView(userEmail: "test@example.com")
}

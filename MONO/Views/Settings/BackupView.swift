import SwiftUI
import Foundation

// Backup manager for handling OCR data backups
class SimpleBackupManager: ObservableObject {
    static let shared = SimpleBackupManager()
    
    @Published var ocrRecordCount = 0
    @Published var lastBackupDate: Date?
    
    private init() {
        loadStats()
    }
    
    func createBackup() -> String {
        lastBackupDate = Date()
        saveStats()
        return "backup_\(Date().timeIntervalSince1970).json"
    }
    
    func getStats() -> (count: Int, lastBackup: Date?) {
        return (ocrRecordCount, lastBackupDate)
    }
    
    func addOCRRecord() {
        ocrRecordCount += 1
        saveStats()
    }
    
    private func loadStats() {
        ocrRecordCount = UserDefaults.standard.integer(forKey: "ocrRecordCount")
        if let timestamp = UserDefaults.standard.object(forKey: "lastBackupDate") as? Date {
            lastBackupDate = timestamp
        }
    }
    
    private func saveStats() {
        UserDefaults.standard.set(ocrRecordCount, forKey: "ocrRecordCount")
        if let date = lastBackupDate {
            UserDefaults.standard.set(date, forKey: "lastBackupDate")
        }
    }
}

struct BackupView: View {
    let userEmail: String
    @ObservedObject private var backupManager = SimpleBackupManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Backup Status") {
                    HStack {
                        Text("OCR Records")
                        Spacer()
                        Text("\(backupManager.ocrRecordCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Last Backup")
                        Spacer()
                        if let lastBackup = backupManager.lastBackupDate {
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
                    
                    Button("Add Test OCR Record") {
                        addTestRecord()
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
        let filename = backupManager.createBackup()
        alertMessage = "Backup created successfully: \(filename)"
        showingAlert = true
    }
    
    private func addTestRecord() {
        backupManager.addOCRRecord()
        alertMessage = "Test OCR record added. Total: \(backupManager.ocrRecordCount)"
        showingAlert = true
    }
}

#Preview {
    BackupView(userEmail: "test@example.com")
}

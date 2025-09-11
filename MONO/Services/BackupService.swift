import Foundation
import CoreData

struct OCRBackupRecord: Codable {
    let id: String
    let amount: Double?
    let text: String
    let category: String?
    let confidence: Float
    let merchant: String?
    let date: Date?
    let createdAt: Date
    let userEmail: String
}

struct UserBackupRecord: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String?
    let dateCreated: Date
    let isLoggedIn: Bool
}

struct IncomeBackupRecord: Codable {
    let id: String
    let amount: Double
    let categoryId: String
    let categoryName: String
    let categoryIcon: String
    let categoryColor: String
    let incomeDescription: String?
    let date: Date
    let isRecurring: Bool
    let recurrenceFrequency: String?
    let createdAt: Date
    let updatedAt: Date
}

struct ExpenseBackupRecord: Codable {
    let id: String
    let amount: Double
    let category: String
    let expenseDescription: String?
    let date: Date
    let isRecurring: Bool
    let recurringFrequency: String?
    let isPaymentReminder: Bool
    let isReminderActive: Bool
    let reminderDate: Date?
    let reminderFrequency: String?
    let reminderDayOfMonth: Int16?
    let lastReminderSent: Date?
    let locationName: String?
    let latitude: Double?
    let longitude: Double?
    let dependentID: String?
    let userID: String
    let createdAt: Date
    let updatedAt: Date
}

struct DependentBackupRecord: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let relationship: String
    let dateOfBirth: Date
    let phoneNumber: String
    let email: String
    let isActive: Bool
    let dataAdded: Date
    let userID: String
}

struct CompleteBackupData: Codable {
    let version: String
    let createdAt: Date
    let userEmail: String
    let user: UserBackupRecord?
    let ocrRecords: [OCRBackupRecord]
    let incomes: [IncomeBackupRecord]
    let expenses: [ExpenseBackupRecord]
    let dependents: [DependentBackupRecord]
}

struct BackupData: Codable {
    let version: String
    let createdAt: Date
    let userEmail: String
    let ocrRecords: [OCRBackupRecord]
}

enum BackupError: Error, LocalizedError {
    case exportFailed
    case importFailed
    case fileNotFound
    case invalidData
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .exportFailed:
            return "Failed to export backup data"
        case .importFailed:
            return "Failed to import backup data"
        case .fileNotFound:
            return "Backup file not found"
        case .invalidData:
            return "Invalid backup data format"
        case .permissionDenied:
            return "Permission denied to access files"
        }
    }
}

class BackupService: ObservableObject {
    static let shared = BackupService()
    
    private let fileManager = FileManager.default
    private let documentsPath: URL
    
    @Published var lastBackupDate: Date?
    @Published var backupInProgress = false
    
    private init() {
        documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        loadLastBackupDate()
    }
    
    
    func saveOCRResult(amount: Double?, text: String, category: String?, confidence: Float, merchant: String?, date: Date?, userEmail: String) {
        let record = OCRBackupRecord(
            id: UUID().uuidString,
            amount: amount,
            text: text,
            category: category,
            confidence: confidence,
            merchant: merchant,
            date: date,
            createdAt: Date(),
            userEmail: userEmail
        )
        
        saveOCRRecordToLocal(record)
    }
    
    func getOCRRecords(for userEmail: String) -> [OCRBackupRecord] {
        return loadOCRRecords().filter { $0.userEmail == userEmail }
    }
    
    func deleteOCRRecord(id: String) {
        var records = loadOCRRecords()
        records.removeAll { $0.id == id }
        saveOCRRecords(records)
    }

    
    func createBackup(for userEmail: String) async throws -> URL {
        backupInProgress = true
        defer { backupInProgress = false }
        
        do {
            let user = try fetchUserForBackup(userEmail: userEmail)
            
            let ocrRecords = getOCRRecords(for: userEmail)
            let incomes = try fetchIncomesForBackup(userEmail: userEmail)
            let expenses = try fetchExpensesForBackup(userEmail: userEmail)
            let dependents = try fetchDependentsForBackup(userEmail: userEmail)
            
            let completeBackupData = CompleteBackupData(
                version: "2.0",
                createdAt: Date(),
                userEmail: userEmail,
                user: user,
                ocrRecords: ocrRecords,
                incomes: incomes,
                expenses: expenses,
                dependents: dependents
            )
            
            let fileName = "MONO_Complete_Backup_\(formatDateForFilename(Date())).json"
            let backupURL = documentsPath.appendingPathComponent(fileName)
            
            let jsonData = try JSONEncoder().encode(completeBackupData)
            try jsonData.write(to: backupURL)
            
            lastBackupDate = Date()
            saveLastBackupDate()
            
            return backupURL
            
        } catch {
            print("Backup creation failed: \(error)")
            throw BackupError.exportFailed
        }
    }
    
    func restoreFromBackup(url: URL, for userEmail: String) async throws {
        backupInProgress = true
        defer { backupInProgress = false }
        
        do {
            let jsonData = try Data(contentsOf: url)
            let backupData = try JSONDecoder().decode(BackupData.self, from: jsonData)
            let userRecords = backupData.ocrRecords.filter { $0.userEmail == userEmail }
            var existingRecords = loadOCRRecords()
            existingRecords.removeAll { $0.userEmail == userEmail }
            existingRecords.append(contentsOf: userRecords)
            
            saveOCRRecords(existingRecords)
            
        } catch {
            throw BackupError.importFailed
        }
    }
    
    func exportBackupForSharing(for userEmail: String) async throws -> URL {
        return try await createBackup(for: userEmail)
    }
    
    func getBackupStats(for userEmail: String) -> (ocrCount: Int, lastBackup: Date?) {
        let ocrRecords = getOCRRecords(for: userEmail)
        return (ocrCount: ocrRecords.count, lastBackup: lastBackupDate)
    }
    
    
    private func saveOCRRecordToLocal(_ record: OCRBackupRecord) {
        var records = loadOCRRecords()
        records.append(record)
        saveOCRRecords(records)
    }
    
    private func loadOCRRecords() -> [OCRBackupRecord] {
        let url = documentsPath.appendingPathComponent("ocr_records.json")
        
        guard let data = try? Data(contentsOf: url),
              let records = try? JSONDecoder().decode([OCRBackupRecord].self, from: data) else {
            return []
        }
        
        return records
    }
    
    private func saveOCRRecords(_ records: [OCRBackupRecord]) {
        do {
            let data = try JSONEncoder().encode(records)
            let url = documentsPath.appendingPathComponent("ocr_records.json")
            try data.write(to: url)
        } catch {
            print("Failed to save OCR records: \(error)")
        }
    }
    
    private func formatDateForFilename(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: date)
    }
    
    private func saveLastBackupDate() {
        if let date = lastBackupDate {
            UserDefaults.standard.set(date, forKey: "lastBackupDate")
        }
    }
    
    private func loadLastBackupDate() {
        if let date = UserDefaults.standard.object(forKey: "lastBackupDate") as? Date {
            lastBackupDate = date
        }
    }
    
    private func fetchUserForBackup(userEmail: String) throws -> UserBackupRecord? {
        return UserBackupRecord(
            id: UUID().uuidString,
            firstName: "User",
            lastName: "Data",
            email: userEmail,
            phoneNumber: nil,
            dateCreated: Date(),
            isLoggedIn: true
        )
    }
    
    private func fetchIncomesForBackup(userEmail: String) throws -> [IncomeBackupRecord] {
        return []
    }
    
    private func fetchExpensesForBackup(userEmail: String) throws -> [ExpenseBackupRecord] {
        return []
    }
    
    private func fetchDependentsForBackup(userEmail: String) throws -> [DependentBackupRecord] {
        return []
    }
}

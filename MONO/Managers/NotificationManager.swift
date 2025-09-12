//
//  NotificationManager.swift
//  MONO
//
//  Created by Akash01 on 2025-09-12.
//

import Foundation
import UserNotifications
import CoreData
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notifications: [AppNotification] = []
    @Published var hasUnreadNotifications: Bool = false
    
    private init() {
        loadNotifications()
        requestNotificationPermission()
    }
    
    // MARK: - Notification Permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            print("Notification permission granted: \(granted)")
        }
    }
    
    // MARK: - Schedule Notifications
    func scheduleIncomeReminder(amount: Double, description: String?, date: Date, isRecurring: Bool, frequency: String?) {
        let content = UNMutableNotificationContent()
        content.title = "Income Reminder"
        content.subtitle = "MONO - Personal Finance"
        content.body = "Time to log your income: \(description ?? "Rs. \(String(format: "%.2f", amount))")"
        content.badge = 1
        content.sound = UNNotificationSound.default
        content.userInfo = [
            "type": "income_reminder",
            "amount": amount,
            "description": description ?? "",
            "isRecurring": isRecurring,
            "frequency": frequency ?? ""
        ]
        
        let identifier = "income_reminder_\(UUID().uuidString)"
        
        if isRecurring && frequency != nil {
            scheduleRecurringNotification(content: content, identifier: identifier, frequency: frequency!, startDate: date)
        } else {
            scheduleOneTimeNotification(content: content, identifier: identifier, date: date)
        }
        
        // Add to local notifications array
        addNotification(
            title: "Income Reminder Set",
            message: "You'll be reminded to log your income",
            type: .income,
            scheduledDate: date
        )
    }
    
    func scheduleExpenseReminder(amount: Double, description: String?, category: String, date: Date, isRecurring: Bool, frequency: String?) {
        let content = UNMutableNotificationContent()
        content.title = "Expense Reminder"
        content.subtitle = "MONO - Personal Finance"
        content.body = "Don't forget: \(description ?? "\(category) expense of Rs. \(String(format: "%.2f", amount))")"
        content.badge = 1
        content.sound = UNNotificationSound.default
        content.userInfo = [
            "type": "expense_reminder",
            "amount": amount,
            "description": description ?? "",
            "category": category,
            "isRecurring": isRecurring,
            "frequency": frequency ?? ""
        ]
        
        let identifier = "expense_reminder_\(UUID().uuidString)"
        
        if isRecurring && frequency != nil {
            scheduleRecurringNotification(content: content, identifier: identifier, frequency: frequency!, startDate: date)
        } else {
            scheduleOneTimeNotification(content: content, identifier: identifier, date: date)
        }
        
        // Add to local notifications array
        addNotification(
            title: "Expense Reminder Set",
            message: "You'll be reminded about your \(category.lowercased()) expense",
            type: .expense,
            scheduledDate: date
        )
    }
    
    func schedulePaymentReminder(amount: Double, description: String?, reminderDate: Date, frequency: String) {
        let content = UNMutableNotificationContent()
        content.title = "Payment Due"
        content.subtitle = "MONO - Personal Finance"
        content.body = "Payment reminder: \(description ?? "Rs. \(String(format: "%.2f", amount))")"
        content.badge = 1
        content.sound = UNNotificationSound.default
        content.userInfo = [
            "type": "payment_reminder",
            "amount": amount,
            "description": description ?? ""
        ]
        
        let identifier = "payment_reminder_\(UUID().uuidString)"
        
        if frequency == "Monthly" {
            scheduleRecurringNotification(content: content, identifier: identifier, frequency: "monthly", startDate: reminderDate)
        } else if frequency == "Yearly" {
            scheduleRecurringNotification(content: content, identifier: identifier, frequency: "yearly", startDate: reminderDate)
        } else {
            scheduleOneTimeNotification(content: content, identifier: identifier, date: reminderDate)
        }
        
        // Add to local notifications array
        addNotification(
            title: "Payment Reminder Set",
            message: "You'll be reminded about your payment",
            type: .reminder,
            scheduledDate: reminderDate
        )
    }
    
    // MARK: - Private Scheduling Methods
    private func scheduleOneTimeNotification(content: UNMutableNotificationContent, identifier: String, date: Date) {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling one-time notification: \(error)")
            } else {
                print("One-time notification scheduled for \(date)")
            }
        }
    }
    
    private func scheduleRecurringNotification(content: UNMutableNotificationContent, identifier: String, frequency: String, startDate: Date) {
        var dateComponents: DateComponents
        
        switch frequency.lowercased() {
        case "daily":
            dateComponents = Calendar.current.dateComponents([.hour, .minute], from: startDate)
        case "weekly":
            dateComponents = Calendar.current.dateComponents([.weekday, .hour, .minute], from: startDate)
        case "monthly":
            dateComponents = Calendar.current.dateComponents([.day, .hour, .minute], from: startDate)
        case "yearly":
            dateComponents = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: startDate)
        default:
            dateComponents = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: startDate)
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling recurring notification: \(error)")
            } else {
                print("Recurring \(frequency) notification scheduled")
            }
        }
    }
    
    // MARK: - Local Notification Management
    func addNotification(title: String, message: String, type: NotificationType, scheduledDate: Date? = nil) {
        let notification = AppNotification(
            id: UUID(),
            title: title,
            message: message,
            timestamp: Date(),
            type: type,
            isRead: false,
            scheduledDate: scheduledDate
        )
        
        DispatchQueue.main.async {
            self.notifications.insert(notification, at: 0)
            self.updateUnreadStatus()
        }
        
        saveNotifications()
    }
    
    func markAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            DispatchQueue.main.async {
                self.notifications[index].isRead = true
                self.updateUnreadStatus()
            }
            saveNotifications()
        }
    }
    
    func deleteNotification(_ notification: AppNotification) {
        DispatchQueue.main.async {
            self.notifications.removeAll { $0.id == notification.id }
            self.updateUnreadStatus()
        }
        saveNotifications()
    }
    
    func clearAllNotifications() {
        DispatchQueue.main.async {
            self.notifications.removeAll()
            self.hasUnreadNotifications = false
        }
        saveNotifications()
    }
    
    private func updateUnreadStatus() {
        hasUnreadNotifications = notifications.contains { !$0.isRead }
    }
    
    // MARK: - Persistence
    private func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: "saved_notifications")
        }
    }
    
    private func loadNotifications() {
        if let data = UserDefaults.standard.data(forKey: "saved_notifications"),
           let decoded = try? JSONDecoder().decode([AppNotification].self, from: data) {
            DispatchQueue.main.async {
                self.notifications = decoded
                self.updateUnreadStatus()
            }
        }
    }
    
    // MARK: - Demo/Testing
    func addSampleNotifications() {
        let sampleNotifications = [
            AppNotification(
                id: UUID(),
                title: "Welcome to MONO",
                message: "Start tracking your income and expenses efficiently!",
                timestamp: Date(),
                type: .reminder,
                isRead: false
            ),
            AppNotification(
                id: UUID(),
                title: "Salary Reminder",
                message: "Don't forget to log your monthly salary",
                timestamp: Date().addingTimeInterval(-3600),
                type: .income,
                isRead: false
            ),
            AppNotification(
                id: UUID(),
                title: "Rent Payment Due",
                message: "Your rent payment is due tomorrow",
                timestamp: Date().addingTimeInterval(-7200),
                type: .expense,
                isRead: false
            )
        ]
        
        DispatchQueue.main.async {
            self.notifications.append(contentsOf: sampleNotifications)
            self.updateUnreadStatus()
        }
        saveNotifications()
    }
}

// MARK: - Data Models
struct AppNotification: Identifiable, Codable {
    let id: UUID
    let title: String
    let message: String
    let timestamp: Date
    let type: NotificationType
    var isRead: Bool
    let scheduledDate: Date?
    
    init(id: UUID, title: String, message: String, timestamp: Date, type: NotificationType, isRead: Bool, scheduledDate: Date? = nil) {
        self.id = id
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.type = type
        self.isRead = isRead
        self.scheduledDate = scheduledDate
    }
}

enum NotificationType: String, CaseIterable, Codable {
    case income
    case expense
    case budget
    case reminder
    
    var iconName: String {
        switch self {
        case .income:
            return "plus.circle.fill"
        case .expense:
            return "minus.circle.fill"
        case .budget:
            return "chart.pie.fill"
        case .reminder:
            return "bell.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .income:
            return .green
        case .expense:
            return .red
        case .budget:
            return .orange
        case .reminder:
            return .blue
        }
    }
}

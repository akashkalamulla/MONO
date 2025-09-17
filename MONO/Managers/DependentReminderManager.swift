//
//  DependentReminderManager.swift
//  MONO
//
//  Created by Akash01 on 2025-09-17.
//

import Foundation
import SwiftUI
import UserNotifications
import CoreLocation

class DependentReminderManager: ObservableObject {
    @Published var reminders: [DependentReminder] = []
    @Published var isLoading = false
    
    private let userDefaults = UserDefaults.standard
    private let remindersKey = "DependentReminders"
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        loadReminders()
    }
    
    // MARK: - Data Persistence
    private func loadReminders() {
        isLoading = true
        defer { isLoading = false }
        
        guard let data = userDefaults.data(forKey: remindersKey),
              let decodedReminders = try? JSONDecoder().decode([DependentReminder].self, from: data) else {
            reminders = []
            return
        }
        
        reminders = decodedReminders.sorted { $0.combinedDateTime < $1.combinedDateTime }
    }
    
    private func saveReminders() {
        guard let data = try? JSONEncoder().encode(reminders) else { return }
        userDefaults.set(data, forKey: remindersKey)
    }
    
    // MARK: - Reminder Management
    func addReminder(_ reminder: DependentReminder) {
        var newReminder = reminder
        
        // Schedule notification
        scheduleNotification(for: newReminder) { notificationId in
            newReminder.notificationId = notificationId
            
            DispatchQueue.main.async {
                self.reminders.append(newReminder)
                self.reminders.sort { $0.combinedDateTime < $1.combinedDateTime }
                self.saveReminders()
            }
        }
    }
    
    func updateReminder(_ reminder: DependentReminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        
        // Cancel existing notification
        if let notificationId = reminders[index].notificationId {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationId])
        }
        
        var updatedReminder = reminder
        
        // Schedule new notification if not completed
        if !reminder.isCompleted {
            scheduleNotification(for: updatedReminder) { notificationId in
                updatedReminder.notificationId = notificationId
                
                DispatchQueue.main.async {
                    self.reminders[index] = updatedReminder
                    self.reminders.sort { $0.combinedDateTime < $1.combinedDateTime }
                    self.saveReminders()
                }
            }
        } else {
            reminders[index] = updatedReminder
            reminders.sort { $0.combinedDateTime < $1.combinedDateTime }
            saveReminders()
        }
    }
    
    func completeReminder(_ reminder: DependentReminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        
        // Cancel notification
        if let notificationId = reminder.notificationId {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationId])
        }
        
        var completedReminder = reminder
        completedReminder.isCompleted = true
        completedReminder.completedAt = Date()
        completedReminder.notificationId = nil
        
        // Remove location when completed (as requested)
        completedReminder.location = nil
        
        reminders[index] = completedReminder
        saveReminders()
    }
    
    func deleteReminder(_ reminder: DependentReminder) {
        // Cancel notification
        if let notificationId = reminder.notificationId {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationId])
        }
        
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }
    
    func getReminders(for dependentId: UUID) -> [DependentReminder] {
        return reminders.filter { $0.dependentId == dependentId }
    }
    
    func getActiveReminders(for dependentId: UUID) -> [DependentReminder] {
        return reminders.filter { $0.dependentId == dependentId && !$0.isCompleted && $0.isActive }
    }
    
    func getUpcomingReminders(for dependentId: UUID) -> [DependentReminder] {
        return reminders.filter { $0.dependentId == dependentId && $0.isUpcoming }
    }
    
    func getOverdueReminders(for dependentId: UUID) -> [DependentReminder] {
        return reminders.filter { $0.dependentId == dependentId && $0.isOverdue }
    }
    
    // MARK: - Notification Scheduling
    private func scheduleNotification(for reminder: DependentReminder, completion: @escaping (String?) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = "Payment Reminder"
        content.subtitle = reminder.paymentName
        content.body = "Amount: Rs. \(String(format: "%.2f", reminder.amount))"
        content.sound = UNNotificationSound.default
        content.userInfo = [
            "reminderId": reminder.id.uuidString,
            "type": "dependent_payment_reminder",
            "paymentName": reminder.paymentName,
            "amount": reminder.amount,
            "dependentId": reminder.dependentId.uuidString
        ]
        
        // Add location to notification if available
        if let location = reminder.location {
            content.body += "\nLocation: \(location.name)"
            content.userInfo["locationName"] = location.name
            content.userInfo["locationLatitude"] = location.latitude
            content.userInfo["locationLongitude"] = location.longitude
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.combinedDateTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "dependent_reminder_\(reminder.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
                completion(nil)
            } else {
                completion(identifier)
            }
        }
    }
    
    // MARK: - Helper Methods
    func cleanup() {
        // Remove completed reminders older than 30 days
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        reminders.removeAll { reminder in
            return reminder.isCompleted && 
                   (reminder.completedAt ?? reminder.createdAt) < thirtyDaysAgo
        }
        
        saveReminders()
    }
    
    func requestNotificationPermissions() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            print("Notification permission granted: \(granted)")
        }
    }
}

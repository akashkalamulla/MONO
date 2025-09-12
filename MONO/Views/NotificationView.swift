//
//  NotificationView.swift
//  MONO
//
//  Created by Akash01 on 2025-09-12.
//

import SwiftUI
import UserNotifications

struct NotificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var notifications: [NotificationItem] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading notifications...")
                        .padding()
                } else if notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Notifications")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Text("You're all caught up! Notifications will appear here when you have reminders or updates.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(notifications) { notification in
                            NotificationRowView(notification: notification) {
                                markAsRead(notification)
                            }
                        }
                        .onDelete(perform: deleteNotifications)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                if !notifications.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            clearAllNotifications()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            loadNotifications()
        }
    }
    
    private func loadNotifications() {
        isLoading = true
        
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Load sample notifications (in a real app, this would come from Core Data or a service)
            notifications = getSampleNotifications()
            isLoading = false
        }
    }
    
    private func getSampleNotifications() -> [NotificationItem] {
        return [
            NotificationItem(
                id: UUID(),
                title: "Income Reminder",
                message: "Don't forget to log your monthly salary",
                timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
                type: .income,
                isRead: false
            ),
            NotificationItem(
                id: UUID(),
                title: "Expense Reminder",
                message: "Rent payment is due tomorrow",
                timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
                type: .expense,
                isRead: false
            ),
            NotificationItem(
                id: UUID(),
                title: "Budget Alert",
                message: "You've spent 80% of your monthly food budget",
                timestamp: Date().addingTimeInterval(-86400), // 1 day ago
                type: .budget,
                isRead: true
            )
        ]
    }
    
    private func markAsRead(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    private func deleteNotifications(offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
    }
    
    private func clearAllNotifications() {
        notifications.removeAll()
    }
}

struct NotificationRowView: View {
    let notification: NotificationItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon based on notification type
                Image(systemName: notification.type.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(notification.type.color)
                    .frame(width: 30, height: 30)
                    .background(notification.type.color.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 16, weight: notification.isRead ? .medium : .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(notification.message)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    Text(formatTime(notification.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !notification.isRead {
                    Circle()
                        .fill(Color.monoPrimary)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct NotificationItem: Identifiable {
    let id: UUID
    let title: String
    let message: String
    let timestamp: Date
    let type: NotificationType
    var isRead: Bool
}

enum NotificationType {
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

#Preview {
    NotificationView()
}

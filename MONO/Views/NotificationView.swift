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
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading notifications...")
                        .padding()
                } else if notificationManager.notifications.isEmpty {
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
                        
                        Button("Add Sample Notifications") {
                            notificationManager.addSampleNotifications()
                        }
                        .padding(.top)
                        .foregroundColor(.blue)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(notificationManager.notifications) { notification in
                            NotificationRowView(notification: notification) {
                                notificationManager.markAsRead(notification)
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
                
                if !notificationManager.notifications.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            notificationManager.clearAllNotifications()
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
            isLoading = false
        }
    }
    
    private func deleteNotifications(offsets: IndexSet) {
        for index in offsets {
            let notification = notificationManager.notifications[index]
            notificationManager.deleteNotification(notification)
        }
    }
}


struct NotificationRowView: View {
    let notification: AppNotification
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
                        .fill(Color.blue)
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

#Preview {
    NotificationView()
}

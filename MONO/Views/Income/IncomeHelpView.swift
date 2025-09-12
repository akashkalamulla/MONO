//
//  IncomeHelpView.swift
//  MONO
//
//  Created by Akash01 on 2025-09-12.
//

import SwiftUI
import UserNotifications

struct IncomeHelpView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingNotificationAlert = false
    @State private var notificationMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Adding Income")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    Text("Learn how to track and manage your income sources in MONO.")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                instructionCard(
                    number: "1",
                    title: "Enter Amount",
                    description: "Input your income amount in Sri Lankan Rupees (Rs.). Make sure to enter the exact amount you received or expect to receive."
                )
                
                instructionCard(
                    number: "2",
                    title: "Select Category",
                    description: "Choose the appropriate income category: Salary, Freelance, Business, Investment, Rental, or Other. This helps organize your income sources."
                )
                
                instructionCard(
                    number: "3",
                    title: "Set Date",
                    description: "Pick the date when you received or will receive this income. You can select past or future dates for better planning."
                )
                
                instructionCard(
                    number: "4",
                    title: "Recurring Income",
                    description: "Enable this option if the income repeats regularly. Choose the frequency: Weekly, Bi-weekly, Monthly, or Yearly to automatically track future income."
                )
                
                instructionCard(
                    number: "5",
                    title: "Add Description",
                    description: "Optionally add a description to provide more details about the income source, such as client name, project details, or additional notes."
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tips & Best Practices")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    tipItem(
                        icon: "dollarsign.circle",
                        text: "Track all income sources to get a complete picture of your financial health."
                    )
                    
                    tipItem(
                        icon: "calendar.badge.plus",
                        text: "Use recurring income for regular payments like salary to save time on data entry."
                    )
                    
                    tipItem(
                        icon: "chart.line.uptrend.xyaxis",
                        text: "Regular income tracking helps you monitor growth trends and plan your budget effectively."
                    )
                    
                    tipItem(
                        icon: "folder.badge.gearshape",
                        text: "Categorize your income properly to understand which sources contribute most to your finances."
                    )
                    
                    tipItem(
                        icon: "note.text",
                        text: "Add descriptions for freelance or business income to track specific projects or clients."
                    )
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    Button(action: {
                        setupIncomeReminder()
                    }) {
                        HStack {
                            Image(systemName: "app.badge")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            
                            Text("Set Income Reminder")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.2, green: 0.6, blue: 0.6))
                        .cornerRadius(8)
                    }
                    .padding(.bottom, 8)
                }
                .padding(.vertical, 8)
                    
                VStack(alignment: .leading, spacing: 12) {
                    Text("Income Categories")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    categoryItem(
                        icon: "briefcase.fill",
                        title: "Salary",
                        description: "Regular employment income from your primary job"
                    )
                    
                    categoryItem(
                        icon: "laptop",
                        title: "Freelance",
                        description: "Income from freelance work, consulting, or contract jobs"
                    )
                    
                    categoryItem(
                        icon: "building.2",
                        title: "Business",
                        description: "Revenue from your business or entrepreneurial activities"
                    )
                    
                    categoryItem(
                        icon: "chart.pie",
                        title: "Investment",
                        description: "Returns from stocks, bonds, dividends, or other investments"
                    )
                    
                    categoryItem(
                        icon: "house",
                        title: "Rental",
                        description: "Income from renting out property or assets"
                    )
                    
                    categoryItem(
                        icon: "ellipsis.circle",
                        title: "Other",
                        description: "Any other income sources not covered by the above categories"
                    )
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Help")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .edgesIgnoringSafeArea(.bottom)
        .alert("Income Reminder", isPresented: $showingNotificationAlert) {
            Button("OK") { }
        } message: {
            Text(notificationMessage)
        }
    }
    
    private func setupIncomeReminder() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.scheduleIncomeReminder()
                } else {
                    self.notificationMessage = "Please enable notifications in Settings to receive income reminders."
                    self.showingNotificationAlert = true
                }
            }
        }
    }
    
    private func scheduleIncomeReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Income Reminder"
        content.subtitle = "MONO - Personal Finance"
        content.body = "Don't forget to log your income for this period!"
        content.badge = 1
        content.sound = UNNotificationSound.default
        content.userInfo = ["category": "income", "action": "add_income"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "income_reminder_demo", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.notificationMessage = "Failed to schedule reminder: \(error.localizedDescription)"
                } else {
                    self.notificationMessage = "Income reminder set! You'll receive a notification in 10 seconds."
                }
                self.showingNotificationAlert = true
            }
        }
    }
    }
    
    private func instructionCard(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color(red: 0.2, green: 0.6, blue: 0.6))
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func tipItem(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6)) 
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
    
    private func categoryItem(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 6)
    }


#Preview {
    NavigationView {
        IncomeHelpView()
    }
}

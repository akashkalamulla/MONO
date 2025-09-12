//
//  ExpenseHelpView.swift
//  MONO
//
//  Created by Akash01 on 2025-09-12.
//

import SwiftUI
import UserNotifications

struct ExpenseHelpView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingNotificationAlert = false
    @State private var notificationMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Adding Expenses")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    Text("Learn how to track and manage your expenses efficiently using both manual entry and receipt scanning in MONO.")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                instructionCard(
                    number: "1",
                    title: "Choose Entry Method",
                    description: "Use 'Scan Receipt' for automatic data extraction from photos, or manual entry for quick input. Receipt scanning uses OCR to detect amounts and categories automatically."
                )
                
                instructionCard(
                    number: "2",
                    title: "Enter Amount",
                    description: "Input your expense amount in Sri Lankan Rupees (Rs.). Make sure to enter the exact amount you spent for accurate tracking."
                )
                
                instructionCard(
                    number: "3",
                    title: "Select Category",
                    description: "Choose from categories like Food & Dining, Transportation, Housing, Utilities, Shopping, Healthcare, Entertainment, Education, or Other."
                )
                
                instructionCard(
                    number: "4",
                    title: "Set Date & Location",
                    description: "Pick the expense date and optionally add location information using the map picker for better expense organization and analysis."
                )
                
                instructionCard(
                    number: "5",
                    title: "Recurring Expenses",
                    description: "Enable for regular expenses like rent or subscriptions. Choose frequency: Daily, Weekly, Monthly, or Yearly to automatically track future expenses."
                )
                
                instructionCard(
                    number: "6",
                    title: "Payment Reminders",
                    description: "Set reminders for upcoming payments. Choose 'Once' for one-time reminders, 'Monthly' for recurring bills, or 'Yearly' for annual payments."
                )
                
                instructionCard(
                    number: "7",
                    title: "Associate with Dependents",
                    description: "Link expenses to family members or dependents for better financial planning and separate expense tracking per person."
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tips & Best Practices")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    tipItem(
                        icon: "camera.viewfinder",
                        text: "Use receipt scanning for accurate data entry - it automatically extracts amounts and suggests categories."
                    )
                    
                    tipItem(
                        icon: "calendar.badge.plus",
                        text: "Set up recurring expenses for bills and subscriptions to avoid missing payments."
                    )
                    
                    tipItem(
                        icon: "bell.badge",
                        text: "Enable payment reminders for important bills to maintain good financial habits."
                    )
                    
                    tipItem(
                        icon: "mappin.circle",
                        text: "Add locations to track where you spend most - useful for identifying spending patterns."
                    )
                    
                    tipItem(
                        icon: "person.2.circle",
                        text: "Use dependent association to track family expenses separately for better budgeting."
                    )
                    
                    tipItem(
                        icon: "chart.pie",
                        text: "Categorize expenses properly to understand your spending patterns and identify areas to save."
                    )
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    Button(action: {
                        setupExpenseReminder()
                    }) {
                        HStack {
                            Image(systemName: "bell.badge")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            
                            Text("Set Expense Reminder")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.monoPrimary)
                        .cornerRadius(8)
                    }
                    .padding(.bottom, 8)
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Expense Categories")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    categoryItem(
                        icon: "fork.knife.circle.fill",
                        title: "Food & Dining",
                        description: "Restaurants, groceries, takeout, and food-related expenses"
                    )
                    
                    categoryItem(
                        icon: "car.fill",
                        title: "Transportation",
                        description: "Fuel, public transport, ride-sharing, vehicle maintenance"
                    )
                    
                    categoryItem(
                        icon: "house.fill",
                        title: "Housing",
                        description: "Rent, mortgage, property taxes, home maintenance"
                    )
                    
                    categoryItem(
                        icon: "bolt.fill",
                        title: "Utilities",
                        description: "Electricity, water, gas, internet, phone bills"
                    )
                    
                    categoryItem(
                        icon: "bag.fill",
                        title: "Shopping",
                        description: "Clothing, electronics, household items, personal purchases"
                    )
                    
                    categoryItem(
                        icon: "cross.case.fill",
                        title: "Healthcare",
                        description: "Medical bills, medications, insurance, wellness expenses"
                    )
                    
                    categoryItem(
                        icon: "gamecontroller.fill",
                        title: "Entertainment",
                        description: "Movies, games, sports, hobbies, leisure activities"
                    )
                    
                    categoryItem(
                        icon: "book.fill",
                        title: "Education",
                        description: "Tuition, books, courses, training, educational materials"
                    )
                    
                    categoryItem(
                        icon: "ellipsis.circle.fill",
                        title: "Other",
                        description: "Any expenses not covered by the above categories"
                    )
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("OCR Receipt Scanning Tips")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))

                    tipItem(
                        icon: "camera.macro",
                        text: "How to scan: place the receipt flat on a contrasting surface, center it in the frame, keep the camera steady, and capture the entire receipt (including edges)."
                    )

                    tipItem(
                        icon: "text.viewfinder",
                        text: "What OCR tries to extract: merchant name, date, subtotal, taxes, and the final total. The app prioritizes the line labeled 'Total' or the largest monetary value."
                    )

                    tipItem(
                        icon: "square.and.pencil",
                        text: "Verify and edit: OCR results are suggestions — always confirm the detected amount, date, and category before saving, and correct any mistakes."
                    )

                    tipItem(
                        icon: "light.max",
                        text: "Troubleshooting: crop tightly to the receipt, increase lighting or contrast, avoid glare, and try multiple angles. If OCR repeatedly fails, use manual entry."
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
        .alert("Expense Reminder", isPresented: $showingNotificationAlert) {
            Button("OK") { }
        } message: {
            Text(notificationMessage)
        }
    }
    
    private func setupExpenseReminder() {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.scheduleExpenseReminder()
                } else {
                    self.notificationMessage = "Please enable notifications in Settings to receive expense reminders."
                    self.showingNotificationAlert = true
                }
            }
        }
    }
    
    private func scheduleExpenseReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Expense Reminder"
        content.subtitle = "MONO - Personal Finance"
        content.body = "Don't forget to log your recent expenses and receipts!"
        content.badge = 1
        content.sound = UNNotificationSound.default
        content.userInfo = ["category": "expense", "action": "add_expense"]
        
        // Schedule for 10 seconds from now (for demo purposes)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "expense_reminder_demo", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.notificationMessage = "Failed to schedule reminder: \(error.localizedDescription)"
                } else {
                    self.notificationMessage = "Expense reminder set! You'll receive a notification in 10 seconds."
                }
                self.showingNotificationAlert = true
            }
        }
    }
    
    private func instructionCard(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.monoPrimary)
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
                .foregroundColor(Color.monoPrimary)
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
                .foregroundColor(Color.monoPrimary)
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
}

#Preview {
    NavigationView {
        ExpenseHelpView()
    }
}

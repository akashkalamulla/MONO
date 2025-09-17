//
//  DependentRemindersView.swift
//  MONO
//
//  Created by Akash01 on 2025-09-17.
//

import SwiftUI
import MapKit

struct DependentRemindersView: View {
    let dependent: Dependent
    @ObservedObject var reminderManager: DependentReminderManager
    @State private var showingAddReminder = false
    @State private var selectedReminder: DependentReminder?
    @State private var showingReminderDetail = false
    
    private var activeReminders: [DependentReminder] {
        reminderManager.getActiveReminders(for: dependent.id)
    }
    
    private var completedReminders: [DependentReminder] {
        reminderManager.getReminders(for: dependent.id).filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Reminders for")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text(dependent.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.monoPrimary)
                    }
                    .padding(.top)
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        ReminderStatCard(
                            title: "Active",
                            count: activeReminders.count,
                            color: .blue
                        )
                        
                        ReminderStatCard(
                            title: "Overdue",
                            count: reminderManager.getOverdueReminders(for: dependent.id).count,
                            color: .red
                        )
                        
                        ReminderStatCard(
                            title: "Upcoming",
                            count: reminderManager.getUpcomingReminders(for: dependent.id).count,
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Active Reminders
                    if !activeReminders.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Reminders")
                                .font(.headline)
                                .foregroundColor(.monoPrimary)
                                .padding(.horizontal)
                            
                            ForEach(activeReminders) { reminder in
                                ReminderCard(
                                    reminder: reminder,
                                    onTap: {
                                        selectedReminder = reminder
                                        showingReminderDetail = true
                                    },
                                    onComplete: {
                                        reminderManager.completeReminder(reminder)
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Completed Reminders
                    if !completedReminders.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Completed Reminders")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            ForEach(completedReminders.prefix(5)) { reminder in
                                ReminderCard(
                                    reminder: reminder,
                                    onTap: {
                                        selectedReminder = reminder
                                        showingReminderDetail = true
                                    },
                                    onComplete: nil
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Empty State
                    if activeReminders.isEmpty && completedReminders.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "bell.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Reminders Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            
                            Text("Set up custom payment reminders for \(dependent.firstName)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 40)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddReminder = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.monoPrimary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddReminder) {
            AddDependentReminderView(reminderManager: reminderManager, dependent: dependent)
        }
        .sheet(isPresented: $showingReminderDetail) {
            if let reminder = selectedReminder {
                ReminderDetailView(reminder: reminder, reminderManager: reminderManager)
            }
        }
    }
}

struct ReminderStatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ReminderCard: View {
    let reminder: DependentReminder
    let onTap: () -> Void
    let onComplete: (() -> Void)?
    
    private var statusColor: Color {
        switch reminder.status {
        case .upcoming: return .blue
        case .overdue: return .red
        case .completed: return .green
        case .inactive: return .gray
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(reminder.paymentName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Rs. \(String(format: "%.2f", reminder.amount))")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.monoPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(reminder.status.title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor)
                            .cornerRadius(8)
                        
                        if !reminder.isCompleted && onComplete != nil {
                            Button(action: {
                                onComplete?()
                            }) {
                                Image(systemName: "checkmark.circle")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                HStack(spacing: 16) {
                    Label {
                        Text(formatDateTime(reminder.combinedDateTime))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                    }
                    
                    if let location = reminder.location {
                        Label {
                            Text(location.name)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } icon: {
                            Image(systemName: "location")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Location preview map for active reminders with location
                if let location = reminder.location, !reminder.isCompleted {
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )), annotationItems: [location]) { location in
                        MapPin(coordinate: location.coordinate, tint: .red)
                    }
                    .frame(height: 100)
                    .cornerRadius(8)
                    .allowsHitTesting(false)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: Date()) {
            formatter.timeStyle = .short
            return "Today at \(formatter.string(from: date))"
        } else if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
                  calendar.isDate(date, inSameDayAs: tomorrow) {
            formatter.timeStyle = .short
            return "Tomorrow at \(formatter.string(from: date))"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

struct ReminderDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let reminder: DependentReminder
    @ObservedObject var reminderManager: DependentReminderManager
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "bell.fill")
                            .font(.system(size: 60))
                            .foregroundColor(reminder.isCompleted ? .green : .monoPrimary)
                        
                        Text(reminder.paymentName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.monoPrimary)
                        
                        Text("Rs. \(String(format: "%.2f", reminder.amount))")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    // Details
                    VStack(spacing: 16) {
                        DetailRow(label: "Date & Time", value: formatDateTime(reminder.combinedDateTime))
                        DetailRow(label: "Status", value: reminder.status.title)
                        
                        if let completedAt = reminder.completedAt {
                            DetailRow(label: "Completed At", value: formatDateTime(completedAt))
                        }
                        
                        if let location = reminder.location {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Location")
                                    .font(.headline)
                                    .foregroundColor(.monoPrimary)
                                
                                Text(location.name)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                if let address = location.address {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                // Only show map if reminder is not completed (location disappears when completed)
                                if !reminder.isCompleted {
                                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                                        center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    )), annotationItems: [location]) { location in
                                        MapPin(coordinate: location.coordinate, tint: .red)
                                    }
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Actions
                    if !reminder.isCompleted {
                        VStack(spacing: 12) {
                            Button(action: {
                                reminderManager.completeReminder(reminder)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text("Mark as Completed")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Reminder")
                                }
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Reminder Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.monoPrimary)
                }
            }
        }
        .alert("Delete Reminder", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                reminderManager.deleteReminder(reminder)
                presentationMode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this reminder? This action cannot be undone.")
        }
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.monoPrimary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    let sampleDependent = Dependent(
        firstName: "Emma",
        lastName: "Smith",
        relationship: "Child",
        dateOfBirth: Calendar.current.date(byAdding: .year, value: -8, to: Date()) ?? Date(),
        phoneNumber: "555-0123",
        email: "emma@example.com",
        userId: UUID()
    )
    
    DependentRemindersView(
        dependent: sampleDependent,
        reminderManager: DependentReminderManager()
    )
}

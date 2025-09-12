# MONO App Notification System Documentation

## Overview
A comprehensive notification system has been implemented for the MONO app to provide working reminder functionality for income and expense tracking. The system includes local notifications, notification management, and UI integration.

## Components Implemented

### 1. NotificationManager.swift
**Location:** `/MONO/Managers/NotificationManager.swift`
**Purpose:** Central notification management system

**Key Features:**
- Singleton pattern for app-wide access
- Local notification scheduling with UNUserNotificationCenter
- Persistent notification storage using UserDefaults
- Support for recurring and one-time notifications
- Badge management for unread notifications

**Main Methods:**
- `scheduleIncomeReminder()` - Schedule recurring income reminders
- `scheduleExpenseReminder()` - Schedule recurring expense reminders  
- `schedulePaymentReminder()` - Schedule payment due reminders
- `requestNotificationPermission()` - Handle notification permissions
- `markAsRead()` - Mark notifications as read
- `deleteNotification()` - Remove scheduled notifications

### 2. NotificationView.swift
**Location:** `/MONO/Views/NotificationView.swift`
**Purpose:** Display and manage app notifications

**Features:**
- List view of all app notifications
- Mark as read/unread functionality
- Delete notifications capability
- Real-time updates with ObservableObject
- Empty state handling

### 3. AuthenticatedView.swift Integration
**Location:** `/MONO/Views/Income/Main/AuthenticatedView.swift`
**Updates:**
- Added notification bell icon in top-right header
- Replaced profile avatar with notification button
- Integrated notification badge system
- Connected to NotificationView through sheet presentation

### 4. Income Entry Integration
**Location:** `/MONO/Views/Income/SimpleIncomeEntry.swift`
**Features:**
- Automatic notification scheduling for recurring income
- NotificationManager integration
- User feedback about scheduled reminders
- Frequency conversion utilities

### 5. Expense Entry Integration
**Location:** `/MONO/Views/Expenses/SimpleExpenseEntry.swift`
**Features:**
- Recurring expense reminder scheduling
- Payment reminder notifications
- Monthly payment date calculation
- NotificationManager integration

### 6. OCR Expense Entry Integration
**Location:** `/MONO/Views/Expenses/OCRExpenseEntry.swift`
**Features:**
- Same notification capabilities as simple expense entry
- Supports both recurring and payment reminders
- Integrated with receipt scanning workflow

## Notification Types

### 1. Income Reminders
- **Trigger:** When user sets up recurring income
- **Frequencies:** Weekly, Bi-weekly, Monthly, Yearly
- **Content:** Reminds user to record income for specific category and amount

### 2. Expense Reminders  
- **Trigger:** When user sets up recurring expenses
- **Frequencies:** Daily, Weekly, Monthly, Yearly
- **Content:** Reminds user to record recurring expenses

### 3. Payment Reminders
- **Trigger:** When user enables payment reminders for expenses
- **Types:** One-time, Monthly, Yearly
- **Content:** Reminds user about upcoming payment due dates

## Data Persistence

### NotificationManager Storage
- Uses UserDefaults for JSON serialization
- Stores notification metadata and scheduling info
- Maintains read/unread state
- Preserves scheduled notification identifiers

### CoreData Integration
- Expense and Income entities store reminder preferences
- Links to notification scheduling through NotificationManager
- Maintains data consistency between forms and notifications

## UI/UX Features

### Visual Indicators
- Red badge dot on notification bell when unread notifications exist
- MonoPrimary color scheme integration
- Consistent iconography throughout app

### User Experience
- Permission requests handled gracefully
- Clear feedback when reminders are scheduled
- Easy access to notifications from main dashboard
- Intuitive mark as read/delete interactions

## Technical Implementation

### Permissions
- Requests notification permissions on first use
- Handles permission denied scenarios
- Provides fallback for users without notifications enabled

### Scheduling
- Uses UNCalendarNotificationTrigger for recurring reminders
- UNTimeIntervalNotificationTrigger for one-time notifications
- Proper timezone handling and date calculations
- Unique identifiers for each scheduled notification

### Error Handling
- Validates notification content before scheduling
- Handles scheduling failures gracefully
- Provides user feedback for error conditions

## Integration Points

### Help Views
- `IncomeHelpView.swift` includes notification setup demos
- `ExpenseHelpView.swift` explains reminder functionality
- User education about notification features

### Form Integration
- All income/expense entry forms support notification scheduling
- Toggles for enabling/disabling reminders
- Frequency selection and date pickers
- Real-time feedback about scheduled reminders

## Future Enhancements

### Potential Improvements
1. Custom notification sounds
2. Rich notification content with images
3. Notification history and analytics
4. Smart reminder suggestions based on spending patterns
5. Integration with calendar apps
6. Push notifications for cloud sync

### Scalability Considerations
- Current system supports local notifications only
- Architecture allows for future push notification integration
- NotificationManager can be extended for additional notification types
- Modular design supports easy feature additions

## Testing Recommendations

### Manual Testing
1. Test notification permissions flow
2. Verify recurring reminder scheduling
3. Check payment reminder calculations
4. Test notification badge updates
5. Verify mark as read/delete functionality

### Integration Testing
- Test with different iOS notification settings
- Verify background notification delivery
- Check timezone handling for scheduled reminders
- Test with different user permission scenarios

## Conclusion

The MONO app now has a fully functional notification system that enhances user engagement and helps maintain consistent financial tracking habits. The system is designed to be user-friendly, reliable, and expandable for future feature additions.

import XCTest
@testable import MONO


// These check basic creation and properties
class SimpleExpenseTests: XCTestCase {
    
    // Test creating a basic expense with location and association
    func testCreateExpenseWithLocationAndAssociation() {

        let amount = 45.75
        let category = "food"
        let description = "Lunch at cafe"
        let userID = UUID()
        let dependentID = UUID()
        let locationName = "Cafe Central"
        let latitude = 12.3456
        let longitude = 65.4321
        
        let expense = ExpenseModel(
            amount: amount,
            category: category,
            description: description,
            userID: userID,
            dependentID: dependentID,
            locationName: locationName,
            latitude: latitude,
            longitude: longitude
        )
        
        XCTAssertEqual(expense.amount, 45.75, "Amount should be set correctly")
        XCTAssertEqual(expense.category, "food", "Category should match")
        XCTAssertEqual(expense.description, "Lunch at cafe", "Description should match")
        XCTAssertEqual(expense.userID, userID, "User ID should match")
        XCTAssertEqual(expense.dependentID, dependentID, "Dependent ID should match")
        XCTAssertEqual(expense.locationName, "Cafe Central", "Location name should match")
        XCTAssertEqual(expense.latitude, 12.3456, "Latitude should match")
        XCTAssertEqual(expense.longitude, 65.4321, "Longitude should match")
    }
    
    // Test reminder settings on an expense
    func testExpenseReminderSettings() {
        let userID = UUID()
        let reminderDate = Date().addingTimeInterval(60 * 60 * 24)
        
        let expense = ExpenseModel(
            amount: 120.0,
            category: "utilities",
            isPaymentReminder: true,
            reminderDate: reminderDate,
            reminderDayOfMonth: 15,
            reminderFrequency: .monthly,
            isReminderActive: true,
            userID: userID
        )
        
        XCTAssertTrue(expense.isPaymentReminder, "Expense should be marked as payment reminder")
        XCTAssertEqual(expense.reminderDayOfMonth, 15, "Reminder day of month should be 15")
        XCTAssertEqual(expense.reminderFrequency, .monthly, "Reminder frequency should be monthly")
        XCTAssertTrue(expense.isReminderActive, "Reminder should be active")
        XCTAssertEqual(expense.reminderDate, reminderDate, "Reminder date should match")
    }
    
    // Test recurring expense flag and frequency
    func testRecurringExpense() {
        let userID = UUID()
        
        let recurringExpense = ExpenseModel(
            amount: 800.0,
            category: "housing",
            isRecurring: true,
            recurringFrequency: .monthly,
            userID: userID
        )
        
        XCTAssertTrue(recurringExpense.isRecurring, "Expense should be recurring")
        XCTAssertEqual(recurringExpense.recurringFrequency, .monthly, "Should recur monthly")
    }
    
    // Test default values for optional fields
    func testExpenseDefaultOptionalFields() {
        let userID = UUID()
        
        let expense = ExpenseModel(amount: 10.0, category: "other", userID: userID)
        
        XCTAssertNil(expense.description, "Description should be nil by default")
        XCTAssertFalse(expense.isRecurring, "Should not be recurring by default")
        XCTAssertFalse(expense.isPaymentReminder, "Should not be payment reminder by default")
        XCTAssertNil(expense.reminderDate, "Reminder date should be nil by default")
        XCTAssertNil(expense.latitude, "Latitude should be nil by default")
        XCTAssertNil(expense.longitude, "Longitude should be nil by default")
    }
    
    // Test calculating total of multiple expenses
    func testCalculateTotalExpenses() {
        let userID = UUID()
        let expenses = [
            ExpenseModel(amount: 5.0, category: "food", userID: userID),
            ExpenseModel(amount: 15.0, category: "transport", userID: userID),
            ExpenseModel(amount: 30.0, category: "shopping", userID: userID)
        ]
        
        let total = expenses.reduce(0.0) { $0 + $1.amount }
        
        XCTAssertEqual(total, 50.0, "Total expenses should be 50")
    }
}

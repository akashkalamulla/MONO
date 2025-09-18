import XCTest
import SwiftUI
@testable import MONO

// These tests check small utility
class SimpleColorAndCategoryTests: XCTestCase {
    
    func testCreateColorFromHex() {
        let redHex = "#FF0000"
        
        let redColor = Color(hex: redHex)

        XCTAssertNotNil(redColor, "Color should be created from hex code")
    }
    
    // Test different hex color formats
    func testDifferentHexFormats() {
        let sixDigitHex = "#FF5722"
        let threeDigitHex = "#F57"
        
        let color1 = Color(hex: sixDigitHex)
        let color2 = Color(hex: threeDigitHex)
        
        XCTAssertNotNil(color1, "Should create color from 6-digit hex")
        XCTAssertNotNil(color2, "Should create color from 3-digit hex")
    }
    
    // Test hex colors without # symbol
    func testHexWithoutHashSymbol() {
        let hexWithoutHash = "FF5722"
        
        let color = Color(hex: hexWithoutHash)
        
        XCTAssertNotNil(color, "Should work even without # symbol")
    }
    
    // Test expense categories
    func testExpenseCategoriesExist() {
        let categories = ExpenseCategory.defaultCategories
        
        XCTAssertEqual(categories.count, 9, "Should have 9 default expense categories")
    }
    
    func testExpenseCategoryHasRequiredInfo() {

        let foodCategory = ExpenseCategory.defaultCategories[0]
        
        XCTAssertEqual(foodCategory.id, "food", "Food category ID should be 'food'")
        XCTAssertEqual(foodCategory.name, "Food & Dining", "Name should be 'Food & Dining'")
        XCTAssertEqual(foodCategory.icon, "fork.knife", "Should have fork.knife icon")
        XCTAssertEqual(foodCategory.color, "#FF5722", "Should have orange color")
        XCTAssertFalse(foodCategory.name.isEmpty, "Name should not be empty")
        XCTAssertFalse(foodCategory.icon.isEmpty, "Icon should not be empty")
    }
    
    // Test different expense categories
    func testDifferentExpenseCategories() {
        let categories = ExpenseCategory.defaultCategories
        
        let transportCategory = categories.first { $0.id == "transport" }
        let housingCategory = categories.first { $0.id == "housing" }
        let shoppingCategory = categories.first { $0.id == "shopping" }
        
        XCTAssertNotNil(transportCategory, "Transport category should exist")
        XCTAssertEqual(transportCategory?.name, "Transportation", "Transport name should be correct")
        
        XCTAssertNotNil(housingCategory, "Housing category should exist")
        XCTAssertEqual(housingCategory?.name, "Housing", "Housing name should be correct")
        
        XCTAssertNotNil(shoppingCategory, "Shopping category should exist")
        XCTAssertEqual(shoppingCategory?.name, "Shopping", "Shopping name should be correct")
    }
    
    // Test that category IDs are unique
    func testExpenseCategoryIDsAreUnique() {
        let categories = ExpenseCategory.defaultCategories
        let categoryIDs = categories.map { $0.id }
        
        let uniqueIDs = Set(categoryIDs)

        XCTAssertEqual(categoryIDs.count, uniqueIDs.count, "All category IDs should be unique")
    }
    
    // Test expense recurrence frequency display names
    func testExpenseRecurrenceFrequencyDisplayNames() {
        let daily = ExpenseRecurrenceFrequency.daily
        let weekly = ExpenseRecurrenceFrequency.weekly
        let monthly = ExpenseRecurrenceFrequency.monthly
        let yearly = ExpenseRecurrenceFrequency.yearly
        
        XCTAssertEqual(daily.displayName, "Daily", "Daily should display as 'Daily'")
        XCTAssertEqual(weekly.displayName, "Weekly", "Weekly should display as 'Weekly'")
        XCTAssertEqual(monthly.displayName, "Monthly", "Monthly should display as 'Monthly'")
        XCTAssertEqual(yearly.displayName, "Yearly", "Yearly should display as 'Yearly'")
    }
    
    // Test payment reminder frequency display names
    func testPaymentReminderFrequencyDisplayNames() {
        let once = PaymentReminderFrequency.once
        let monthly = PaymentReminderFrequency.monthly
        let yearly = PaymentReminderFrequency.yearly
        
        XCTAssertEqual(once.displayName, "Once", "Once should display as 'Once'")
        XCTAssertEqual(monthly.displayName, "Monthly", "Monthly should display as 'Monthly'")
        XCTAssertEqual(yearly.displayName, "Yearly", "Yearly should display as 'Yearly'")
    }
    
    // Test creating a basic expense
    func testCreateBasicExpense() {
        let amount = 25.50
        let category = "food"
        let description = "Coffee and snack"
        let userID = UUID()
        
        let expense = ExpenseModel(
            amount: amount,
            category: category,
            description: description,
            userID: userID
        )
        
        XCTAssertEqual(expense.amount, 25.50, "Amount should be 25.50")
        XCTAssertEqual(expense.category, "food", "Category should be 'food'")
        XCTAssertEqual(expense.description, "Coffee and snack", "Description should match")
        XCTAssertEqual(expense.userID, userID, "User ID should match")
        XCTAssertNotNil(expense.id, "Expense should have an ID")
        XCTAssertFalse(expense.isRecurring, "Should not be recurring by default")
        XCTAssertFalse(expense.isPaymentReminder, "Should not be a payment reminder by default")
    }
    
    // Test that expense categories have valid colors
    func testExpenseCategoryColorsAreValid() {
        let categories = ExpenseCategory.defaultCategories
        
        for category in categories {
            XCTAssertTrue(category.color.hasPrefix("#"), "Color should start with #: \(category.name)")
            XCTAssertTrue(category.color.count == 7, "Color should be 7 characters (#RRGGBB): \(category.name)")
            
            let color = Color(hex: category.color)
            XCTAssertNotNil(color, "Should be able to create Color from hex: \(category.color)")
        }
    }
}

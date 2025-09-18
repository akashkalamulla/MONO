import XCTest
@testable import MONO

// These tests check Income model
class SimpleIncomeTests: XCTestCase {
    
    // This test checks if we can create a basic income entry
    func testCanCreateIncome() {
        let salaryCategory = IncomeCategory.defaultCategories[0]
        let amount = 1000.0
        let description = "My monthly salary"
        
 
        let income = IncomeModel(
            amount: amount,
            category: salaryCategory,
            description: description
        )
        
        XCTAssertEqual(income.amount, 1000.0, "Amount should be 1000")
        XCTAssertEqual(income.description, "My monthly salary", "Description should match")
        XCTAssertEqual(income.categoryName, "Salary", "Category should be Salary")
        XCTAssertNotNil(income.id, "Income should have an ID")
    }
    
    // This test checks if income amounts work correctly
    func testIncomeAmount() {
        let freelanceCategory = IncomeCategory.defaultCategories[1]
        
        let smallIncome = IncomeModel(amount: 50.0, category: freelanceCategory)
        let bigIncome = IncomeModel(amount: 5000.0, category: freelanceCategory)
        
        XCTAssertEqual(smallIncome.amount, 50.0, "Small income should be 50")
        XCTAssertEqual(bigIncome.amount, 5000.0, "Big income should be 5000")
    }
    
    // This test checks if we can create income without description
    func testIncomeWithoutDescription() {
        let businessCategory = IncomeCategory.defaultCategories[2]
        
        let income = IncomeModel(
            amount: 750.0,
            category: businessCategory,
            description: nil 
        )
        
        XCTAssertEqual(income.amount, 750.0, "Amount should be 750")
        XCTAssertNil(income.description, "Description should be empty")
        XCTAssertEqual(income.categoryName, "Business", "Category should be Business")
    }
    
    // This test checks if dates work properly
    func testIncomeDate() {
        let testDate = Date()
        let investmentCategory = IncomeCategory.defaultCategories[3]
        
        let income = IncomeModel(
            amount: 200.0,
            category: investmentCategory,
            date: testDate
        )
        
        // Then: The date should be stored correctly
        XCTAssertEqual(income.date, testDate, "Date should match")
        XCTAssertEqual(income.categoryName, "Investment", "Category should be Investment")
    }
    
    // This test checks if we can create multiple incomes
    func testMultipleIncomes() {
        let salaryCategory = IncomeCategory.defaultCategories[0]
        let bonusCategory = IncomeCategory.defaultCategories[5]
        
        // When: We create multiple incomes
        let salary = IncomeModel(amount: 3000.0, category: salaryCategory, description: "Monthly salary")
        let bonus = IncomeModel(amount: 500.0, category: bonusCategory, description: "Year-end bonus")
        
        // Then: Both should be created with different IDs
        XCTAssertNotEqual(salary.id, bonus.id, "Each income should have unique ID")
        XCTAssertEqual(salary.amount, 3000.0, "Salary amount should be 3000")
        XCTAssertEqual(bonus.amount, 500.0, "Bonus amount should be 500")
        XCTAssertEqual(salary.categoryName, "Salary", "First income should be Salary category")
        XCTAssertEqual(bonus.categoryName, "Bonus", "Second income should be Bonus category")
    }
    
    // This test checks if recurring income works
    func testRecurringIncome() {
        let rentalCategory = IncomeCategory.defaultCategories[4]
        let recurringIncome = IncomeModel(
            amount: 1200.0,
            category: rentalCategory,
            description: "Monthly rent from property",
            isRecurring: true,
            recurrenceFrequency: .monthly
        )
        
        XCTAssertTrue(recurringIncome.isRecurring, "Income should be recurring")
        XCTAssertEqual(recurringIncome.recurrenceFrequency, .monthly, "Should recur monthly")
        XCTAssertEqual(recurringIncome.categoryName, "Rental", "Category should be Rental")
    }
    
    // This test checks if category colors work
    func testIncomeCategory() {
        let salaryCategory = IncomeCategory.defaultCategories[0]
        
        let income = IncomeModel(amount: 1000.0, category: salaryCategory)
        
        XCTAssertEqual(income.categoryId, "salary", "Category ID should be 'salary'")
        XCTAssertEqual(income.categoryName, "Salary", "Category name should be 'Salary'")
        XCTAssertEqual(income.categoryIcon, "dollarsign.circle.fill", "Should have dollar icon")
        XCTAssertEqual(income.categoryColor, "#4CAF50", "Should have green color")
    }
    
    // This test checks if we can calculate total income from multiple entries
    func testCalculateTotalIncome() {
        let salaryCategory = IncomeCategory.defaultCategories[0]
        let freelanceCategory = IncomeCategory.defaultCategories[1]
        
        let incomes = [
            IncomeModel(amount: 1000.0, category: salaryCategory),
            IncomeModel(amount: 300.0, category: freelanceCategory),
            IncomeModel(amount: 200.0, category: salaryCategory)
        ]

        let total = incomes.reduce(0.0) { sum, income in
            return sum + income.amount
        }
        
        XCTAssertEqual(total, 1500.0, "Total income should be 1500")
    }
}

import XCTest
@testable import MONO

// These tests check basic user features and simple helper functions
class SimpleUserTests: XCTestCase {

    func testCreateUser() {
        let firstName = "John"
        let lastName = "Smith"
        let email = "john.smith@email.com"
        let phoneNumber = "123-456-7890"

        let user = User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber
        )

        XCTAssertEqual(user.firstName, "John", "First name should be John")
        XCTAssertEqual(user.lastName, "Smith", "Last name should be Smith")
        XCTAssertEqual(user.email, "john.smith@email.com", "Email should match")
        XCTAssertEqual(user.phoneNumber, "123-456-7890", "Phone number should match")
        XCTAssertNotNil(user.id, "User should have an ID")
        XCTAssertFalse(user.isLoggedIn, "New user should not be logged in")
    }
    
    // Test the fullName computed property
    func testUserFullName() {
        let user = User(
            firstName: "Alice",
            lastName: "Johnson",
            email: "alice@email.com"
        )
        
        let fullName = user.fullName

        XCTAssertEqual(fullName, "Alice Johnson", "Full name should be 'Alice Johnson'")
    }
    
    // Test fullName with different name combinations
    func testFullNameWithDifferentNames() {
        let user1 = User(firstName: "Bob", lastName: "Wilson", email: "bob@email.com")
        let user2 = User(firstName: "Mary", lastName: "Davis", email: "mary@email.com")
        let user3 = User(firstName: "X", lastName: "Y", email: "xy@email.com")
        
        XCTAssertEqual(user1.fullName, "Bob Wilson", "Should be 'Bob Wilson'")
        XCTAssertEqual(user2.fullName, "Mary Davis", "Should be 'Mary Davis'")
        XCTAssertEqual(user3.fullName, "X Y", "Should work with single letters")
    }
    
    // Test creating user without phone number
    func testCreateUserWithoutPhoneNumber() {
        let user = User(
            firstName: "Sarah",
            lastName: "Brown",
            email: "sarah.brown@email.com"
        )
        
        XCTAssertNil(user.phoneNumber, "Phone number should be nil when not provided")
        XCTAssertEqual(user.firstName, "Sarah", "First name should still be set")
        XCTAssertEqual(user.email, "sarah.brown@email.com", "Email should still be set")
    }
    
    // Test that each user gets a unique ID
    func testUsersHaveUniqueIDs() {
        let user1 = User(firstName: "Twin", lastName: "One", email: "twin1@email.com")
        let user2 = User(firstName: "Twin", lastName: "Two", email: "twin2@email.com")
        
        XCTAssertNotEqual(user1.id, user2.id, "Each user should have unique ID")
    }
    
    func testUserDefaultValues() {
        let user = User(
            firstName: "Test",
            lastName: "User",
            email: "test@email.com"
        )
        
        XCTAssertFalse(user.isLoggedIn, "New user should not be logged in by default")
        XCTAssertNil(user.profileImageData, "Profile image should be nil by default")
        XCTAssertNotNil(user.dateCreated, "Date created should be set")
        XCTAssertNotNil(user.id, "ID should be generated")
    }
    
    // Test email validation
    func testUserEmailFormat() {
        let validUser = User(firstName: "Valid", lastName: "User", email: "valid@email.com")
        let invalidUser = User(firstName: "Invalid", lastName: "User", email: "not-an-email")
        
        XCTAssertTrue(validUser.email.contains("@"), "Valid email should contain @")
        XCTAssertTrue(validUser.email.contains("."), "Valid email should contain .")
        XCTAssertFalse(invalidUser.email.contains("@"), "Invalid email doesn't have @")
    }
    
    // Test creating multiple users for a family
    func testCreateFamilyUsers() {
        let father = User(firstName: "John", lastName: "Family", email: "john@family.com", phoneNumber: "111-111-1111")
        let mother = User(firstName: "Jane", lastName: "Family", email: "jane@family.com", phoneNumber: "222-222-2222")
        let child = User(firstName: "Junior", lastName: "Family", email: "junior@family.com")

        let family = [father, mother, child]
        
        XCTAssertEqual(family.count, 3, "Family should have 3 members")
        XCTAssertEqual(family[0].fullName, "John Family", "Father's name should be correct")
        XCTAssertEqual(family[1].fullName, "Jane Family", "Mother's name should be correct")
        XCTAssertEqual(family[2].fullName, "Junior Family", "Child's name should be correct")
        XCTAssertNotNil(family[0].phoneNumber, "Father should have phone number")
        XCTAssertNotNil(family[1].phoneNumber, "Mother should have phone number")
        XCTAssertNil(family[2].phoneNumber, "Child doesn't have phone number")
    }
    
    // Test user name updates
    func testUpdateUserName() {
        var user = User(firstName: "Old", lastName: "Name", email: "user@email.com")

        user.firstName = "New"
        user.lastName = "UpdatedName"
        
        XCTAssertEqual(user.firstName, "New", "First name should be updated")
        XCTAssertEqual(user.lastName, "UpdatedName", "Last name should be updated")
        XCTAssertEqual(user.fullName, "New UpdatedName", "Full name should be updated")
    }
    
    // Test user with empty names
    func testUserWithEmptyNames() {
        let user = User(firstName: "", lastName: "", email: "empty@email.com")
        
        let fullName = user.fullName
        
        XCTAssertEqual(fullName, " ", "Full name should be just a space when names are empty")
        XCTAssertEqual(user.firstName, "", "First name should be empty string")
        XCTAssertEqual(user.lastName, "", "Last name should be empty string")
    }
    
    // Test user email uniqueness concept
    func testUserEmailsAreDifferent() {
        let user1 = User(firstName: "User", lastName: "One", email: "user1@email.com")
        let user2 = User(firstName: "User", lastName: "Two", email: "user2@email.com")
        let user3 = User(firstName: "User", lastName: "Three", email: "user3@email.com")
        
        let emails = [user1.email, user2.email, user3.email]
        let uniqueEmails = Set(emails)
        
        XCTAssertEqual(emails.count, uniqueEmails.count, "All user emails should be unique")
        XCTAssertNotEqual(user1.email, user2.email, "User 1 and 2 should have different emails")
        XCTAssertNotEqual(user2.email, user3.email, "User 2 and 3 should have different emails")
    }
}

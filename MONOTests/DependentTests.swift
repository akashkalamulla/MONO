import XCTest
@testable import MONO
// tests Dependent model
class SimpleDependentTests: XCTestCase {
    
    // Test create a basic dependent
    func testCreateDependent() {
        let firstName = "John"
        let lastName = "Doe"
        let relationship = "Son"
        let dateOfBirth = Date()
        let userId = UUID()
        
        let dependent = Dependent(
            firstName: firstName,
            lastName: lastName,
            relationship: relationship,
            dateOfBirth: dateOfBirth,
            userId: userId
        )
        
        XCTAssertEqual(dependent.firstName, "John", "First name should be John")
        XCTAssertEqual(dependent.lastName, "Doe", "Last name should be Doe")
        XCTAssertEqual(dependent.relationship, "Son", "Relationship should be Son")
        XCTAssertNotNil(dependent.id, "Dependent should have an ID")
        XCTAssertTrue(dependent.isActive, "New dependent should be active by default")
    }
    
    // Test fullName
    func testDependentFullName() {
        let dependent = Dependent(
            firstName: "Alice",
            lastName: "Smith",
            relationship: "Daughter",
            dateOfBirth: Date(),
            userId: UUID()
        )
        
        let fullName = dependent.fullName
        
        XCTAssertEqual(fullName, "Alice Smith", "Full name should be 'Alice Smith'")
    }
    
    func testDependentInitials() {
        let dependent = Dependent(
            firstName: "Bob",
            lastName: "Johnson",
            relationship: "Brother",
            dateOfBirth: Date(),
            userId: UUID()
        )
        
        let initials = dependent.initials
        
        XCTAssertEqual(initials, "BJ", "Initials should be 'BJ'")
    }
    
    // Test initials with lowercase names
    func testInitialsWithLowercaseNames() {
        let dependent = Dependent(
            firstName: "mary",
            lastName: "brown",
            relationship: "Sister",
            dateOfBirth: Date(),
            userId: UUID()
        )
        
        let initials = dependent.initials
        
        XCTAssertEqual(initials, "MB", "Initials should be uppercase 'MB'")
    }
    
    // Test the age calculation
    func testDependentAge() {
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -25, to: Date())!
        
        let dependent = Dependent(
            firstName: "Alex",
            lastName: "Wilson",
            relationship: "Child",
            dateOfBirth: birthDate,
            userId: UUID()
        )
        
        let age = dependent.age
        XCTAssertEqual(age, 25, "Age should be 25 years")
    }
    
    // Test age for a child
    func testChildAge() {
        let thisYear = Date()
        
        let dependent = Dependent(
            firstName: "Baby",
            lastName: "Smith",
            relationship: "Child",
            dateOfBirth: thisYear,
            userId: UUID()
        )
        
        let age = dependent.age
        
        XCTAssertEqual(age, 0, "Baby should be 0 years old")
    }
    
    // Test creating dependent with optional fields
    func testDependentWithOptionalFields() {
        let dependent = Dependent(
            firstName: "Sarah",
            lastName: "Davis",
            relationship: "Mother",
            dateOfBirth: Date(),
            phoneNumber: "123-456-7890",
            email: "sarah@email.com",
            userId: UUID()
        )
        
        XCTAssertEqual(dependent.phoneNumber, "123-456-7890", "Phone number should match")
        XCTAssertEqual(dependent.email, "sarah@email.com", "Email should match")
        XCTAssertEqual(dependent.relationship, "Mother", "Relationship should be Mother")
    }
    
    // Test that each dependent gets a unique ID
    func testUniqueIDs() {
        let userId = UUID()
        
        let dependent1 = Dependent(
            firstName: "Twin",
            lastName: "One",
            relationship: "Child",
            dateOfBirth: Date(),
            userId: userId
        )
        
        let dependent2 = Dependent(
            firstName: "Twin",
            lastName: "Two",
            relationship: "Child",
            dateOfBirth: Date(),
            userId: userId
        )
        
        XCTAssertNotEqual(dependent1.id, dependent2.id, "Each dependent should have unique ID")
    }
    
    // Test default values when creating a dependent
    func testDefaultValues() {
        let dependent = Dependent(
            firstName: "Test",
            lastName: "User",
            relationship: "Friend",
            dateOfBirth: Date(),
            userId: UUID()
        )
        
        XCTAssertTrue(dependent.isActive, "New dependent should be active")
        XCTAssertEqual(dependent.phoneNumber, "", "Phone should be empty by default")
        XCTAssertEqual(dependent.email, "", "Email should be empty by default")
        XCTAssertNotNil(dependent.dateAdded, "Date added should be set")
    }
    
    // Test different relationship types
    func testDifferentRelationships() {
        let userId = UUID()
        
        let child = Dependent(firstName: "Kid", lastName: "Smith", relationship: "Child", dateOfBirth: Date(), userId: userId)
        let spouse = Dependent(firstName: "Partner", lastName: "Smith", relationship: "Spouse", dateOfBirth: Date(), userId: userId)
        let parent = Dependent(firstName: "Mom", lastName: "Smith", relationship: "Parent", dateOfBirth: Date(), userId: userId)
        
        XCTAssertEqual(child.relationship, "Child", "Should be Child")
        XCTAssertEqual(spouse.relationship, "Spouse", "Should be Spouse")
        XCTAssertEqual(parent.relationship, "Parent", "Should be Parent")
    }
}

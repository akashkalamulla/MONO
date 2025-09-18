import XCTest
@testable import MONO

// These tests focus on simple behaviors
class SimpleNotificationTests: XCTestCase {
    let manager = NotificationManager.shared
    
    override func setUp() {
        super.setUp()
        DispatchQueue.main.sync {
            self.manager.notifications = []
            self.manager.hasUnreadNotifications = false
        }
        UserDefaults.standard.removeObject(forKey: "saved_notifications")
    }
    
    override func tearDown() {
        // Clean up after tests
        DispatchQueue.main.sync {
            self.manager.notifications = []
            self.manager.hasUnreadNotifications = false
        }
        UserDefaults.standard.removeObject(forKey: "saved_notifications")
        super.tearDown()
    }
    
    func testAddNotificationUpdatesListAndUnreadStatus() {
        let expectation = self.expectation(description: "addNotification updates notifications and unread status")
        
        manager.addNotification(title: "Test Title", message: "Test message", type: .reminder)

        DispatchQueue.main.async {
            XCTAssertEqual(self.manager.notifications.count, 1, "There should be one notification after adding")
            XCTAssertTrue(self.manager.hasUnreadNotifications, "hasUnreadNotifications should be true after adding an unread notification")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testMarkAsReadClearsUnreadFlag() {
        let expectation = self.expectation(description: "markAsRead sets isRead and updates unread flag")
        
        // Arrange: add a notification
        manager.addNotification(title: "Read Test", message: "Please read me", type: .income)
        
        DispatchQueue.main.async {
            XCTAssertEqual(self.manager.notifications.count, 1)
            let notif = self.manager.notifications[0]
            XCTAssertFalse(notif.isRead)
            
            self.manager.markAsRead(notif)
            
            // MarkAsRead updates on main queue too; check again on next run loop
            DispatchQueue.main.async {
                XCTAssertTrue(self.manager.notifications[0].isRead, "Notification should be marked as read")
                XCTAssertFalse(self.manager.hasUnreadNotifications, "No unread notifications should remain")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testDeleteNotificationRemovesItFromList() {
        let expectation = self.expectation(description: "deleteNotification removes notification from list")
        
        manager.addNotification(title: "To Delete", message: "Delete me", type: .expense)
        
        DispatchQueue.main.async {
            XCTAssertEqual(self.manager.notifications.count, 1)
            let notif = self.manager.notifications[0]
            self.manager.deleteNotification(notif)
            
            DispatchQueue.main.async {
                XCTAssertEqual(self.manager.notifications.count, 0, "Notification list should be empty after deletion")
                XCTAssertFalse(self.manager.hasUnreadNotifications, "No unread notifications after deletion")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testClearAllNotificationsRemovesAll() {
        let expectation = self.expectation(description: "clearAllNotifications clears notifications")
        
        // Add multiple notifications
        manager.addSampleNotifications()
        
        DispatchQueue.main.async {
            XCTAssertTrue(self.manager.notifications.count >= 1, "Should have sample notifications after adding")
            self.manager.clearAllNotifications()
            
            DispatchQueue.main.async {
                XCTAssertEqual(self.manager.notifications.count, 0, "All notifications should be removed")
                XCTAssertFalse(self.manager.hasUnreadNotifications, "No unread notifications after clearing")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0)
    }
}

import SwiftUI
import CoreData
import UserNotifications

@main
struct MONOApp: App {
    @StateObject private var authManager = AuthenticationManager()
    let persistenceController = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    AuthenticatedView(authManager: authManager)
                        .environment(\.managedObjectContext, persistenceController.context)
                } else {
                    SplashView()
                        .environmentObject(authManager)
                        .environment(\.managedObjectContext, persistenceController.context)
                }
            }
            .onAppear {
                // Request notification permissions on launch (Simulator test helper)
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    print("Notifications permission granted:", granted, "error:", error as Any)
                }
                UNUserNotificationCenter.current().delegate = NotificationHandler.shared
            }
        }
    }
}

// Simple notification handler to allow foreground presentation while testing
final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

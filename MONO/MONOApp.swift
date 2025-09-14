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
                // Ensure our notification handler is set before requesting permissions
                UNUserNotificationCenter.current().delegate = NotificationHandler.shared

                // Request notification permissions on launch (Simulator test helper)
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    print("Notifications permission granted:", granted, "error:", error as Any)
                }
            }
        }
    }
}

// Simple notification handler to allow foreground presentation while testing
final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Include .alert for broader compatibility (simulator / older iOS) so notifications appear in foreground
        completionHandler([.banner, .alert, .sound, .badge])

        // Mirror the delivered notification to the in-app NotificationManager so users see it in the Notifications tab
        let content = notification.request.content
        let title = content.title.isEmpty ? "" : content.title
        let body = content.body.isEmpty ? "" : content.body
    print("NotificationHandler willPresent - forwarding notification to in-app manager: \(title) - \(body)")
        DispatchQueue.main.async {
            // Use .reminder as a generic type for forwarded system/local notifications
            NotificationManager.shared.addNotification(title: title, message: body, type: .reminder, scheduledDate: Date())
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Called when the user taps the notification — ensure it's recorded in the in-app list
        let content = response.notification.request.content
        let title = content.title.isEmpty ? "" : content.title
        let body = content.body.isEmpty ? "" : content.body
    print("NotificationHandler didReceive response - forwarding notification to in-app manager: \(title) - \(body)")
        DispatchQueue.main.async {
            NotificationManager.shared.addNotification(title: title, message: body, type: .reminder, scheduledDate: Date())
        }
        completionHandler()
    }
}

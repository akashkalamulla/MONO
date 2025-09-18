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
                UNUserNotificationCenter.current().delegate = NotificationHandler.shared
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    print("Notifications permission granted:", granted, "error:", error as Any)
                }
            }
        }
    }
}

final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .alert, .sound, .badge])
        let content = notification.request.content
        let title = content.title.isEmpty ? "" : content.title
        let body = content.body.isEmpty ? "" : content.body
    print("NotificationHandler willPresent - forwarding notification to in-app manager: \(title) - \(body)")
        DispatchQueue.main.async {
            NotificationManager.shared.addNotification(title: title, message: body, type: .reminder, scheduledDate: Date())
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
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

import SwiftUI
import CoreData

@main
struct MONOApp: App {
    @StateObject private var authManager = AuthenticationManager()
    let persistenceController = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                AuthenticatedView(authManager: authManager)
                    .environment(\.managedObjectContext, persistenceController.context)
            } else {
                SplashView()
                    .environmentObject(authManager)
                    .environment(\.managedObjectContext, persistenceController.context)
            }
        }
    }
}

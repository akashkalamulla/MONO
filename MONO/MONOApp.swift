//
//  MONOApp.swift
//  MONO
//
//  Created by Akash01 on 2025-08-15.
//

import SwiftUI

@main
struct MONOApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

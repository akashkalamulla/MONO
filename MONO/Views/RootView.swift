//
//  RootView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-16.
//

import SwiftUI

struct RootView: View {
    @StateObject private var authManager: AuthManager
    @State private var showSplash = true
    
    init() {
        self._authManager = StateObject(wrappedValue: AuthManager(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                if authManager.isLoggedIn {
                    DashboardView()
                        .environmentObject(authManager)
                } else {
                    GetStartedView()
                        .environmentObject(authManager)
                }
            }
        }
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        .onAppear {
            // Create a test user for testing (remove this in production)
            authManager.createTestUser()
        }
    }
}

#Preview {
    RootView()
}

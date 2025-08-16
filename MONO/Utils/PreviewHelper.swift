//
//  PreviewHelper.swift
//  MONO
//
//  Created by Akash01 on 2025-08-16.
//

import SwiftUI

struct PreviewWrapper<Content: View>: View {
    let content: Content
    @StateObject private var authManager = AuthManager(context: PersistenceController.preview.container.viewContext)
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .environmentObject(authManager)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

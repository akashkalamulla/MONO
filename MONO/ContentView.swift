//
//  ContentView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-15.
//

import SwiftUI

// Legacy ContentView - replaced by SplashView and MainView
// Keeping for reference, but no longer used in the app

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

//
//  SplashView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-15.
//

import SwiftUI

struct SplashView: View {
    @State private var isLoading = true
    @State private var showMainView = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // MONO Logo Text
                    Text("mono")
                        .font(.system(size: 48, weight: .medium, design: .default))
                        .foregroundColor(.monoPrimary)
                        .tracking(2) // Letter spacing
                    
                    // Loading Indicator
                    if isLoading {
                        LoadingIndicator()
                            .frame(width: 30, height: 30)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // Simulate loading time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isLoading = false
                    showMainView = true
                }
            }
        }
        .fullScreenCover(isPresented: $showMainView) {
            GetStartedView()
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AuthenticationManager())
}

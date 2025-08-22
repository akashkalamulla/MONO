import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var isLoading = true
    @State private var showGetStarted = false
    @State private var showLogin = false
    
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
                    
                    // Check if user needs to see get started or login
                    if authManager.currentUser != nil {
                        // User exists but not authenticated - show login
                        showLogin = true
                    } else {
                        // No user - show get started
                        showGetStarted = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showGetStarted) {
            GetStartedView()
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
                .environmentObject(authManager)
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AuthenticationManager())
}

import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var isLoading = true
    @State private var showGetStarted = false
    @State private var showLogin = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    Text("mono")
                        .font(.system(size: 48, weight: .medium, design: .default))
                        .foregroundColor(.monoPrimary)
                        .tracking(2)
                    
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isLoading = false
                    
                    if authManager.currentUser != nil {
                        showLogin = true
                    } else {
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

import SwiftUI
import UIKit

struct GetStartedView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var showLogin = false
    @State private var showRegister = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 80)
            
            Image("getstarted")
                .resizable()
                .frame(width: 410, height: 490)
                .padding(.bottom, 50)
            
            VStack(spacing: 4) {
                Text("Spend Smarter")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#438883"))
                    .multilineTextAlignment(.center)
                
                Text("Save More")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#438883"))
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 8)
            
            VStack(spacing: 20) {
                Button(action: {
                    showRegister = true
                }) {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#438883"))
                        .cornerRadius(25)
                }
                .padding(.horizontal, 40)
                
                HStack(spacing: 4) {
                    Text("Already Have Account?")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        showLogin = true
                    }) {
                        Text("Log In")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#438883"))
                    }
                }
            }
            .padding(.bottom, 60)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGray6))
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
}

#Preview {
    GetStartedView()
        .environmentObject(AuthenticationManager())
}

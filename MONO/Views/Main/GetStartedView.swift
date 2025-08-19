//
//  GetStartedView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-15.
//

import SwiftUI

struct GetStartedView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var showLogin = false
    @State private var showRegister = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top spacer for proper positioning
            Spacer()
                .frame(height: 80)
            
            // 3D Character illustration
            Image("getstarted")
                .resizable()
                .frame(width: 410, height: 490)
                .padding(.bottom, 50)
            
            // Main heading text - two lines
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
            
            // Bottom section with button and login text
            VStack(spacing: 20) {
                // Get Started button
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
                
                // Already have account text with login link
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
        .background(Color(UIColor.systemGray6)) // Light gray background
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

//
//  GetStartedView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-15.
//

import SwiftUI

struct GetStartedView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Light background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.97, blue: 0.98),
                        Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top spacing
                    Spacer()
                        .frame(height: 60)
                    
                    // 3D Character Illustration
                    VStack {
                        // 3D Character Image from Assets
                        Image("getstarted")
                            .resizable()
                            .scaledToFit()
                            .frame(width: min(geometry.size.width * 0.8, 320), height: min(geometry.size.width * 0.8, 320))
                            .clipped()
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Main Content
                    VStack(spacing: 32) {
                        // Title Section
                        VStack(spacing: 8) {
                            Text("Spend Smarter")
                                .font(.system(size: 32, weight: .bold, design: .default))
                                .foregroundColor(.monoPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("Save More")
                                .font(.system(size: 32, weight: .bold, design: .default))
                                .foregroundColor(.monoPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)
                        
                        // Buttons Section
                        VStack(spacing: 16) {
                            // Get Started Button
                            Button(action: {
                                // Handle get started action
                                print("Get Started tapped")
                            }) {
                                Text("Get Started")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.monoPrimary)
                                    .cornerRadius(28)
                                    .shadow(color: Color.monoPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding(.horizontal, 32)
                            
                            // Login Link
                            Button(action: {
                                // Handle login action
                                print("Log In tapped")
                            }) {
                                HStack(spacing: 4) {
                                    Text("Already Have Account?")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.monoTextLight)
                                    
                                    Text("Log In")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.monoPrimary)
                                }
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .padding(.top, 8)
                        }
                    }
                    
                    // Bottom spacing
                    Spacer()
                        .frame(height: 50)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    GetStartedView()
}

//
//  MainView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-15.
//

import SwiftUI

struct MainView: View {
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
                        // Placeholder for the 3D character - you'll need to add the actual image to Assets.xcassets
                        ZStack {
                            // Background circle for the character
                            Circle()
                                .fill(Color.monoPrimary.opacity(0.1))
                                .frame(width: min(geometry.size.width * 0.7, 280), height: min(geometry.size.width * 0.7, 280))
                            
                            VStack(spacing: 12) {
                                // Temporary character representation
                                Circle()
                                    .fill(Color.monoPrimary.opacity(0.8))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text("💰")
                                            .font(.system(size: 35))
                                    )
                                
                                VStack(spacing: 4) {
                                    Text("3D Character Placeholder")
                                        .font(.caption)
                                        .foregroundColor(.monoTextLight)
                                    
                                    Text("Replace with actual image")
                                        .font(.caption2)
                                        .foregroundColor(.monoTextLight)
                                }
                            }
                        }
                        
                        // When you add the actual image, replace the above ZStack with:
                        // Image("character_3d")
                        //     .resizable()
                        //     .scaledToFit()
                        //     .frame(width: min(geometry.size.width * 0.8, 320), height: min(geometry.size.width * 0.8, 320))
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
                            .padding(.horizontal, 32)
                            
                            // Login Link
                            Button(action: {
                                // Handle login action
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
    MainView()
}

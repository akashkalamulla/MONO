//
//  GetStartedView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-15.
//

import SwiftUI

struct GetStartedView: View {
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
                    print("Get Started tapped")
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
                        print("Log In tapped")
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
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    GetStartedView()
}

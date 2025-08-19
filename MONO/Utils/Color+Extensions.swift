//
//  Color+Extensions.swift
//  MONO
//
//  Created by Akash01 on 2025-08-15.
//

import SwiftUI

extension Color {
    // Brand Colors
    static let monoPrimary = Color(red: 0.2, green: 0.6, blue: 0.6) // Teal
    static let monoSecondary = Color(red: 0.15, green: 0.45, blue: 0.45) // Darker teal
    static let monoBackground = Color(red: 0.98, green: 0.98, blue: 0.98) // Light gray
    static let monoText = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    static let monoTextLight = Color(red: 0.6, green: 0.6, blue: 0.6) // Light gray
    
    // Hex color initializer
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

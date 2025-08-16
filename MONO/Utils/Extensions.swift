//
//  Extensions.swift
//  MONO
//
//  Created by Akash01 on 2025-08-16.
//

import SwiftUI

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

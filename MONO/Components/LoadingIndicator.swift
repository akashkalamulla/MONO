//
//  LoadingIndicator.swift
//  MONO
//
//  Created by Akash01 on 2025-08-15.
//

import SwiftUI

struct LoadingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.monoPrimary.opacity(0.7))
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LoadingIndicator()
        .frame(width: 50, height: 50)
        .background(Color.gray.opacity(0.1))
}

//
//  VideoTutorialsView.swift
//  MONO
//
//  Created by Akash01 on 2025-09-03.
//

import SwiftUI
import AVKit

struct VideoTutorialsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    private let tutorials = [
        VideoTutorial(
            title: "Getting Started with MONO",
            description: "Learn the basics of setting up your MONO account and navigating the app.",
            thumbnailName: "play.circle.fill",
            duration: "5:22",
            youtubeID: "dQw4w9WgXcQ"
        ),
        VideoTutorial(
            title: "Managing Your Income Sources",
            description: "How to add, edit, and categorize different income streams in MONO.",
            thumbnailName: "dollarsign.circle.fill",
            duration: "4:15",
            youtubeID: "9bZkp7q19f0"
        ),
        VideoTutorial(
            title: "Tracking Expenses Effectively",
            description: "Learn how to use MONO's expense tracking features, including receipt scanning.",
            thumbnailName: "minus.circle.fill",
            duration: "6:48",
            youtubeID: "JGwWNGJdvx8"
        ),
        VideoTutorial(
            title: "Setting Up Family Members as Dependents",
            description: "How to add family members to your MONO account and track expenses for each person.",
            thumbnailName: "person.2.circle.fill",
            duration: "3:37",
            youtubeID: "kJQP7kiw5Fk"
        ),
        VideoTutorial(
            title: "Using Security Features in MONO",
            description: "Protect your financial data with MONO's security features including biometric authentication.",
            thumbnailName: "shield.fill",
            duration: "4:53",
            youtubeID: "hT_nvWreIhg"
        ),
        VideoTutorial(
            title: "Understanding Financial Reports",
            description: "How to generate and analyze financial reports in MONO to make better decisions.",
            thumbnailName: "chart.bar.fill",
            duration: "7:12",
            youtubeID: "fJ9rUzIMcZQ" 
        )
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tutorials) { tutorial in
                    VideoTutorialRow(tutorial: tutorial) {
                        openYouTubeVideo(id: tutorial.youtubeID)
                    }
                }
            }
            .navigationTitle("Video Tutorials")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func openYouTubeVideo(id: String) {
        if let youtubeURL = URL(string: "https://www.youtube.com/watch?v=\(id)") {
            openURL(youtubeURL)
        }
    }
}

struct VideoTutorial: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let thumbnailName: String
    let duration: String
    let youtubeID: String
}

struct VideoTutorialRow: View {
    let tutorial: VideoTutorial
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: tutorial.thumbnailName)
                        .font(.system(size: 28))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tutorial.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(tutorial.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(tutorial.duration)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
                
                Image(systemName: "play.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                    .padding(8)
                    .background(Circle().fill(Color.orange.opacity(0.1)))
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VideoTutorialsView()
}

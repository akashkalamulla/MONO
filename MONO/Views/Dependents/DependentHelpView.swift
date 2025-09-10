//
//  DependentHelpView.swift
//  MONO
//
//  Created by Akash01 on 2025-09-10.
//

import SwiftUI

struct DependentHelpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title and description
                VStack(alignment: .leading, spacing: 12) {
                    Text("Adding a Dependent")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)) // monoText
                    
                    Text("Learn how to add and manage your dependents in MONO.")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6)) // monoTextLight
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Instructions
                instructionCard(
                    number: "1",
                    title: "Personal Information",
                    description: "Enter your dependent's first and last name. These fields are required to create a new dependent profile."
                )
                
                instructionCard(
                    number: "2",
                    title: "Relationship",
                    description: "Select the relationship between you and your dependent. This helps categorize your expenses appropriately."
                )
                
                instructionCard(
                    number: "3",
                    title: "Date of Birth",
                    description: "Add your dependent's birth date. This is used for age calculation and can help with expense planning based on life stages."
                )
                
                instructionCard(
                    number: "4",
                    title: "Contact Information",
                    description: "Optionally add phone number and email address for your dependent. This information can be useful for sending receipts or expense notifications."
                )
                
                // Tips section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tips")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)) // monoText
                    
                    tipItem(
                        icon: "person.badge.plus",
                        text: "Adding multiple dependents helps you track expenses separately for each family member."
                    )
                    
                    tipItem(
                        icon: "chart.pie",
                        text: "Dependents appear in your expense reports with their own category, making financial planning easier."
                    )
                    
                    tipItem(
                        icon: "person.crop.circle.badge.xmark",
                        text: "You can deactivate a dependent rather than deleting them to keep your expense history intact."
                    )
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Help")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .background(Color(red: 0.98, green: 0.98, blue: 0.98)) // monoBackground
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // Helper view for instruction cards
    private func instructionCard(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Number circle
            Text(number)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color(red: 0.2, green: 0.6, blue: 0.6)) // monoPrimary
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)) // monoText
                
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // Helper view for tips
    private func tipItem(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6)) // monoPrimary
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        DependentHelpView()
    }
}

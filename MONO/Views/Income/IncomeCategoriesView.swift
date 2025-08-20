//
//  IncomeCategoriesView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import SwiftUI

struct IncomeCategoriesView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let incomeStreams = [
        IncomeStream(id: "salary", name: "Salary", icon: "dollarsign.circle.fill", color: .green, description: "Regular monthly salary"),
        IncomeStream(id: "freelance", name: "Freelance", icon: "laptopcomputer", color: .blue, description: "Project-based work"),
        IncomeStream(id: "business", name: "Business", icon: "building.2.fill", color: .purple, description: "Business revenue"),
        IncomeStream(id: "investment", name: "Investment", icon: "chart.line.up", color: .orange, description: "Stock & crypto gains"),
        IncomeStream(id: "rental", name: "Rental", icon: "house.fill", color: .teal, description: "Property rental income"),
        IncomeStream(id: "bonus", name: "Bonus", icon: "gift.fill", color: .pink, description: "Performance bonuses"),
        IncomeStream(id: "dividend", name: "Dividend", icon: "chart.pie.fill", color: .red, description: "Stock dividends"),
        IncomeStream(id: "interest", name: "Interest", icon: "percent", color: .indigo, description: "Savings interest"),
        IncomeStream(id: "commission", name: "Commission", icon: "person.badge.plus", color: .mint, description: "Sales commissions"),
        IncomeStream(id: "other", name: "Other", icon: "ellipsis.circle.fill", color: .gray, description: "Other income sources")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("Add Income")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6))
                    
                    Text("Choose your income stream to get started")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Income Categories Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 20) {
                        ForEach(incomeStreams) { stream in
                            IncomeStreamCard(stream: stream) {
                                // For now, just print and dismiss
                                print("Selected: \(stream.name)")
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .overlay(
                // Custom close button
                VStack {
                    HStack {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6))
                        .padding(.leading, 20)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    Spacer()
                },
                alignment: .topLeading
            )
        }
    }
}

// MARK: - Income Stream Card
struct IncomeStreamCard: View {
    let stream: IncomeStream
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon Container
                ZStack {
                    Circle()
                        .fill(stream.color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: stream.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(stream.color)
                }
                
                // Content
                VStack(spacing: 8) {
                    Text(stream.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6))
                        .multilineTextAlignment(.center)
                    
                    Text(stream.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                action()
            }
        }
    }
}

// MARK: - Income Stream Model
struct IncomeStream: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let description: String
}

#Preview {
    IncomeCategoriesView()
}

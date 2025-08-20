//
//  AddIncomeView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-20.
//

import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: IncomeCategory?
    @State private var showingIncomeDetail = false
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HeaderView()
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Title
                        VStack(spacing: 8) {
                            Text("Add Income")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Select the category that best describes your income source")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Categories Grid
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(IncomeCategory.allCategories, id: \.id) { category in
                                IncomeCategoryCard(category: category) {
                                    selectedCategory = category
                                    showingIncomeDetail = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
                .background(Color(UIColor.systemGray6))
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingIncomeDetail) {
            if let category = selectedCategory {
                AddIncomeDetailView(category: category)
            }
        }
    }
    
    @ViewBuilder
    private func HeaderView() -> some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Income")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Invisible button for balance
            Button(action: {}) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.clear)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color.white)
    }
}

// MARK: - Income Category Card
struct IncomeCategoryCard: View {
    let category: IncomeCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon Background
                Circle()
                    .fill(category.color.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: category.icon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(category.color)
                    )
                
                // Category Info
                VStack(spacing: 4) {
                    Text(category.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(category.description)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddIncomeView()
}

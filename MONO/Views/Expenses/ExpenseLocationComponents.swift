//
//  ExpenseLocationComponents.swift
//  MONO
//
//  Created by Akash01 on 2025-08-25.
//

import SwiftUI
import CoreData
import CoreLocation
import UIKit

// MARK: - Shared Data Models

struct ExpenseLocationData: Identifiable {
    let id: UUID
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    let amount: Double
    let category: String
    let date: Date
}

// MARK: - Shared Components

struct LocationSectionHeader: View {
    let locationName: String
    let expenses: [ExpenseLocationData]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(locationName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(expenses.count) expense\(expenses.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Rs. \(String(format: "%.2f", totalAmount))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
}

// MARK: - Expense Location Row

struct ExpenseLocationRow: View {
    let expense: ExpenseLocationData
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(categoryColor(for: expense.category).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: categoryIcon(for: expense.category))
                    .font(.system(size: 16))
                    .foregroundColor(categoryColor(for: expense.category))
            }
            
            // Expense details
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(formatDate(expense.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Coordinates (small text)
                Text("(\(String(format: "%.4f", expense.coordinate.latitude)), \(String(format: "%.4f", expense.coordinate.longitude)))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text("Rs. \(String(format: "%.2f", expense.amount))")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Button(action: {
                    openInMaps()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "map")
                        Text("View")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func categoryColor(for category: String) -> Color {
        let categories = ExpenseCategory.defaultCategories
        if let categoryObj = categories.first(where: { $0.name == category }) {
            return Color(hex: categoryObj.color)
        }
        return .blue
    }
    
    private func categoryIcon(for category: String) -> String {
        let categories = ExpenseCategory.defaultCategories
        if let categoryObj = categories.first(where: { $0.name == category }) {
            return categoryObj.icon
        }
        return "dollarsign.circle"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func openInMaps() {
        let latitude = expense.coordinate.latitude
        let longitude = expense.coordinate.longitude
        let url = URL(string: "maps://?q=\(latitude),\(longitude)")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Shared Extensions

extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2)
    }
}

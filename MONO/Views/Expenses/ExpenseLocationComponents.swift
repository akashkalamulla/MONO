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



struct ExpenseLocationData: Identifiable {
    let id: UUID
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    let amount: Double
    let category: String
    let date: Date
}


struct LocationSectionHeader: View {
    let locationName: String
    let expenses: [ExpenseLocationData]
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                
                ZStack {
                    Circle()
                        .fill(Color.monoPrimary.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "location.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.monoPrimary)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(locationName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.monoPrimary)
                    
                    Text("\(expenses.count) expense\(expenses.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text("Rs. \(String(format: "%.0f", totalAmount))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.monoPrimary)
                
                Text("Total")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
    
    private var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
}


struct ExpenseLocationRow: View {
    let expense: ExpenseLocationData
    
    var body: some View {
        HStack(spacing: 16) {
           
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                categoryColor(for: expense.category).opacity(0.2),
                                categoryColor(for: expense.category).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: categoryIcon(for: expense.category))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(categoryColor(for: expense.category))
            }
            
           
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(expense.category)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.monoPrimary)
                    
                    Spacer()
                    
                    Text("Rs. \(String(format: "%.0f", expense.amount))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.monoPrimary)
                }
                
                HStack {
                    Label(formatDate(expense.date), systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: openInMaps) {
                        HStack(spacing: 4) {
                            Image(systemName: "map.fill")
                            Text("Open")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.monoPrimary)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
               
                Text("Coordinates: \(String(format: "%.4f", expense.coordinate.latitude)), \(String(format: "%.4f", expense.coordinate.longitude))")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.7))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.monoShadow, radius: 2, x: 0, y: 1)
        )
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


extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2)
    }
}

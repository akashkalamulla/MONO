# MONO Expense Tracker - Complete Setup Guide
## Database Relations, MapKit Integration & Expense Management

---

## 📋 **Table of Contents**
1. [Core Data Setup & Relationships](#core-data-setup--relationships)
2. [Expense Adding System](#expense-adding-system)
3. [MapKit Integration](#mapkit-integration)
4. [Database Relationship Management](#database-relationship-management)
5. [Testing & Validation](#testing--validation)

---

## 🗄️ **1. Core Data Setup & Relationships**

### **Step 1: Create Core Data Entities** ⚠️ **CRITICAL**

#### **A. User Entity (Already Exists - Update)**
In Xcode > `MONO.xcdatamodeld`:

1. **Select User Entity**
2. **Verify/Add Attributes:**
   ```
   id: UUID (required)
   name: String (required)
   email: String (required)
   createdAt: Date (required)
   ```

3. **Add New Relationships:**
   ```
   expenses → Expense (To Many, Delete Rule: Cascade)
   categories → ExpenseCategory (To Many, Delete Rule: Cascade)
   budgets → Budget (To Many, Delete Rule: Cascade)
   ```

#### **B. Expense Entity (NEW - Create)**
1. **Click "+" → Add Entity**
2. **Name:** `Expense`
3. **Add Attributes:**
   ```
   id: UUID (required)
   name: String (required)
   amount: Double (required)
   type: String (required) // "Expenses", "Income", "Transfer"
   category: String (required)
   categoryIcon: String (required)
   categoryColor: String (required)
   date: Date (required)
   location: String (optional)
   latitude: Double (default: 0.0)
   longitude: Double (default: 0.0)
   notes: String (optional)
   reminderDate: Date (optional)
   createdAt: Date (required)
   updatedAt: Date (optional)
   ```

4. **Add Relationships:**
   ```
   user → User (To One, Delete Rule: Nullify, required)
   category → ExpenseCategory (To One, Delete Rule: Nullify, optional)
   ```

#### **C. ExpenseCategory Entity (NEW - Create)**
1. **Click "+" → Add Entity**
2. **Name:** `ExpenseCategory`
3. **Add Attributes:**
   ```
   id: UUID (required)
   name: String (required)
   icon: String (required)
   color: String (required)
   type: String (required) // "Expenses", "Income", "Transfer"
   isDefault: Boolean (default: false)
   isActive: Boolean (default: true)
   createdAt: Date (required)
   ```

4. **Add Relationships:**
   ```
   user → User (To One, Delete Rule: Nullify, required)
   expenses → Expense (To Many, Delete Rule: Cascade)
   ```

#### **D. Budget Entity (NEW - Create)**
1. **Click "+" → Add Entity**
2. **Name:** `Budget`
3. **Add Attributes:**
   ```
   id: UUID (required)
   name: String (required)
   amount: Double (required)
   period: String (required) // "monthly", "weekly", "yearly"
   category: String (optional)
   startDate: Date (required)
   endDate: Date (required)
   isActive: Boolean (default: true)
   createdAt: Date (required)
   ```

4. **Add Relationships:**
   ```
   user → User (To One, Delete Rule: Nullify, required)
   ```

### **Step 2: Set Inverse Relationships** ⚠️ **CRITICAL**

#### **Configure All Relationships:**

1. **User ↔ Expense**
   - User.expenses ↔ Expense.user
   - User: To Many, Delete Rule: Cascade
   - Expense: To One, Delete Rule: Nullify

2. **User ↔ ExpenseCategory**
   - User.categories ↔ ExpenseCategory.user
   - User: To Many, Delete Rule: Cascade
   - ExpenseCategory: To One, Delete Rule: Nullify

3. **User ↔ Budget**
   - User.budgets ↔ Budget.user
   - User: To Many, Delete Rule: Cascade
   - Budget: To One, Delete Rule: Nullify

4. **ExpenseCategory ↔ Expense**
   - ExpenseCategory.expenses ↔ Expense.category
   - ExpenseCategory: To Many, Delete Rule: Cascade
   - Expense: To One, Delete Rule: Nullify

---

## 💰 **2. Expense Adding System**

### **Step 1: Update ExpenseManager.swift**

Replace your current ExpenseManager with this enhanced version:

```swift
import Foundation
import CoreData
import UserNotifications
import CoreLocation

class ExpenseManager: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var categories: [ExpenseCategory] = []
    @Published var isLoading = false
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchExpenses()
        fetchCategories()
        setupDefaultCategories()
    }
    
    // MARK: - Expense CRUD Operations
    func addExpense(
        name: String,
        amount: Double,
        type: String,
        category: String,
        categoryIcon: String,
        categoryColor: String,
        date: Date,
        location: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        notes: String? = nil,
        reminderDate: Date? = nil,
        user: User
    ) -> Bool {
        
        let expense = Expense(context: viewContext)
        expense.id = UUID()
        expense.name = name
        expense.amount = amount
        expense.type = type
        expense.category = category
        expense.categoryIcon = categoryIcon
        expense.categoryColor = categoryColor
        expense.date = date
        expense.location = location
        expense.latitude = latitude ?? 0.0
        expense.longitude = longitude ?? 0.0
        expense.notes = notes
        expense.reminderDate = reminderDate
        expense.createdAt = Date()
        expense.user = user
        
        // Find and link category entity
        if let categoryEntity = findCategory(name: category, type: type, user: user) {
            expense.categoryEntity = categoryEntity
        }
        
        do {
            try viewContext.save()
            
            // Schedule reminder if set
            if let reminderDate = reminderDate {
                scheduleReminder(for: expense, at: reminderDate)
            }
            
            fetchExpenses()
            return true
        } catch {
            print("Error saving expense: \(error)")
            return false
        }
    }
    
    func fetchExpenses() {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]
        
        do {
            expenses = try viewContext.fetch(request)
        } catch {
            print("Error fetching expenses: \(error)")
        }
    }
    
    func fetchExpenses(for user: User) -> [Expense] {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching user expenses: \(error)")
            return []
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        // Cancel reminder if exists
        if let reminderId = expense.id {
            cancelReminder(for: reminderId)
        }
        
        viewContext.delete(expense)
        
        do {
            try viewContext.save()
            fetchExpenses()
        } catch {
            print("Error deleting expense: \(error)")
        }
    }
    
    // MARK: - Category Management
    func fetchCategories() {
        let request: NSFetchRequest<ExpenseCategory> = ExpenseCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseCategory.name, ascending: true)]
        
        do {
            categories = try viewContext.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    func createCategory(
        name: String,
        icon: String,
        color: String,
        type: String,
        user: User,
        isDefault: Bool = false
    ) -> ExpenseCategory? {
        
        let category = ExpenseCategory(context: viewContext)
        category.id = UUID()
        category.name = name
        category.icon = icon
        category.color = color
        category.type = type
        category.isDefault = isDefault
        category.isActive = true
        category.createdAt = Date()
        category.user = user
        
        do {
            try viewContext.save()
            fetchCategories()
            return category
        } catch {
            print("Error creating category: \(error)")
            return nil
        }
    }
    
    func findCategory(name: String, type: String, user: User) -> ExpenseCategory? {
        let request: NSFetchRequest<ExpenseCategory> = ExpenseCategory.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ AND type == %@ AND user == %@", name, type, user)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error finding category: \(error)")
            return nil
        }
    }
    
    // MARK: - Default Categories Setup
    private func setupDefaultCategories() {
        // This will be called once per user to create default categories
        // Implementation depends on your category structure
    }
    
    func setupDefaultCategories(for user: User) {
        // Check if user already has default categories
        let request: NSFetchRequest<ExpenseCategory> = ExpenseCategory.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@ AND isDefault == true", user)
        
        do {
            let existingDefaults = try viewContext.fetch(request)
            if !existingDefaults.isEmpty { return } // Already setup
            
            // Create default expense categories
            let expenseCategories = [
                ("Food", "fork.knife", "orange"),
                ("Transport", "car.fill", "blue"),
                ("Shopping", "bag.fill", "purple"),
                ("Bills", "doc.text.fill", "red"),
                ("Entertainment", "gamecontroller.fill", "green"),
                ("Health", "cross.fill", "cyan"),
                ("Education", "graduationcap.fill", "blue"),
                ("Others", "ellipsis.circle.fill", "gray")
            ]
            
            for (name, icon, color) in expenseCategories {
                _ = createCategory(name: name, icon: icon, color: color, type: "Expenses", user: user, isDefault: true)
            }
            
            // Create default income categories
            let incomeCategories = [
                ("Salary", "banknote.fill", "green"),
                ("Freelance", "laptopcomputer", "blue"),
                ("Investment", "chart.line.uptrend.xyaxis", "green"),
                ("Business", "briefcase.fill", "purple"),
                ("Others", "plus.circle.fill", "gray")
            ]
            
            for (name, icon, color) in incomeCategories {
                _ = createCategory(name: name, icon: icon, color: color, type: "Income", user: user, isDefault: true)
            }
            
        } catch {
            print("Error checking default categories: \(error)")
        }
    }
    
    // MARK: - Location-Based Features
    func getExpensesNearLocation(_ coordinate: CLLocationCoordinate2D, radius: Double = 1000) -> [Expense] {
        return expenses.filter { expense in
            guard expense.latitude != 0, expense.longitude != 0 else { return false }
            
            let expenseLocation = CLLocation(latitude: expense.latitude, longitude: expense.longitude)
            let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            return expenseLocation.distance(from: targetLocation) <= radius
        }
    }
    
    func getLocationInsights() -> [LocationInsight] {
        let groupedExpenses = Dictionary(grouping: expenses) { expense in
            expense.location ?? "Unknown Location"
        }
        
        return groupedExpenses.compactMap { location, expenses in
            guard !expenses.isEmpty else { return nil }
            
            let totalAmount = expenses.reduce(0) { $0 + $1.amount }
            let averageAmount = totalAmount / Double(expenses.count)
            
            return LocationInsight(
                locationName: location,
                totalSpent: totalAmount,
                averageSpent: averageAmount,
                expenseCount: expenses.count,
                lastVisit: expenses.max(by: { ($0.date ?? Date()) < ($1.date ?? Date()) })?.date ?? Date()
            )
        }.sorted { $0.totalSpent > $1.totalSpent }
    }
    
    // MARK: - Analytics
    func getMonthlySummary(for user: User, month: Int, year: Int) -> (income: Double, expenses: Double, balance: Double) {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@ AND date >= %@ AND date <= %@", user, startOfMonth as NSDate, endOfMonth as NSDate)
        
        do {
            let monthExpenses = try viewContext.fetch(request)
            
            let income = monthExpenses.filter { $0.type == "Income" }.reduce(0) { $0 + $1.amount }
            let expenses = monthExpenses.filter { $0.type == "Expenses" }.reduce(0) { $0 + $1.amount }
            
            return (income: income, expenses: expenses, balance: income - expenses)
        } catch {
            print("Error calculating monthly summary: \(error)")
            return (income: 0, expenses: 0, balance: 0)
        }
    }
    
    // MARK: - Reminder Management
    private func scheduleReminder(for expense: Expense, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "💰 Expense Reminder"
        content.body = "Don't forget: \(expense.name ?? "Expense")"
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "expense_reminder_\(expense.id?.uuidString ?? UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error)")
            }
        }
    }
    
    func cancelReminder(for expenseId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["expense_reminder_\(expenseId.uuidString)"]
        )
    }
}

// MARK: - Supporting Models
struct LocationInsight {
    let locationName: String
    let totalSpent: Double
    let averageSpent: Double
    let expenseCount: Int
    let lastVisit: Date
}
```

### **Step 2: Update User Creation to Setup Categories**

In your `AuthManager.swift`, when creating a new user:

```swift
func createUser(name: String, email: String) -> Bool {
    let user = User(context: viewContext)
    user.id = UUID()
    user.name = name
    user.email = email
    user.createdAt = Date()
    
    do {
        try viewContext.save()
        
        // Setup default categories for new user
        let expenseManager = ExpenseManager(context: viewContext)
        expenseManager.setupDefaultCategories(for: user)
        
        self.currentUser = user
        return true
    } catch {
        print("Error creating user: \(error)")
        return false
    }
}
```

---

## 🗺️ **3. MapKit Integration**

### **Step 1: Create ExpenseMapView.swift**

Create new file: `/Views/Map/ExpenseMapView.swift`

```swift
import SwiftUI
import MapKit
import CoreData

struct ExpenseMapView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var expenseManager: ExpenseManager
    @StateObject private var locationHelper = LocationHelper.shared
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedExpense: Expense?
    @State private var showingExpenseDetail = false
    @State private var mapType: MKMapType = .standard
    
    init() {
        self._expenseManager = StateObject(wrappedValue: ExpenseManager(context: PersistenceController.shared.container.viewContext))
    }
    
    var userExpenses: [Expense] {
        guard let user = authManager.currentUser else { return [] }
        return expenseManager.fetchExpenses(for: user).filter { 
            $0.latitude != 0 && $0.longitude != 0 
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map View
                Map(coordinateRegion: $region, annotationItems: userExpenses) { expense in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: expense.latitude, longitude: expense.longitude)) {
                        ExpenseMapPin(expense: expense) {
                            selectedExpense = expense
                            showingExpenseDetail = true
                        }
                    }
                }
                .mapStyle(MapStyle.standard(elevation: .realistic))
                .onAppear {
                    centerMapOnUserExpenses()
                }
                
                // Map Controls
                VStack {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 8) {
                            // Map Type Toggle
                            Button(action: {
                                mapType = mapType == .standard ? .satellite : .standard
                            }) {
                                Image(systemName: mapType == .standard ? "map" : "globe.americas.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            
                            // Current Location
                            Button(action: {
                                centerMapOnCurrentLocation()
                            }) {
                                Image(systemName: "location.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.trailing, 16)
                    }
                    
                    Spacer()
                }
                .padding(.top, 100)
            }
            .navigationTitle("Expense Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Standard", action: { mapType = .standard })
                        Button("Satellite", action: { mapType = .satellite })
                        Button("Hybrid", action: { mapType = .hybrid })
                    } label: {
                        Image(systemName: "map")
                    }
                }
            }
        }
        .sheet(isPresented: $showingExpenseDetail) {
            if let expense = selectedExpense {
                ExpenseDetailSheet(expense: expense)
            }
        }
    }
    
    private func centerMapOnUserExpenses() {
        guard !userExpenses.isEmpty else {
            centerMapOnCurrentLocation()
            return
        }
        
        let coordinates = userExpenses.map { 
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) 
        }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? 0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 0
        let minLon = coordinates.map { $0.longitude }.min() ?? 0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(maxLat - minLat, 0.01) * 1.2,
            longitudeDelta: max(maxLon - minLon, 0.01) * 1.2
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
    
    private func centerMapOnCurrentLocation() {
        if let location = locationHelper.currentLocation {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}

// MARK: - Expense Map Pin
struct ExpenseMapPin: View {
    let expense: Expense
    let onTap: () -> Void
    
    var pinColor: Color {
        switch expense.type {
        case "Income":
            return .green
        case "Expenses":
            return .red
        default:
            return .blue
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                // Pin Icon
                ZStack {
                    Circle()
                        .fill(pinColor)
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: expense.categoryIcon ?? "dollarsign.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Amount
                Text("$\(expense.amount, specifier: "%.0f")")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(4)
            }
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: expense.amount)
    }
}

// MARK: - Expense Detail Sheet
struct ExpenseDetailSheet: View {
    let expense: Expense
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Expense Icon and Amount
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color(expense.categoryColor ?? "blue").opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: expense.categoryIcon ?? "dollarsign.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(Color(expense.categoryColor ?? "blue"))
                        )
                    
                    Text("$\(expense.amount, specifier: "%.2f")")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(expense.type == "Income" ? .green : .red)
                    
                    Text(expense.name ?? "Unknown")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                // Details
                VStack(spacing: 16) {
                    DetailRow(label: "Category", value: expense.category ?? "Unknown")
                    DetailRow(label: "Type", value: expense.type ?? "Unknown")
                    DetailRow(label: "Date", value: expense.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown")
                    
                    if let location = expense.location, !location.isEmpty {
                        DetailRow(label: "Location", value: location)
                    }
                    
                    if let notes = expense.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            Text(notes)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Expense Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
```

### **Step 2: Update DashboardView to Include Map**

In your `DashboardView.swift`, update the Location tab:

```swift
TabBarItem(
    icon: "location.fill",
    title: "Location",
    isSelected: selectedTab == 3,
    color: .gray
) {
    selectedTab = 3
    showingExpenseMap = true  // Add this state variable
}
```

Add the state variable and sheet:

```swift
@State private var showingExpenseMap = false

// Add to your body:
.sheet(isPresented: $showingExpenseMap) {
    ExpenseMapView()
        .environmentObject(authManager)
}
```

---

## 🔗 **4. Database Relationship Management**

### **Step 1: User Isolation**

**Ensure each user only sees their own data:**

```swift
// In ExpenseManager.swift
func fetchUserExpenses(for user: User) -> [Expense] {
    let request: NSFetchRequest<Expense> = Expense.fetchRequest()
    request.predicate = NSPredicate(format: "user == %@", user)
    request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]
    
    do {
        return try viewContext.fetch(request)
    } catch {
        print("Error fetching user expenses: \(error)")
        return []
    }
}

func fetchUserCategories(for user: User) -> [ExpenseCategory] {
    let request: NSFetchRequest<ExpenseCategory> = ExpenseCategory.fetchRequest()
    request.predicate = NSPredicate(format: "user == %@ AND isActive == true", user)
    request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseCategory.name, ascending: true)]
    
    do {
        return try viewContext.fetch(request)
    } catch {
        print("Error fetching user categories: \(error)")
        return []
    }
}
```

### **Step 2: Cascade Delete Rules**

**When a user is deleted, all related data is automatically deleted:**

1. **User → Expenses**: Delete Rule = **Cascade**
2. **User → Categories**: Delete Rule = **Cascade**  
3. **User → Budgets**: Delete Rule = **Cascade**
4. **Category → Expenses**: Delete Rule = **Nullify** (preserve expense, just remove category link)

### **Step 3: Data Integrity**

**Add validation in your models:**

```swift
// In User+CoreDataClass.swift (create this file)
import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date(), forKey: "createdAt")
        setPrimitiveValue(UUID(), forKey: "id")
    }
    
    // Computed property for expenses
    var sortedExpenses: [Expense] {
        let set = expenses as? Set<Expense> ?? []
        return set.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }
    
    // Computed property for categories
    var activeCategories: [ExpenseCategory] {
        let set = categories as? Set<ExpenseCategory> ?? []
        return set.filter { $0.isActive }.sorted { $0.name ?? "" < $1.name ?? "" }
    }
}

// In Expense+CoreDataClass.swift (create this file)
import Foundation
import CoreData
import CoreLocation

@objc(Expense)
public class Expense: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date(), forKey: "createdAt")
        setPrimitiveValue(UUID(), forKey: "id")
    }
    
    // Computed property for location
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var hasValidLocation: Bool {
        return latitude != 0.0 && longitude != 0.0
    }
    
    // Computed property for formatted amount
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}
```

---

## ✅ **5. Testing & Validation**

### **Step 1: Database Testing**

**Test all relationships:**

```swift
func testDatabaseRelationships() {
    // Create test user
    let user = User(context: viewContext)
    user.name = "Test User"
    user.email = "test@example.com"
    
    // Create test category
    let category = ExpenseCategory(context: viewContext)
    category.name = "Food"
    category.icon = "fork.knife"
    category.color = "orange"
    category.type = "Expenses"
    category.user = user
    
    // Create test expense
    let expense = Expense(context: viewContext)
    expense.name = "Coffee"
    expense.amount = 5.50
    expense.type = "Expenses"
    expense.user = user
    expense.categoryEntity = category
    
    do {
        try viewContext.save()
        
        // Test relationships
        assert(user.expenses?.count == 1, "User should have 1 expense")
        assert(user.categories?.count == 1, "User should have 1 category") 
        assert(category.expenses?.count == 1, "Category should have 1 expense")
        assert(expense.user == user, "Expense should belong to user")
        assert(expense.categoryEntity == category, "Expense should be linked to category")
        
        print("✅ All database relationships working correctly!")
        
    } catch {
        print("❌ Database test failed: \(error)")
    }
}
```

### **Step 2: MapKit Testing**

**Test location features:**

```swift
func testMapKitIntegration() {
    // Test location storage
    let expense = Expense(context: viewContext)
    expense.latitude = 37.7749
    expense.longitude = -122.4194
    expense.location = "San Francisco, CA"
    
    // Test coordinate access
    let coordinate = expense.coordinate
    assert(coordinate.latitude == 37.7749, "Latitude should be stored correctly")
    assert(coordinate.longitude == -122.4194, "Longitude should be stored correctly")
    assert(expense.hasValidLocation == true, "Should have valid location")
    
    print("✅ MapKit integration working correctly!")
}
```

### **Step 3: User Isolation Testing**

**Ensure data isolation:**

```swift
func testUserDataIsolation() {
    // Create two users
    let user1 = User(context: viewContext)
    user1.name = "User 1"
    user1.email = "user1@example.com"
    
    let user2 = User(context: viewContext)
    user2.name = "User 2"
    user2.email = "user2@example.com"
    
    // Create expenses for each user
    let expense1 = Expense(context: viewContext)
    expense1.name = "User 1 Expense"
    expense1.user = user1
    
    let expense2 = Expense(context: viewContext)
    expense2.name = "User 2 Expense"
    expense2.user = user2
    
    try! viewContext.save()
    
    // Test isolation
    let expenseManager = ExpenseManager(context: viewContext)
    let user1Expenses = expenseManager.fetchExpenses(for: user1)
    let user2Expenses = expenseManager.fetchExpenses(for: user2)
    
    assert(user1Expenses.count == 1, "User 1 should have 1 expense")
    assert(user2Expenses.count == 1, "User 2 should have 1 expense")
    assert(user1Expenses.first?.name == "User 1 Expense", "User 1 should see only their expense")
    assert(user2Expenses.first?.name == "User 2 Expense", "User 2 should see only their expense")
    
    print("✅ User data isolation working correctly!")
}
```

---

## 📱 **6. Info.plist Permissions**

**Add these permissions to your Info.plist:**

```xml
<!-- Location Services -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>MONO needs location access to track where you make expenses for your spending heat map and location-based insights.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>MONO needs location access to track where you make expenses for your spending heat map and location-based insights.</string>

<!-- Notifications -->
<key>NSUserNotificationAlertStyle</key>
<string>alert</string>
```

---

## 🎯 **7. Final Integration Checklist**

### **Database Setup** ✅
- [ ] Core Data entities created with correct attributes
- [ ] Relationships properly configured with inverse relationships
- [ ] Delete rules set correctly (Cascade for user data, Nullify for references)
- [ ] Default categories setup for new users

### **Expense System** ✅
- [ ] ExpenseManager handles CRUD operations
- [ ] User isolation implemented
- [ ] Location data stored with each expense
- [ ] Category relationships working

### **MapKit Integration** ✅
- [ ] ExpenseMapView displays user expenses
- [ ] Location permissions added to Info.plist
- [ ] Map pins show expense details
- [ ] User can navigate map and view expense locations

### **Testing** ✅
- [ ] Database relationships tested
- [ ] User data isolation verified
- [ ] MapKit location features working
- [ ] Expense creation with location data successful

---

## 🚀 **What You Get After Setup**

1. **Complete Expense Tracking** with location data
2. **Visual Map** showing where money is spent
3. **User-Specific Data** with proper isolation
4. **Smart Category Management** with defaults
5. **Location-Based Insights** and analytics
6. **Proper Database Relationships** with data integrity

**Your MONO app will be a complete expense tracking solution with powerful location-based features!** 🎉

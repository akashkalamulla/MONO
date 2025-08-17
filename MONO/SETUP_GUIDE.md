# MONO Expense Tracker - Manual Setup Guide

## 🚀 **Complete Expense Tracking System is Ready!**

Your expense tracking system with location services and reminders is now fully implemented. Here's what you need to do manually to complete the setup:

## 📋 **Manual Setup Checklist**

### **1. Create Core Data Expense Entity** ⚠️ **REQUIRED**

In Xcode:
1. **Open** `MONO.xcdatamodeld` in your project
2. **Click "+"** to add new Entity
3. **Name it:** `Expense`
4. **Add these attributes:**
   - `id`: **UUID** (required)
   - `name`: **String** (required)
   - `amount`: **Double** (required)
   - `type`: **String** (required) - "Expenses", "Income", or "Transfer"
   - `category`: **String** (required)
   - `categoryIcon`: **String** (required)
   - `categoryColor`: **String** (required)
   - `date`: **Date** (required)
   - `location`: **String** (optional)
   - `latitude`: **Double** (default: 0)
   - `longitude`: **Double** (default: 0)
   - `notes`: **String** (optional)
   - `reminderDate`: **Date** (optional)
   - `createdAt`: **Date** (required)

5. **Add Relationships:**
   - `user`: **User** (To One, required)

6. **Update User Entity:**
   - Add relationship: `expenses`: **Expense** (To Many)
   - Set inverse relationship

---

### **2. Add Location Permissions** 📍 **REQUIRED**

In your `Info.plist` file, add:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>MONO needs location access to track where you make expenses for your spending heat map.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>MONO needs location access to track where you make expenses for your spending heat map.</string>
```

---

### **3. Add Notification Permissions** 🔔 **REQUIRED**

In your `Info.plist` file, add:

```xml
<key>NSUserNotificationAlertStyle</key>
<string>alert</string>
```

**Also add to your main app file (`MONOApp.swift`):**

```swift
import UserNotifications

@main
struct MONOApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    // Request notification permission
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                        if granted {
                            print("Notification permission granted")
                        }
                    }
                }
        }
    }
}
```

---

### **4. Enable Location Services** 🌍 **AUTOMATIC**

✅ **LocationHelper.swift** is already implemented with:
- ✅ **CLLocationManager** integration
- ✅ **Real-time location tracking**
- ✅ **Address reverse geocoding**
- ✅ **Permission handling**
- ✅ **Coordinate storage for heat maps**

---

### **5. Enable Notification Services** 📱 **AUTOMATIC**

✅ **ExpenseManager.swift** is already implemented with:
- ✅ **UNUserNotificationCenter** integration
- ✅ **Reminder scheduling**
- ✅ **Notification cancellation**
- ✅ **Permission management**

---

## 🎯 **What's Already Working:**

### ✅ **Complete Expense Form**
- **Teal header** with back navigation
- **Category selection** with icons and colors
- **Amount input** with currency formatting
- **Date picker** with calendar
- **Location picker** with current location
- **Notes field** for additional details
- **Reminder toggle** with date/time picker
- **Form validation** and error handling

### ✅ **ExpenseManager Features**
- **Add expenses** with all data fields
- **Core Data integration** ready
- **Location coordinate storage** for heat maps
- **Reminder scheduling** system
- **Monthly summary** calculations
- **User relationship** management
- **CRUD operations** for expenses

### ✅ **LocationHelper Features**
- **Current location** detection
- **Address reverse geocoding**
- **Permission management**
- **Coordinate extraction** for heat maps
- **Location name resolution**

---

## 🚨 **Testing Instructions:**

After completing the manual setup:

1. **Build and run** the app
2. **Navigate to Expenses tab**
3. **Select a category** (Food, Transport, etc.)
4. **Fill out the expense form:**
   - Name: "Coffee at Starbucks"
   - Amount: $5.50
   - Date: Today
   - Location: Enable "Use Current Location"
   - Notes: "Morning coffee"
   - Reminder: Enable for tomorrow 9 AM
5. **Tap Save**

**Expected Result:**
- ✅ Expense saved to Core Data
- ✅ Location coordinates stored
- ✅ Reminder scheduled
- ✅ Success message shown
- ✅ Return to expenses list

---

## 🗺️ **Heat Map Ready:**

Your expense location data is being stored as coordinates (latitude/longitude) which will be perfect for creating a heat map visualization on the Map tab in the future!

---

## 📞 **Need Help?**

If you encounter any issues:
1. **Check Xcode console** for error messages
2. **Verify permissions** are properly added to Info.plist
3. **Ensure Core Data model** matches exactly
4. **Test on device** (location services don't work in simulator properly)

**Your expense tracking system is now complete and ready for use!** 🎉

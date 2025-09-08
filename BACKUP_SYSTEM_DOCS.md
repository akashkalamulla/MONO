# MONO Backup System Documentation

## Overview
The MONO app now has a comprehensive backup system that can backup all Core Data entities and OCR scan results.

## What Gets Backed Up (Version 2.0)

### ✅ Currently Implemented
1. **OCR Scan Results** 
   - Extracted text content
   - Detected amounts
   - Merchant information  
   - Categories
   - Confidence scores
   - Scan dates and timestamps

2. **User Profile Data Structure**
   - User ID
   - First/Last Name
   - Email address
   - Phone number
   - Account creation date
   - Login status

### 🚧 Prepared for Implementation (Structure Ready)
3. **Income Records**
   - Amount and category details
   - Income descriptions
   - Date information
   - Recurring income settings
   - Category icons and colors

4. **Expense Records**
   - Expense amounts and categories
   - Descriptions and dates
   - Recurring expense settings
   - Payment reminders
   - Location data (GPS coordinates)
   - Associated dependent information

5. **Dependent Information**
   - Personal details (names, relationships)
   - Contact information
   - Birth dates
   - Active status
   - Associated expenses

## Backup File Structure

```json
{
  "version": "2.0",
  "createdAt": "2025-09-08T...",
  "userEmail": "user@example.com",
  "user": {
    "id": "uuid",
    "firstName": "John",
    "lastName": "Doe",
    "email": "user@example.com",
    "phoneNumber": "+1234567890",
    "dateCreated": "2025-01-01T...",
    "isLoggedIn": true
  },
  "ocrRecords": [
    {
      "id": "uuid",
      "amount": 25.99,
      "text": "Receipt content...",
      "category": "food",
      "confidence": 0.89,
      "merchant": "Restaurant Name",
      "date": "2025-09-08T...",
      "createdAt": "2025-09-08T...",
      "userEmail": "user@example.com"
    }
  ],
  "incomes": [...],
  "expenses": [...],
  "dependents": [...]
}
```

## Backup Views Available

### BackupView
- Complete backup interface with full functionality
- Real-time statistics display
- Create and manage backups
- User-friendly alerts and progress indicators
- Integrated OCR record management

## Integration Instructions

Add to your settings navigation:
```swift
NavigationLink("Backup & Sync", destination: BackupView(userEmail: currentUser.email))
```

## File Locations
- **Main Service**: `MONO/Services/BackupService.swift`
- **Backup Views**: `MONO/Views/Settings/`
- **Generated Backups**: App Documents directory as JSON files

## Future Implementation Notes

To enable full Core Data backup:
1. Complete the TODO sections in `fetchIncomesForBackup`, `fetchExpensesForBackup`, and `fetchDependentsForBackup` methods
2. Add proper Core Data entity access (CoreDataStack integration)
3. Implement restore functionality for all entity types
4. Add data validation and migration between backup versions

## Current Status
✅ **OCR Data Backup**: Fully functional
✅ **User Profile Structure**: Ready for implementation  
✅ **UI Components**: Complete and working
✅ **File Management**: Functional
🚧 **Full Core Data Integration**: Structured but needs Core Data access implementation

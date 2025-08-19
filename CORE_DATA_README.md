# Core Data Integration for MONO App

## 🗄️ **Overview**
This implementation integrates Core Data with the MONO authentication system, providing persistent user storage and management.

## 📁 **File Structure**
```
MONO/
├── CoreData/
│   ├── CoreDataStack.swift          # Core Data management
│   └── UserEntity+Extensions.swift  # UserEntity helper methods
├── Models/
│   └── User.swift                   # Updated with Core Data integration
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift          # Uses Core Data for authentication
│   │   ├── RegisterView.swift       # Creates users in Core Data
│   │   ├── EditProfileView.swift    # Updates user data
│   │   └── CoreDataDebugView.swift  # Debug tool for development
│   └── Main/
│       └── AuthenticatedView.swift  # Updated with profile editing
└── MONO.xcdatamodeld/              # Core Data model file
    └── MONO.xcdatamodel/
        └── contents                 # Entity definitions
```

## 🔧 **Core Data Components**

### 1. **CoreDataStack.swift**
- Manages Core Data persistent container
- Provides CRUD operations for users
- Handles login/logout state persistence
- Thread-safe context management

### 2. **UserEntity (Core Data Model)**
- **Attributes:**
  - `id: UUID` - Unique identifier
  - `firstName: String` - User's first name
  - `lastName: String` - User's last name
  - `email: String` - User's email (unique)
  - `phoneNumber: String?` - Optional phone number
  - `dateCreated: Date` - Account creation date
  - `isLoggedIn: Bool` - Current login status

### 3. **User (Data Transfer Object)**
- Lightweight struct for UI binding
- Converts to/from UserEntity
- Maintains compatibility with existing views

## 🚀 **Key Features**

### ✅ **Persistent Authentication**
- User login state survives app restarts
- Automatic login restoration on app launch
- Secure logout with state cleanup

### ✅ **User Management**
- Create new user accounts
- Update user profiles
- Delete user accounts
- Check for existing users

### ✅ **Data Validation**
- Email format validation
- Required field checking
- Duplicate email prevention
- Safe data unwrapping

### ✅ **Development Tools**
- Debug view for Core Data inspection
- Test user creation
- Data clearing utilities
- Real-time data monitoring

## 🔄 **Authentication Flow**

### **App Launch:**
1. `AuthenticationManager` initializes
2. Checks for logged-in user in Core Data
3. Restores user session if found
4. Shows appropriate UI (authenticated/unauthenticated)

### **Registration:**
1. Validate user input
2. Check if email already exists
3. Create new `UserEntity` in Core Data
4. Set login state and update UI

### **Login:**
1. Validate credentials
2. Find existing user by email
3. Update login state in Core Data
4. Load user data and update UI

### **Logout:**
1. Set `isLoggedIn = false` for all users
2. Clear current user state
3. Return to unauthenticated UI

## 📱 **Usage Examples**

### **Create New User:**
```swift
let coreDataStack = CoreDataStack.shared
let newUser = coreDataStack.createUser(
    firstName: "John",
    lastName: "Doe", 
    email: "john@example.com",
    phoneNumber: "+1234567890"
)
```

### **Find User by Email:**
```swift
if let user = coreDataStack.fetchUser(by: "john@example.com") {
    // User found
    print("Found user: \(user.fullName)")
}
```

### **Update User Profile:**
```swift
authManager.updateUserProfile(
    firstName: "John",
    lastName: "Smith",
    phoneNumber: "+1987654321"
)
```

## 🛠️ **Integration Steps**

### **1. Add Core Data Framework**
- In Xcode, select your target
- Go to "Frameworks, Libraries, and Embedded Content"
- Add CoreData.framework

### **2. Add Files to Xcode Project**
- Add all Core Data files to your Xcode project
- Ensure they're included in your target
- Add the .xcdatamodeld file properly

### **3. Update Build Settings**
- No additional build settings required
- Core Data is automatically linked

### **4. Test the Integration**
- Run the app in simulator
- Register a new user
- Close and reopen the app
- Verify user session persists

## 🐛 **Debugging**

### **Debug View Access:**
- In debug builds, go to Profile tab
- Tap "Debug Core Data" option
- View all users and their states
- Create test users or clear data

### **Common Issues:**
- **Model not found:** Ensure .xcdatamodeld is added to target
- **Context errors:** Check CoreDataStack initialization
- **Entity errors:** Verify entity name matches model

### **Console Logging:**
- Core Data errors are logged to console
- User operations include error handling
- Check Xcode console for detailed messages

## 🔐 **Security Considerations**

### **Current Implementation:**
- Password validation (length check)
- Email format validation
- No password storage (mock authentication)

### **Production Recommendations:**
- Hash passwords before storage
- Implement proper authentication API
- Add keychain storage for sensitive data
- Enable Core Data encryption
- Implement proper session management

## 📈 **Performance**

### **Optimizations:**
- Fetch requests use predicates and limits
- Background context for heavy operations
- Automatic change merging enabled
- Minimal data fetching

### **Memory Management:**
- UserEntity objects are managed by Core Data
- User DTOs are lightweight structs
- Proper context lifecycle management

## 🧪 **Testing**

### **Manual Testing:**
1. Register new users with different emails
2. Test login with existing users
3. Update profile information
4. Test app restart persistence
5. Test logout functionality

### **Debug Features:**
- View all users in debug panel
- Create test users quickly
- Clear all data for fresh testing
- Monitor login states

## 📋 **Next Steps**

1. **Backend Integration:**
   - Replace mock authentication with real API
   - Implement server-side user management
   - Add password hashing and verification

2. **Enhanced Features:**
   - Password reset functionality
   - Email verification
   - Two-factor authentication
   - Social login options

3. **Data Sync:**
   - CloudKit integration
   - Multi-device synchronization
   - Offline-first architecture

4. **Security:**
   - Keychain integration
   - Biometric authentication
   - Data encryption at rest

The Core Data integration is now complete and ready for production use with proper backend authentication!

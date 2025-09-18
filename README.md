
## MONO — iOS Personal Finance (SwiftUI)

Compatibility
-------------

- Swift version: 5.9
- iOS deployment target: 15.2

MONO is a SwiftUI-based iOS app for personal finance and dependent management. It includes features such as reminders, expense/ income tracking, location-aware reminders (MapKit), and Core Data persistence.

This README covers project layout, how to run locally, Core Data notes (migration), and developer tips.

## Project layout (`MONO/` directory only)

```
MONO/
├── MONOApp.swift                     # App entry point
├── new.swift                         # Additional app configuration
├── Assets.xcassets/                  # App assets and resources
├── Auth/
│   ├── EditProfileView.swift
│   ├── LoginView.swift
│   └── RegisterView.swift
├── Components/
│   ├── ButtonStyles.swift
│   ├── ImagePickerView.swift
│   ├── ImageSelectionSheet.swift
│   ├── LoadingIndicator.swift
│   └── StandardLocationPicker.swift
├── CoreData/
│   ├── CoreDataModels.swift
│   ├── CoreDataStack.swift
│   ├── DependentEntityModel.swift
│   ├── DependentReminderEntityModel.swift
│   ├── IncomeEntityModel.swift
│   └── UserEntityModel.swift
├── Managers/
│   ├── BiometricAuthManager.swift
│   ├── DependentReminderManager.swift
│   └── NotificationManager.swift
├── Models/
│   ├── Dependent.swift
│   ├── DependentReminder.swift
│   ├── Expense.swift
│   ├── Income.swift
│   └── User.swift
├── Services/
│   ├── Colors.swift
│   ├── OCRFileHelper.swift
│   ├── OCRService.swift
│   ├── OCRServiceErrorFixes.swift
│   └── OCRServiceSecond.swift
└── Views/
	├── FinanceView.swift
	├── NotificationView.swift
	├── Dependents/
	│   ├── AddDependentReminderView.swift
	│   ├── AddDependentView.swift
	│   ├── DependentDetailView.swift
	│   ├── DependentExpensesPlaceholderView.swift
	│   ├── DependentExpensesView.swift
	│   ├── DependentHelpView.swift
	│   ├── DependentRemindersView.swift
	│   ├── DependentsView.swift
	│   └── EditDependentView.swift
	├── Expenses/
	│   ├── ExpenseHelpView.swift
	│   ├── ExpenseListView.swift
	│   ├── ExpenseLocationComponents.swift
	│   ├── ExpenseLocationListView.swift
	│   ├── ExpenseLocationMapView.swift
	│   ├── OCRExpenseEntry.swift
	│   └── SharedLocationComponents.swift
	├── Income/
	├── Settings/
	├── Splash/
	└── Statistics/
```

## Features

- Reminders for dependents with date/time, optional location, and notification scheduling
- Location picker with map search and reverse geocoding via `StandardLocationPicker`
- Core Data persistence (entities for dependents, expenses, reminders)
- Map preview for reminders with saved coordinates
- Modular SwiftUI components and manager classes (ObservableObject)

## Quick start — open and run

1. Open the workspace in Xcode:

```bash
open MONO.xcworkspace
```

2. Select a simulator or device, set a development team for signing (see Signing notes), then Build & Run (⌘R).

If you prefer command line build (useful for CI):

```bash
# build for simulator
xcodebuild -workspace MONO.xcworkspace -scheme MONO -sdk iphonesimulator -configuration Debug build
```

## Core Data — important notes and migration

The app uses Core Data. The `DependentReminderEntity` currently stores reminder metadata and location coordinates.

If you change the model you must create a new model version and enable lightweight migration:

1. In Xcode, open `MONO.xcdatamodeld` → Editor → Add Model Version… → name it (e.g. `MONOv2`).
2. Select the `.xcdatamodeld` container and use the File Inspector (right pane) → Model Version to set the new version as Current.
3. Enable lightweight migration in `CoreDataStack.swift` (example):

```swift
let description = persistentContainer.persistentStoreDescriptions.first
description?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
description?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

persistentContainer.loadPersistentStores { _, error in
	if let error = error {
		fatalError("Unresolved Core Data error: \(error)")
	}
}
```

4. Build and run. If migration fails, try uninstalling the app from the simulator before running (this removes the old store).

Recommended `DependentReminderEntity` attributes (if you will restore full reminder features):

- `id: UUID`
- `paymentName: String`
- `amount: Double`
- `date: Date` (scheduled datetime)
- `createdAt: Date`
- `isCompleted: Bool`
- `completedAt: Date?`
- `notificationId: String?`
- `locationName: String?`, `locationLatitude: Double`, `locationLongitude: Double`

Add these exactly (or adapt code accordingly) so the app can reconstruct reminders and show map pins.

Detailed Core Data implementation
--------------------------------

Core Data in MONO is split across two responsibilities:

- Persistent container and context management (`CoreDataStack.swift`)
- Entity <-> Model mapping helpers (in `CoreDataModels.swift` and `*EntityModel.swift` files)

CoreDataStack (location: `CoreData/CoreDataStack.swift`)
- Creates the NSPersistentContainer with the `MONO` model
- Configures lightweight migration options (see example above)
- Exposes a `context` for read/write operations, and helper methods like `save()`, `fetchUser(by:)`, `createUser(...)`, `loginUser(_:)`, `logoutAllUsers()`, etc.
- Ensure `persistentContainer.viewContext.automaticallyMergesChangesFromParent = true` is set when doing background operations.

Entity mapping and helper files
- `CoreDataModels.swift` contains Codable/extension helpers to convert between Core Data entities and in-memory models used in views and managers.
- Specific entity model files (e.g. `DependentEntityModel.swift`, `DependentReminderEntityModel.swift`, `IncomeEntityModel.swift`, `UserEntityModel.swift`) provide typed accessors and initializers for the corresponding entities.

Recommended Core Data entities and attributes
- DependentEntity
	- id: UUID (indexed)
	- firstName: String
	- lastName: String
	- relationship: String
	- dateOfBirth: Date
	- phoneNumber: String?
	- email: String?
	- isActive: Bool
	- dateAdded: Date
	- userId: UUID

- DependentReminderEntity
	- id: UUID (indexed)
	- title: String
	- amount: Double
	- date: Date
	- isCompleted: Bool
	- completedAt: Date?
	- notificationId: String?
	- locationName: String?
	- locationLatitude: Double
	- locationLongitude: Double
	- createdAt: Date

- IncomeEntity
	- id: UUID (indexed)
	- amount: Double
	- categoryId: String
	- categoryName: String
	- descriptionText: String?
	- date: Date
	- isRecurring: Bool
	- recurrenceFrequency: String? (store rawValue)
	- createdAt: Date

- ExpenseEntity
	- id: UUID (indexed)
	- amount: Double
	- categoryId: String
	- descriptionText: String?
	- date: Date
	- isRecurring: Bool
	- reminderDate: Date?
	- isPaymentReminder: Bool
	- reminderFrequency: String?
	- locationName: String?
	- latitude: Double?
	- longitude: Double?
	- userId: UUID
	- dependentId: UUID?
	- createdAt: Date

- UserEntity
	- id: UUID (indexed)
	- firstName: String
	- lastName: String
	- email: String (indexed, unique)
	- phoneNumber: String?
	- password: String? (hashed)
	- dateCreated: Date
	- isLoggedIn: Bool

Mapping recommendations and usage
- Keep attribute names in Core Data consistent with the helpers in `CoreDataModels.swift` to avoid mapping bugs.
- For enums (recurrence frequency, payment reminder frequency), store the `rawValue` as String in the entity and map back to enums in the model initializers.
- Use UUIDs for primary keys and index them where you frequently query by id.
- Store images or large binaries in the file system and reference them via a filename or store small blobs in `Data` attributes only when necessary.

Concurrency and background operations
- For background imports (e.g., importing many expenses), create a new background context via `persistentContainer.newBackgroundContext()` and perform saves on that context. Merge changes to the view context using `NSManagedObjectContext.mergeChanges(fromContextDidSave:)` or by setting `automaticallyMergesChangesFromParent`.

Testing and fixtures
- `MONOTests/data.json` contains sample incomes and categories used by unit tests. You can use `JSONDecoder` to load fixtures and seed an in-memory Core Data store for tests.

Debugging tips
- If migrations fail, check the model version in the `.xcdatamodeld` and confirm you created a new model version before changing attributes.
- Use `po` on managed objects in the debugger to inspect attributes during runtime.

## Where to look for reminder/location code

- `Managers/DependentReminderManager.swift` — CRUD, notification scheduling, and (eventually) Core Data integration for reminders.
- `CoreData/DependentReminderEntity+Extensions.swift` — mapping helpers between Core Data entity and `DependentReminder` model.
- `Components/StandardLocationPicker.swift` — unified location picker used by expense/reminder forms.
- `Views/Dependents/DependentRemindersView.swift` — UI showing reminders and small Map preview annotations.

## Developer workflow / conventions

- Use `ObservableObject` managers to hold app state and pass them into SwiftUI views via `@ObservedObject` / `@EnvironmentObject`.
- Prefer small reusable components in `Components/` and keep views declarative.
- Keep Core Data model keys and your entity extension helper names in sync — mismatches cause compile-time errors.

## Debugging tips

- If maps don’t show pins: verify the `locationLatitude`/`locationLongitude` values are being saved and loaded.
- If reminders disappear after restart: confirm Core Data migration and that the entity contains the required fields.
- If build fails with signing errors: open project in Xcode and select a Team in Signing & Capabilities.

## Testing

- Unit/UITests are located in `MONOTests/` and `MONOUITests/`. Run tests in Xcode via Product → Test or via:

```bash
xcodebuild test -workspace MONO.xcworkspace -scheme MONO -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Contributing

- Follow the repository branch strategy; create feature branches off `newdev-main`.
- Run the app and tests locally before opening a pull request. Keep changes small and focused.

## Useful files

- `CoreData/CoreDataStack.swift` — persistent container config
- `Managers/DependentReminderManager.swift` — reminder business logic
- `Models/DependentReminder.swift` — in-memory reminder model

## Contact / Notes

If you need help with Core Data attributes or migration I can add the Core Data attribute changes programmatically or update the mapping helpers. When modifying the model, create a new model version and enable lightweight migration as shown above.

---

Thanks for working on MONO — this README is a living document; update it as features and architecture evolve.

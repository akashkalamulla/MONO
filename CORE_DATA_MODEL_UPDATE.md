# Core Data Model Update Instructions

## Adding Dependent-Expense Relationship

To implement the relationship between Expenses and Dependents in the Core Data model, follow these steps:

1. Open the MONO.xcdatamodeld file in Xcode

2. Add a new attribute to ExpenseEntity:
   - Name: `dependentID`
   - Type: UUID
   - Optional: Yes
   - Default Value: nil

3. Create a DependentEntity if it doesn't already exist with these attributes:
   - id: UUID (not optional)
   - firstName: String (not optional)
   - lastName: String (not optional)
   - relationship: String (not optional)
   - dateOfBirth: Date (not optional)
   - phoneNumber: String (optional)
   - email: String (optional)
   - isActive: Boolean (not optional)
   - dateAdded: Date (not optional)
   - userId: UUID (not optional)

4. Create relationships:
   - In ExpenseEntity:
     - Add relationship "dependent" to DependentEntity (To-One, optional)
     - Delete Rule: Nullify
   
   - In DependentEntity:
     - Add relationship "expenses" to ExpenseEntity (To-Many, optional)
     - Delete Rule: Nullify

5. Set Inverse Relationships:
   - Set "dependent" in ExpenseEntity to have "expenses" as its inverse
   - Set "expenses" in DependentEntity to have "dependent" as its inverse

6. Generate Core Data model classes if needed
   - Editor > Create NSManagedObject Subclass
   - Select DependentEntity and follow the wizard

7. Update CoreDataStack to support fetching expenses for a dependent

After these changes, the ExpenseEntity will be able to reference an optional Dependent, and the DependentEntity will be able to access all of its associated expenses.

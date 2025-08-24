# Core Data Model Update Guide

## Add Dependent-Expense Relationship

To implement the relationship between Expenses and Dependents, you need to make the following changes to your Core Data model:

### 1. Add a DependentEntity if not already present

Add a `DependentEntity` to your Core Data model with the following attributes:
- id (UUID)
- firstName (String)
- lastName (String)
- relationship (String)
- dateOfBirth (Date)
- phoneNumber (String, optional)
- email (String, optional)
- isActive (Boolean)
- dateAdded (Date)
- userId (UUID)

### 2. Update ExpenseEntity

Add the following to your `ExpenseEntity`:
- Add attribute: `dependentID` (UUID, optional)
- Add relationship: `dependent` (to-one relationship to DependentEntity, optional)

### 3. Update DependentEntity

Add a relationship in `DependentEntity`:
- Add relationship: `expenses` (to-many relationship to ExpenseEntity, optional)

### 4. Configure the relationships

Make sure the relationships are properly configured:
1. `dependent` in ExpenseEntity should have its inverse set to `expenses` in DependentEntity
2. Delete Rule for `dependent` should be "Nullify" (when a dependent is deleted, the expense remains but loses its dependent reference)
3. Delete Rule for `expenses` should be "Cascade" (when a dependent is deleted, associated expenses are deleted)

Note: If you prefer to keep expenses when a dependent is deleted, set the Delete Rule for `expenses` to "Nullify" instead.

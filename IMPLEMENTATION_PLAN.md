# Implementation Plan: Dependent-Related Expenses Feature

## Overview

This feature will allow users to associate expenses with specific dependents. For example, a parent (user) can track expenses related to their child (dependent), such as school fees, and view all expenses associated with each dependent.

## Changes Required

### 1. Core Data Model Updates
- Add `dependentID` attribute to `ExpenseEntity` (UUID, optional)
- Create relationship between `ExpenseEntity` and `DependentEntity`
  - See CORE_DATA_MODEL_UPDATE.md for detailed instructions

### 2. Update Expense Model
- Add `dependentID` field to `ExpenseModel` structure (already completed)

### 3. Update SimpleExpenseEntry View
- Add toggle for "Associate with Dependent" (already implemented)
- Add dropdown to select a dependent (already implemented)
- Update `saveExpense()` method to save the selected dependent ID (already implemented)

### 4. Create DependentExpensesView
- Create a new view to display all expenses for a specific dependent
- Implement filtering to show only expenses associated with that dependent
- Add functionality to add new expenses for that dependent

### 5. Update DependentDetailView
- Add navigation to DependentExpensesView (placeholder implemented)
- Add summary of dependent-related expenses in the Expense Summary card

## Implementation Steps

1. **First, you need to:**
   - Update the Core Data model following the instructions in CORE_DATA_MODEL_UPDATE.md
   - After updating the model, you may need to perform a data migration if you have existing data

2. **Then I will:**
   - Complete the implementation of DependentExpensesView to properly fetch and display expenses
   - Update ExpenseEntity+Extensions.swift to include dependent relationship
   - Update the CoreDataStack to support fetching expenses by dependent
   - Implement actual expense saving with dependent association

3. **Additional Tasks:**
   - Add statistics for dependent expenses on the DependentDetailView
   - Implement sorting and filtering in the expenses list
   - Add direct navigation from SimpleExpenseEntry to select a dependent

## Testing Plan

1. Create a dependent
2. Add an expense associated with that dependent
3. Verify the expense appears in the dependent's expenses list
4. Add an expense not associated with any dependent
5. Verify this expense does not appear in any dependent's expenses list
6. Update an expense to change its associated dependent
7. Verify it appears under the correct dependent

## Notes

- The UI components have been implemented but are currently using placeholder data
- The Core Data model needs to be updated to store the relationship between expenses and dependents
- Full implementation will be complete once Core Data changes are made

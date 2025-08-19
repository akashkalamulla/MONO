//
//  EditDependentView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import SwiftUI

struct EditDependentView: View {
    @Environment(\.presentationMode) var presentationMode
    let dependent: Dependent
    @ObservedObject var dependentManager: DependentManager
    let currentUser: User
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var relationship: String
    @State private var dateOfBirth: Date
    @State private var phoneNumber: String
    @State private var email: String
    @State private var isActive: Bool
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    let relationships = ["Child", "Spouse", "Parent", "Sibling", "Grandparent", "Grandchild", "Other"]
    
    init(dependent: Dependent, dependentManager: DependentManager, currentUser: User) {
        self.dependent = dependent
        self.dependentManager = dependentManager
        self.currentUser = currentUser
        
        _firstName = State(initialValue: dependent.firstName)
        _lastName = State(initialValue: dependent.lastName)
        _relationship = State(initialValue: dependent.relationship)
        _dateOfBirth = State(initialValue: dependent.dateOfBirth)
        _phoneNumber = State(initialValue: dependent.phoneNumber)
        _email = State(initialValue: dependent.email)
        _isActive = State(initialValue: dependent.isActive)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Relationship", selection: $relationship) {
                        ForEach(relationships, id: \.self) { rel in
                            Text(rel).tag(rel)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("Phone Number", text: $phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Status")) {
                    Toggle("Active", isOn: $isActive)
                        .toggleStyle(SwitchToggleStyle(tint: .monoPrimary))
                    
                    if !isActive {
                        Text("Inactive dependents won't appear in expense tracking")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(action: updateDependent) {
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Updating...")
                                    .foregroundColor(.white)
                            }
                        } else {
                            Text("Update Dependent")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isFormValid ? Color.monoPrimary : Color.gray)
                    .cornerRadius(10)
                    .disabled(!isFormValid || isLoading)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle("Edit Dependent")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Update Dependent"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage.contains("successfully") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !relationship.isEmpty
    }
    
    private var hasChanges: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines) != dependent.firstName ||
        lastName.trimmingCharacters(in: .whitespacesAndNewlines) != dependent.lastName ||
        relationship != dependent.relationship ||
        dateOfBirth != dependent.dateOfBirth ||
        phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines) != dependent.phoneNumber ||
        email.trimmingCharacters(in: .whitespacesAndNewlines) != dependent.email ||
        isActive != dependent.isActive
    }
    
    private func updateDependent() {
        guard isFormValid && hasChanges else {
            if !hasChanges {
                alertMessage = "No changes to save"
            } else {
                alertMessage = "Please fill in all required fields"
            }
            showingAlert = true
            return
        }
        
        isLoading = true
        
        var updatedDependent = dependent
        updatedDependent.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedDependent.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedDependent.relationship = relationship
        updatedDependent.dateOfBirth = dateOfBirth
        updatedDependent.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedDependent.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedDependent.isActive = isActive
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dependentManager.updateDependent(updatedDependent, for: currentUser.id)
            alertMessage = "Dependent updated successfully!"
            isLoading = false
            showingAlert = true
        }
    }
}

#Preview {
    let sampleDependent = Dependent(
        firstName: "Emma",
        lastName: "Smith",
        relationship: "Child",
        dateOfBirth: Calendar.current.date(byAdding: .year, value: -8, to: Date()) ?? Date(),
        phoneNumber: "555-0123",
        email: "emma@example.com"
    )
    
    let sampleUser = User(
        firstName: "John",
        lastName: "Doe",
        email: "john@example.com",
        phoneNumber: "555-0123"
    )
    
    EditDependentView(
        dependent: sampleDependent,
        dependentManager: DependentManager(),
        currentUser: sampleUser
    )
}

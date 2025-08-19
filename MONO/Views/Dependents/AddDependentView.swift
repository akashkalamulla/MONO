//
//  AddDependentView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-19.
//

import SwiftUI

struct AddDependentView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var dependentManager: DependentManager
    @ObservedObject var authManager: AuthenticationManager
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var relationship = "Child"
    @State private var dateOfBirth = Date()
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    let relationships = ["Child", "Spouse", "Parent", "Sibling", "Grandparent", "Grandchild", "Other"]
    
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
                
                Section(header: Text("Contact Information (Optional)")) {
                    TextField("Phone Number", text: $phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button(action: addDependent) {
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Adding...")
                                    .foregroundColor(.white)
                            }
                        } else {
                            Text("Add Dependent")
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
            .navigationTitle("Add Dependent")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Add Dependent"),
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
    
    private func addDependent() {
        guard isFormValid,
              let currentUser = authManager.currentUser else {
            alertMessage = "Please fill in all required fields"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        let dependent = Dependent(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            relationship: relationship,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            userId: currentUser.id
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if dependentManager.addDependent(dependent) {
                dependentManager.loadDependents(for: currentUser.id)
                alertMessage = "Dependent added successfully!"
            } else {
                alertMessage = "Failed to add dependent. Please try again."
            }
            isLoading = false
            showingAlert = true
        }
    }
}

#Preview {
    let authManager = AuthenticationManager()
    authManager.currentUser = User(firstName: "John", lastName: "Doe", email: "john@example.com")
    authManager.isAuthenticated = true
    
    return AddDependentView(
        dependentManager: DependentManager(),
        authManager: authManager
    )
}

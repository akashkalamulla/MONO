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
    @State private var showingDatePicker = false
    
    let relationships = ["Child", "Spouse", "Parent", "Sibling", "Grandparent", "Grandchild", "Other"]
    
    init(dependent: Dependent, dependentManager: DependentManager) {
        self.dependent = dependent
        self.dependentManager = dependentManager
        
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
            ZStack {
                Color(red: 0.98, green: 0.98, blue: 0.98)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("PERSONAL INFORMATION")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                .padding(.leading, 4)
                                .padding(.bottom, -4)
                            
                            VStack(spacing: 16) {

                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("First Name")
                                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                            .font(.system(size: 14))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 4)
                                    
                                    TextField("", text: $firstName)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("Last Name")
                                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                            .font(.system(size: 14))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 4)
                                    
                                    TextField("", text: $lastName)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("Relationship")
                                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                            .font(.system(size: 14))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 4)
                                    
                                    Menu {
                                        ForEach(relationships, id: \.self) { rel in
                                            Button(rel) {
                                                relationship = rel
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(relationship)
                                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6))
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Date of Birth")
                                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                            .font(.system(size: 14))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 4)
                                    
                                    Button {
                                        showingDatePicker = true
                                    } label: {
                                        HStack {
                                            Text(formattedDate)
                                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Image(systemName: "calendar")
                                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6))
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
                                    }
                                    .sheet(isPresented: $showingDatePicker) {
                                        VStack {
                                            HStack {
                                                Button("Cancel") {
                                                    showingDatePicker = false
                                                }
                                                .padding()
                                                
                                                Spacer()
                                                
                                                Button("Done") {
                                                    showingDatePicker = false
                                                }
                                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6))
                                                .padding()
                                            }
                                            
                                            DatePicker(
                                                "",
                                                selection: $dateOfBirth,
                                                displayedComponents: [.date]
                                            )
                                            .datePickerStyle(GraphicalDatePickerStyle())
                                            .labelsHidden()
                                            .padding()
                                        }
                                        .presentationDetents([.height(420)])
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 10)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("CONTACT INFORMATION")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                .padding(.leading, 4)
                                .padding(.bottom, -4)
                            
                            VStack(spacing: 16) {
                               
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("Phone Number")
                                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                            .font(.system(size: 14))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 4)
                                    
                                    TextField("", text: $phoneNumber)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
                                        .keyboardType(.phonePad)
                                }
                                
                              
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("Email")
                                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                            .font(.system(size: 14))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 4)
                                    
                                    TextField("", text: $email)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                }
                            }
                        }
                        .padding(.bottom, 10)
                        
            
                        VStack(alignment: .leading, spacing: 20) {
                            Text("STATUS")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                .padding(.leading, 4)
                                .padding(.bottom, -4)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Active")
                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                        .font(.system(size: 16))
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $isActive)
                                        .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.2, green: 0.6, blue: 0.6)))
                                        .labelsHidden()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
                                
                                if !isActive {
                                    HStack {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                            .font(.system(size: 14))
                                        
                                        Text("Inactive dependents won't appear in expense tracking")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                        .padding(.bottom, 30)
                        
                       
                        Button(action: updateDependent) {
                            if isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Updating...")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.leading, 8)
                                }
                            } else {
                                Text("Update Dependent")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            isFormValid && hasChanges ? 
                                Color(red: 0.2, green: 0.6, blue: 0.6) :
                                Color.gray.opacity(0.5)
                        )
                        .cornerRadius(27)
                        .shadow(
                            color: (isFormValid && hasChanges) ? 
                                Color(red: 0.2, green: 0.6, blue: 0.6).opacity(0.3) : Color.clear, 
                            radius: 8, x: 0, y: 4
                        )
                        .disabled(!isFormValid || !hasChanges || isLoading)
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Edit Dependent")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.6)) 
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
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateOfBirth)
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
            if dependentManager.updateDependent(updatedDependent) {
                alertMessage = "Dependent updated successfully!"
            } else {
                alertMessage = "Failed to update dependent. Please try again."
            }
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
        email: "emma@example.com",
        userId: UUID()
    )
    
    EditDependentView(
        dependent: sampleDependent,
        dependentManager: DependentManager()
    )
}

//
//  CustomTextField.swift
//  MONO
//
//  Created by Akash01 on 2025-08-16.
//

import SwiftUI

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    @State private var isSecureVisible = false
    
    init(title: String, text: Binding<String>, isSecure: Bool = false, keyboardType: UIKeyboardType = .default) {
        self.title = title
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            HStack {
                if isSecure && !isSecureVisible {
                    SecureField("Enter \(title.lowercased())", text: $text)
                        .font(.system(size: 16))
                        .textFieldStyle(PlainTextFieldStyle())
                } else {
                    TextField("Enter \(title.lowercased())", text: $text)
                        .font(.system(size: 16))
                        .keyboardType(keyboardType)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                if isSecure {
                    Button(action: {
                        isSecureVisible.toggle()
                    }) {
                        Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomTextField(title: "Email", text: .constant(""), keyboardType: .emailAddress)
        CustomTextField(title: "Password", text: .constant(""), isSecure: true)
    }
    .padding()
}

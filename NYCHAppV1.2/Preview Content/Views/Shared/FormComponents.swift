//
//  FormComponents.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftUI

// Keep existing FormSectionHeader but update its style
struct FormSectionHeader: View {
    let title: String
    
    var body: some View {
        
        
        Text(title)
            .font(AppTheme.headlineFont)
            .foregroundColor(AppTheme.secondaryColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top)
        
        
        
    }
    
    
}

// Update existing FormField with improved styling
struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let isRequired: Bool
    let isValid: Bool
    let keyboardType: UIKeyboardType
    @FocusState private var isFocused: Bool
    
    init(
        title: String,
        text: Binding<String>,
        placeholder: String = "",
        isRequired: Bool = false,
        isValid: Bool = true,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.isRequired = isRequired
        self.isValid = isValid
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(title)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(isFocused ? AppTheme.primaryColor : AppTheme.secondaryColor)
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                        .font(AppTheme.bodyFont)
                }
            }
            
            HStack {
                TextField(placeholder, text: $text)
                    .textFieldStyle(CustomTextFieldStyle(isValid: isValid, isFocused: isFocused))
                    .keyboardType(keyboardType)
                    .font(AppTheme.bodyFont)
                    .focused($isFocused)
                
                if !text.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            text = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding(.trailing, 8)
                }
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    let isValid: Bool
    let isFocused: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(AppTheme.backgroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isFocused ? AppTheme.primaryColor :
                        (isValid ? AppTheme.secondaryColor.opacity(0.3) : Color.red),
                        lineWidth: isFocused ? 1.5 : 1
                    )
            )
            .shadow(
                color: isFocused ? AppTheme.primaryColor.opacity(0.1) : AppTheme.cardShadow,
                radius: 3,
                x: 0,
                y: 2
            )
    }
}



// Update existing Pickers with improved styling
struct Pickers: View {
    let topText: String
    @Binding var pickFrom: [String]
    @Binding var selection: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(topText)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryColor)
            
            Picker("Selection", selection: $selection) {
                ForEach(pickFrom, id: \.self) { pick in
                    Text(pick)
                        .font(AppTheme.bodyFont)
                }
            }
            .pickerStyle(.menu)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.primaryColor.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: AppTheme.cardShadow, radius: 3, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
}

// Add a new reusable button style that can be used across the app
struct CorporateButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(isEnabled ? AppTheme.primaryColor : AppTheme.secondaryColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .shadow(color: AppTheme.cardShadow, radius: 3, x: 0, y: 2)
            .opacity(isEnabled ? 1 : 0.6)
    }
}

// Add a preview for the Picker
#Preview {
    Pickers(
        topText: "State",
        pickFrom: .constant(["NY", "CA", "FL"]),
        selection: .constant("NY")
    )
}

// Preview for FormField
#Preview {
    VStack(spacing: 20) {
        FormField(
            title: "First Name",
            text: .constant(""),
            placeholder: "Enter your first name",
            isRequired: true
        )
        
        FormField(
            title: "Email",
            text: .constant(""),
            placeholder: "Enter your email",
            isRequired: true,
            isValid: false,
            keyboardType: .emailAddress
        )
    }
    .padding()
}


#Preview {
    NavigationStack {
        Form {
            FormSectionHeader(title: "Personal Information")
            FormSectionHeader(title: "Contact Details")
        }
    }
}

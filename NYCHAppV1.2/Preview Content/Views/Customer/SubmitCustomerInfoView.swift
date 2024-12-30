//
//  SubmitTicketView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/22/24.
//
import SwiftUI
import Foundation

struct SubmitCustomerInfoView: View {
    @StateObject private var viewModel = CustomerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Personal Information
                    FormSectionHeader(title: "Personal Information")
                    
                    FormField(
                        title: "First Name",
                        text: $viewModel.firstName,
                        placeholder: "Enter first name",
                        isRequired: true,
                        isValid: !viewModel.firstName.isEmpty || !viewModel.hasAttemptedSubmission
                    )
                    
                    FormField(
                        title: "Last Name",
                        text: $viewModel.lastName,
                        placeholder: "Enter last name",
                        isRequired: true,
                        isValid: !viewModel.lastName.isEmpty || !viewModel.hasAttemptedSubmission
                    )
                    
                    FormField(
                        title: "Business Name",
                        text: $viewModel.businessName,
                        placeholder: "Enter business name (optional)"
                    )
                    
                    // Contact Information
                    FormSectionHeader(title: "Contact Information")
                    
                    FormField(
                        title: "Phone Number",
                        text: $viewModel.phone,
                        placeholder: "Enter phone number",
                        isRequired: true,
                        isValid: viewModel.phone.count >= 10 || !viewModel.hasAttemptedSubmission,
                        keyboardType: .phonePad
                    )
                    .onChange(of: viewModel.phone) { _, newValue in
                        viewModel.phone = newValue.filter { $0.isNumber }
                    }
                    
                    FormField(
                        title: "Email",
                        text: $viewModel.email,
                        placeholder: "Enter email address",
                        isRequired: true,
                        isValid: viewModel.email.contains("@") || !viewModel.hasAttemptedSubmission,
                        keyboardType: .emailAddress
                    )
                    
                    // Address
                    FormSectionHeader(title: "Address")
                    
                    FormField(
                        title: "Street Address",
                        text: $viewModel.address,
                        placeholder: "Enter street address"
                    )
                    
                    HStack {
                        FormField(
                            title: "City",
                            text: $viewModel.city,
                            placeholder: "Enter city"
                        )
                        .frame(minWidth: 190)
                        
                        Pickers(
                            topText: "State",
                            pickFrom: .constant(States().stateAbbreviations),
                            selection: $viewModel.state
                        )
                        .padding(.horizontal, -30)
                        
                        FormField(
                            title: "ZIP Code",
                            text: $viewModel.zipCode,
                            placeholder: "Enter ZIP",
                            keyboardType: .numberPad
                        )
                        .onChange(of: viewModel.zipCode) { _, newValue in
                            viewModel.zipCode = newValue.filter { $0.isNumber }
                        }
                    }
                    
                    // Submit Button
                    Button {
                        Task {
                            await viewModel.createCustomer()
                        }
                    } label: {
                        Text("Create Customer")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                   
                    //.disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .padding()
                }
            }
            .containerRelativeFrame(.horizontal)
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .navigationTitle("Customer Information")
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .navigationDestination(isPresented: .constant(viewModel.createdCustomerId != nil)) {
            if let customerId = viewModel.createdCustomerId {
                SubmitTicketInfoView(
                    viewModel: TicketViewModel(
                        customerID: customerId,
                        customerName: viewModel.firstName
                    )
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        SubmitCustomerInfoView()
    }
}

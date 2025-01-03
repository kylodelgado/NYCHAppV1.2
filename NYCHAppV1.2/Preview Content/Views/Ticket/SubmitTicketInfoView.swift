//
//  SubmitTicketInfoView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/23/24.
//

import SwiftUI

struct SubmitTicketInfoView: View {
    @StateObject var viewModel: TicketViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ZStack {
            ScrollView {
                GradientBackground()
                VStack(spacing: 24) {
                    // Device Information
                    FormSectionHeader(title: "Device Information")
                    
                    FormField(
                        title: "Device Type",
                        text: $viewModel.deviceType,
                        placeholder: "Enter device type (e.g., Laptop, Desktop)",
                        isRequired: true,
                        isValid: !viewModel.deviceType.isEmpty || !viewModel.hasAttemptedSubmission
                    )
                    
                    FormField(
                        title: "Issue",
                        text: $viewModel.issue,
                        placeholder: "Brief description of issue",
                        isRequired: true,
                        isValid: !viewModel.issue.isEmpty || !viewModel.hasAttemptedSubmission
                    )
                    
                    FormField(
                        title: "Device Password/PIN",
                        text: $viewModel.devicePassword,
                        placeholder: "Enter if applicable"
                    )
                    
                    // Accessories
                    FormSectionHeader(title: "Accessories")
                    AccessoryGrid(viewModel: viewModel)
                    
                    if viewModel.droppingSomethingElse {
                        FormField(
                            title: "Other Items",
                            text: $viewModel.whatElseIsDropping,
                            placeholder: "What else are you dropping off?",
                            isRequired: true,
                            isValid: !viewModel.whatElseIsDropping.isEmpty || !viewModel.hasAttemptedSubmission
                        )
                    }
                    
                    // Additional Information
                    FormSectionHeader(title: "Additional Information")
                    AdditionalInfoToggles(viewModel: viewModel)
                    
                    if viewModel.hasbitlocker {
                        FormField(
                            title: "Bitlocker Key",
                            text: $viewModel.bitlockerKey,
                            placeholder: "Enter 48-digit recovery key",
                            isRequired: true,
                            isValid: !viewModel.bitlockerKey.isEmpty || !viewModel.hasAttemptedSubmission
                        )
                    }
                    
                    // Issue Description
                    FormSectionHeader(title: "Issue Description")
                    
                    FormField(
                        title: "Detailed Description",
                        text: $viewModel.issueDescription,
                        placeholder: "Provide detailed description of the issue",
                        isRequired: true,
                        isValid: !viewModel.issueDescription.isEmpty || !viewModel.hasAttemptedSubmission
                    )
                    
                    // Submit Button
                    Button {
                        Task {
                            await viewModel.createTicket()
                        }
                    } label: {
                        Text("Create Ticket")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                            .buttonStyle(CorporateButtonStyle(isEnabled: true))
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .padding()
                }
            }
            .containerRelativeFrame(.horizontal)
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .navigationTitle("Hi \(viewModel.customerName)!")
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .alert("Success", isPresented: $viewModel.ticketCreated) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Ticket created successfully!")
        }
    }
}


// MARK: - Preview
#Preview {
    NavigationStack {
        SubmitTicketInfoView(
            viewModel: TicketViewModel(
                customerID: 12345,
                customerName: "John"
            )
        )
    }
}

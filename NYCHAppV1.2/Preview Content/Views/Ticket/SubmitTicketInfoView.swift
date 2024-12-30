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

// MARK: - Supporting Views
struct AccessoryGrid: View {
    @ObservedObject var viewModel: TicketViewModel
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            AccessoryToggleButton(
                icon: "powerplug",
                title: "Charger",
                isSelected: $viewModel.droppingCharger
            )
            
            AccessoryToggleButton(
                icon: "cart",
                title: "Hand Truck",
                isSelected: $viewModel.droppingHandTruck
            )
            
            AccessoryToggleButton(
                icon: "laptopcomputer",
                title: "Sleeve",
                isSelected: $viewModel.droppingSleeve
            )
            
            AccessoryToggleButton(
                icon: "bag",
                title: "Bag",
                isSelected: $viewModel.droppingBag
            )
            
            AccessoryToggleButton(
                icon: "plus.circle",
                title: "Other",
                isSelected: $viewModel.droppingSomethingElse
            )
            .gridCellColumns(2)
        }
        .padding(.horizontal)
    }
}

struct AdditionalInfoToggles: View {
    @ObservedObject var viewModel: TicketViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            InfoToggleButton(
                icon: "lock.shield",
                title: "Has Bitlocker?",
                isSelected: $viewModel.hasbitlocker
            )
            
            InfoToggleButton(
                icon: "doc.text.fill",
                title: "Files Important?",
                isSelected: $viewModel.areFilesImportant
            )
            
            InfoToggleButton(
                icon: "checkmark.shield",
                title: "Under Warranty?",
                isSelected: $viewModel.isDeviceOnWarranty
            )
        }
        .padding(.horizontal)
    }
}

struct AccessoryToggleButton: View {
    let icon: String
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
    }
}

struct InfoToggleButton: View {
    let icon: String
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
            )
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

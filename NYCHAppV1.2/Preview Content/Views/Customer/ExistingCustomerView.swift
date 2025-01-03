import SwiftUI

struct ExistingCustomerView: View {
    @StateObject private var viewModel = ExistingCustomerViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 24) {
                // Search Type Toggle
                HStack(spacing: 24) {
                    SearchTypeButton(
                        isSelected: viewModel.searchType == "Phone",
                        icon: "phone.fill",
                        title: "Phone"
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.searchType = "Phone"
                            viewModel.searchText = ""
                        }
                    }
                    
                    SearchTypeButton(
                        isSelected: viewModel.searchType == "Email",
                        icon: "envelope.fill",
                        title: "Email"
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.searchType = "Email"
                            viewModel.searchText = ""
                        }
                    }
                }
                .padding(.horizontal)
                
                // Search Card
                VStack(spacing: 16) {
                    Text("Enter Your \(viewModel.searchType)")
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.secondaryColor)
                    
                    SearchField(
                        text: $viewModel.searchText,
                        placeholder: viewModel.searchType == "Phone" ? "Enter phone number" : "Enter email address",
                        icon: viewModel.searchType == "Phone" ? "phone.fill" : "envelope.fill",
                        keyboardType: viewModel.searchType == "Phone" ? .phonePad : .emailAddress,
                        isValid: viewModel.isInputValid,
                        isFocused: $isTextFieldFocused,
                        onSubmit: {
                            if viewModel.validateInput() {
                                Task {
                                    await viewModel.searchCustomer()
                                }
                            }
                        }
                    )
                    
                    if let validationMessage = viewModel.validationMessage {
                        Text(validationMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .transition(.opacity)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(AppTheme.backgroundColor)
                        .shadow(color: AppTheme.cardShadow, radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
            }
            .padding(.top)
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .navigationTitle("Existing Customer")
        .navigationBarTitleDisplayMode(.large)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .navigationDestination(isPresented: .constant(viewModel.foundCustomerId != nil)) {
            if let customerId = viewModel.foundCustomerId,
               let customerName = viewModel.foundCustomerName {
                SubmitTicketInfoView(
                    viewModel: TicketViewModel(
                        customerID: customerId,
                        customerName: customerName
                    )
                )
            }
        }
    }
}


#Preview {
    NavigationStack {
        ExistingCustomerView()
    }
}

import SwiftUI

struct ExistingCustomerView: View {
    @StateObject private var viewModel = ExistingCustomerViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 20) {
                // Search Type Toggle
                Picker("Search Type", selection: $viewModel.searchType) {
                    Text("Phone").tag("Phone")
                    Text("Email").tag("Email")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Search Card
                VStack(spacing: 16) {
                    Text("Enter Your \(viewModel.searchType)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        // Leading Icon
                        Image(systemName: viewModel.searchType == "Phone" ? "phone.fill" : "envelope.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        
                        TextField(viewModel.searchType == "Phone" ? "Enter phone number" : "Enter email address",
                                text: $viewModel.searchText)
                            .textFieldStyle(CustomSearchFieldStyle())
                            .keyboardType(viewModel.searchType == "Phone" ? .phonePad : .emailAddress)
                            .textContentType(viewModel.searchType == "Phone" ? .telephoneNumber : .emailAddress)
                            .autocapitalization(.none)
                            .focused($isTextFieldFocused)
                            .onChange(of: viewModel.searchText) { _, newValue in
                                if viewModel.searchType == "Phone" {
                                    viewModel.searchText = newValue.filter { $0.isNumber }
                                }
                            }
                        
                        // Clear button
                        if !viewModel.searchText.isEmpty {
                            Button {
                                viewModel.searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button {
                            if viewModel.validateInput() {
                                Task {
                                    await viewModel.searchCustomer()
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(viewModel.isInputValid ? .blue : .gray)
                        }
                        .disabled(!viewModel.isInputValid || viewModel.isLoading)
                    }
                    .padding(.horizontal)
                    
                    // Validation message
                    if let validationMessage = viewModel.validationMessage {
                        Text(validationMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                // Instructions or empty state
                if !viewModel.isLoading && viewModel.foundCustomerId == nil {
                    VStack(spacing: 12) {
                        Image(systemName: viewModel.searchType == "Phone" ? "phone.circle.fill" : "envelope.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Enter your \(viewModel.searchType.lowercased()) to find your information")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding(.top)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isTextFieldFocused = false
                    }
                }
            }
            
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

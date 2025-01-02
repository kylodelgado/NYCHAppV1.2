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

struct SearchTypeButton: View {
    let isSelected: Bool
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(AppTheme.bodyFont)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor)
                    .shadow(
                        color: isSelected ? AppTheme.primaryColor.opacity(0.3) : AppTheme.cardShadow,
                        radius: 5,
                        x: 0,
                        y: 2
                    )
            )
            .foregroundColor(isSelected ? .white : AppTheme.secondaryColor)
        }
    }
}

struct SearchField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    let keyboardType: UIKeyboardType
    let isValid: Bool
    var isFocused: FocusState<Bool>.Binding
    let onSubmit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(isFocused.wrappedValue ? AppTheme.primaryColor :
                    (isValid ? AppTheme.secondaryColor : .red))
                .font(.system(size: isFocused.wrappedValue ? 24 : 20))  // Dynamic scaling
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .focused(isFocused)
                .submitLabel(.search)
                .onSubmit {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()  // Haptic Feedback
                    onSubmit()
                }
            
            if !text.isEmpty {
                Button {
                    withAnimation {
                        text = ""
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()  // Haptic Feedback
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.secondaryColor)
                        .transition(.opacity)
                }
            }
            
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()  // Haptic Feedback
                onSubmit()
            }) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: isValid ? 48 : 44))  // Smooth transition
                    .foregroundColor(isValid ? AppTheme.primaryColor : AppTheme.secondaryColor)
                    .scaleEffect(isValid ? 1.1 : 1.0)  // Slight scale when active
            }
            .disabled(!isValid)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isValid)  // Smooth animation
        }
        .padding()
        .background(AppTheme.backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isFocused.wrappedValue ? AppTheme.primaryColor :
                        (isValid ? AppTheme.secondaryColor.opacity(0.2) : .red),
                    lineWidth: isFocused.wrappedValue ? 1.5 : 1
                )
                .shadow(color: isFocused.wrappedValue ? AppTheme.primaryColor.opacity(0.3) : .clear,
                        radius: isFocused.wrappedValue ? 5 : 0)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
    }
}

#Preview {
    NavigationStack {
        ExistingCustomerView()
    }
}

//
//  TicketTrackerView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 1/2/25.
//
import SwiftUI
import SwiftData

struct TicketTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomerInformation.timestamp, order: .reverse) private var customerInfo: [CustomerInformation]
    @StateObject private var viewModel = StatusCheckViewModel()
    @State private var showingNewSearchAlert = false
    @State private var isResetting = false
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    if !isResetting {
                        if let lastCustomer = customerInfo.first {
                            // Welcome Header with New Search Button
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Your Tickets")
                                        .font(.title2.bold())
                                    
                                    Spacer()
                                    
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            resetView()
                                        }
                                    } label: {
                                        Label("New Search", systemImage: "magnifyingglass")
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal)
                                
                                Text("Welcome back, \(lastCustomer.customerName.components(separatedBy: " ").first ?? "")!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            // Tickets List
                            VStack(spacing: 16) {
                                if viewModel.isLoading {
                                    VStack(spacing: 12) {
                                        ForEach(0..<3, id: \.self) { _ in
                                            TicketPlaceholderRow()
                                        }
                                    }
                                    .padding(.horizontal)
                                } else if !viewModel.customerTickets.isEmpty {
                                    ForEach(viewModel.customerTickets, id: \.id) { ticket in
                                        NavigationLink(destination: TicketDetailsCard(ticket: ticket)) {
                                            ImprovedTicketRow(ticket: ticket)
                                                .padding(.horizontal)
                                        }
                                    }
                                } else {
                                    LoadingView()
                                        .onAppear {
                                            if viewModel.customerTickets.isEmpty {
                                                Task {
                                                    viewModel.searchText = lastCustomer.phoneNumber
                                                    await viewModel.searchTicket()
                                                }
                                            }
                                        }
                                }
                            }
                        } else {
                            // Search View
                            VStack(spacing: 16) {
                                Text("Check Ticket Status")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                SearchField(
                                    text: $viewModel.searchText,
                                    placeholder: "Enter ticket # or phone number",
                                    icon: viewModel.searchText.count == 5 ? "ticket" : "phone",
                                    keyboardType: .numberPad,
                                    isValid: !viewModel.searchText.isEmpty,
                                    isFocused: $isSearchFocused  // Change this
                                ) {
                                    Task {
                                        await viewModel.searchTicket()
                                        if !viewModel.customerTickets.isEmpty {
                                            storeCustomerInfo()
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(AppTheme.backgroundColor)
                                        .shadow(color: AppTheme.cardShadow, radius: 5)
                                )
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        // Transition view while resetting
                        VStack(spacing: 16) {
                            Text("Check Ticket Status")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            SearchField(
                                text: $viewModel.searchText,
                                placeholder: "Enter ticket # or phone number",
                                icon: viewModel.searchText.count == 5 ? "ticket" : "phone",
                                keyboardType: .numberPad,
                                isValid: !viewModel.searchText.isEmpty,
                                isFocused: $isSearchFocused
                            ) {
                                Task {
                                    await viewModel.searchTicket()
                                    if !viewModel.customerTickets.isEmpty {
                                        storeCustomerInfo()
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(AppTheme.backgroundColor)
                                    .shadow(color: AppTheme.cardShadow, radius: 5)
                            )
                            .padding(.horizontal)
                        }
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                }
                .padding(.top)
            }
        }
    }
    
    private func resetView() {
        // Clear stored data
        customerInfo.forEach { modelContext.delete($0) }
        try? modelContext.save()
        
        // Reset view model
        viewModel.clearSearch()
        
        // Trigger animation
        withAnimation(.easeInOut(duration: 0.3)) {
            isResetting = true
        }
        
        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isResetting = false
            }
        }
    }
    
    private func storeCustomerInfo() {
        if let foundInfo = viewModel.foundCustomerInfo {
            // Clear existing data
            customerInfo.forEach { modelContext.delete($0) }
            try? modelContext.save()
            
            // Store new customer
            let newCustomer = CustomerInformation(
                phoneNumber: foundInfo.phone,
                customerID: foundInfo.id,
                customerName: foundInfo.name
            )
            
            modelContext.insert(newCustomer)
            try? modelContext.save()
        }
    }
}







#Preview {
    TicketTrackerView()
}




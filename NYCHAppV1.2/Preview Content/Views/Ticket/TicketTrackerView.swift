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
    @State private var showingSearchView = false
    @State private var showingNewSearchAlert = false
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    if let lastCustomer = customerInfo.first {
                        // Welcome Header
                        WelcomeHeader(
                            customerName: lastCustomer.customerName,
                            showNewSearchAlert: $showingNewSearchAlert
                        )
                        
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
                                // This is where we show the tickets
                                ForEach(viewModel.customerTickets, id: \.id) { ticket in
                                    ImprovedTicketRow(ticket: ticket)
                                        .padding(.horizontal)
                                }
                            } else {
                                LoadingView()
                                    .onAppear {
                                        Task {
                                            print("Loading tickets for phone: \(lastCustomer.phoneNumber)")
                                            viewModel.searchText = lastCustomer.phoneNumber
                                            await viewModel.searchTicket()
                                        }
                                    }
                            }
                        }
                    } else {
                        // First-time user view
                        NewCustomerView(
                            viewModel: viewModel,
                            onTicketsFound: storeCustomerInfo
                        )
                    }
                }
                .padding(.top)
            }
        }
        .sheet(isPresented: $showingSearchView) {
            DifferentTicketSearchView { newTickets in
                if !newTickets.isEmpty,
                   let firstTicket = newTickets.first {
                    storeNewCustomerInfo(
                        phoneNumber: viewModel.searchText,
                        customerID: firstTicket.customerId,
                        customerName: firstTicket.customerName
                    )
                    viewModel.customerTickets = newTickets
                    showingSearchView = false
                }
            }
        }
        .alert("Check Different Ticket?", isPresented: $showingNewSearchAlert) {
            Button("New Search") {
                showingSearchView = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle("Your Tickets")
    }
    private func storeNewCustomerInfo(phoneNumber: String, customerID: Int, customerName: String) {
        // Clear existing data
        customerInfo.forEach { modelContext.delete($0) }
        
        // Store new customer information
        let newCustomer = CustomerInformation(
            phoneNumber: phoneNumber,
            customerID: customerID,
            customerName: customerName
        )
        
        modelContext.insert(newCustomer)
        
        do {
            try modelContext.save()
            print("Successfully stored new customer info - Phone: \(phoneNumber), Name: \(customerName)")
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    private func storeCustomerInfo() {
        guard !viewModel.customerTickets.isEmpty,
              let firstTicket = viewModel.customerTickets.first else {
            print("No tickets to store")
            return
        }
        
        storeNewCustomerInfo(
            phoneNumber: viewModel.searchText,
            customerID: firstTicket.customerId,
            customerName: firstTicket.customerName
        )
    }
}

struct DifferentTicketSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = StatusCheckViewModel()
    @FocusState private var isSearchFocused: Bool
    let onTicketsFound: ([TicketDetails]) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()
                
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
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
                    
                    ScrollView {
                        if viewModel.isLoading {
                            LoadingView()
                        } else if !viewModel.customerTickets.isEmpty {
                            VStack(spacing: 16) {
                                ForEach(viewModel.customerTickets, id: \.id) { ticket in
                                    TicketResultCard(ticket: ticket)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                            .onChange(of: viewModel.customerTickets) { _, tickets in
                                onTicketsFound(tickets)
                            }
                        } else {
                            EmptySearchState()
                        }
                    }
                }
            }
            .navigationTitle("Check Different Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

struct TicketResultCard: View {
    let ticket: TicketDetails
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ticket #\(ticket.number)")
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.primaryColor)
                    Text(ticket.subject)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.secondaryColor)
                }
                
                Spacer()
                
                StatusBadge(status: ticket.status)
            }
            
            Divider()
            
            HStack {
                Text(ticket.customerName)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryColor)
                
                Spacer()
                
                Text(ticket.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryColor)
            }
        }
        .padding()
        .background(AppTheme.backgroundColor)
        .cornerRadius(12)
        .shadow(
            color: AppTheme.cardShadow,
            radius: isPressed ? 2 : 4,
            x: 0,
            y: isPressed ? 1 : 2
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
    }
}

struct EmptySearchState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.secondaryColor.opacity(0.5))
            
            Text("Enter a ticket number or phone number")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryColor)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct TicketListView: View {
    let tickets: [TicketDetails]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(tickets, id: \.id) { ticket in
                NavigationLink(destination: TicketDetailsCard(ticket: ticket)) {
                    CustomerTicketRow(ticket: ticket)
                        .padding(.horizontal)
                }
            }
        }
    }
}

struct NewCustomerView: View {
    @ObservedObject var viewModel: StatusCheckViewModel
    let onTicketsFound: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Check Ticket Status")
                .font(.headline)
                .foregroundColor(.gray)
            
            SearchCard(viewModel: viewModel)
            
            if viewModel.isLoading {
                LoadingView()
            } else if !viewModel.customerTickets.isEmpty {
                TicketListView(tickets: viewModel.customerTickets)
                    .task {
                        if !viewModel.customerTickets.isEmpty {
                            onTicketsFound()
                        }
                    }
            } else {
                SearchEmptyStateView()
            }
        }
    }
}
private struct StoredCustomerView: View {
    let lastCustomer: CustomerInformation
    @ObservedObject var viewModel: StatusCheckViewModel
    @Binding var showingNewSearchAlert: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Tickets")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
                Button("Check Different Ticket") {
                    showingNewSearchAlert = true
                }
            }
            .padding(.horizontal)
            
            if !lastCustomer.customerName.isEmpty {
                Text("Welcome back, \(lastCustomer.customerName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if viewModel.isLoading {
                LoadingView()
            } else if !viewModel.customerTickets.isEmpty {
                ForEach(viewModel.customerTickets, id: \.id) { ticket in
                    NavigationLink(destination: TicketDetailsCard(ticket: ticket)) {
                        CustomerTicketRow(ticket: ticket)
                            .padding(.horizontal)
                    }
                }
            } else {
                Text("Loading your tickets...")
                    .onAppear {
                        Task {
                            print("Loading tickets for stored customer: \(lastCustomer.phoneNumber)")
                            viewModel.searchText = lastCustomer.phoneNumber
                            await viewModel.searchTicket()
                        }
                    }
            }
        }
    }
}


// MARK: - Returning User Content View
private struct ReturningUserView: View {
    let lastCustomer: CustomerInformation
    @ObservedObject var viewModel: StatusCheckViewModel
    @Binding var showingNewSearchAlert: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Tickets")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button {
                    showingNewSearchAlert = true
                } label: {
                    Label("Check Different Ticket", systemImage: "magnifyingglass")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
            
            if !lastCustomer.customerName.isEmpty {
                Text("Welcome back, \(lastCustomer.customerName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            
            if viewModel.isLoading {
                LoadingView()
            } else if !viewModel.customerTickets.isEmpty {
                TicketListView(tickets: viewModel.customerTickets)
            } else {
                Text("Loading your tickets...")
                    .onAppear {
                        Task {
                            print("Loading tickets for phone: \(lastCustomer.phoneNumber)")
                            viewModel.searchText = lastCustomer.phoneNumber
                            await viewModel.searchTicket()
                        }
                    }
            }
        }
    }
}

// MARK: - First Time User Content View
private struct FirstTimeUserView: View {
    @ObservedObject var viewModel: StatusCheckViewModel
    let onTicketsLoaded: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Check Ticket Status")
                .font(.headline)
                .foregroundColor(.gray)
            
            SearchCard(viewModel: viewModel)
            
            if viewModel.isLoading {
                LoadingView()
            } else if let ticket = viewModel.ticket {
                TicketDetailsCard(ticket: ticket)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if !viewModel.customerTickets.isEmpty {
                TicketListView(tickets: viewModel.customerTickets)
                    .onChange(of: viewModel.customerTickets) { _, newValue in
                        if !newValue.isEmpty {
                            onTicketsLoaded()
                        }
                    }
            } else {
                SearchEmptyStateView()
            }
        }
    }
}

// MARK: - Ticket List View



#Preview {
    TicketTrackerView()
}


struct WelcomeHeader: View {
    let customerName: String
    @Binding var showNewSearchAlert: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                // Customer info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Tickets")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Welcome back, \(customerName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Search button with improved styling
                Button {
                    showNewSearchAlert = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                        Text("New Search")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .padding(.horizontal)
    }
}


struct ImprovedTicketRow: View {
    let ticket: TicketDetails
    @State private var isPressed = false
    
    var displayProblemType: String {
        if let type = ticket.problem_type {
            return type == "API" ? "General Repair" : type
        }
        return "General Repair"
    }
    
    var body: some View {
        NavigationLink(destination: TicketDetailsCard(ticket: ticket)) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with Ticket number and Status
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ticket #\(ticket.number)")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Text(ticket.subject)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: ticket.status)
                }
                
                Divider()
                
                // Footer with additional info
                HStack {
                    // Repair type
                    HStack(spacing: 6) {
                        Image(systemName: "wrench.and.screwdriver")
                            .foregroundColor(.gray)
                        
                        Text(displayProblemType)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Date
                    Text(ticket.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: isPressed ? 2 : 4, x: 0, y: isPressed ? 1 : 2)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: isPressed) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
        .onTapGesture {
            withAnimation {
                isPressed = true
            }
        }
    }
}


struct TicketPlaceholderRow: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 20)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 20)
            }
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 16)
            
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 16)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 16)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .opacity(isAnimating ? 0.6 : 1.0)
        .animation(
            Animation.easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
    }
}




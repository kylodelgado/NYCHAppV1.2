//
//  ReusableComponents.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 1/2/25.
//

import Foundation
import SwiftUI



struct DifferentTicketSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = StatusCheckViewModel()
    @ObservedObject var mainViewModel: StatusCheckViewModel
    @FocusState private var isSearchFocused: Bool
    let onTicketsFound: ([TicketDetails]) -> Void
    
    init(mainViewModel: StatusCheckViewModel, onTicketsFound: @escaping ([TicketDetails]) -> Void) {
        self.mainViewModel = mainViewModel
        self.onTicketsFound = onTicketsFound
        _viewModel = StateObject(wrappedValue: StatusCheckViewModel())
    }
    
    private func handleSuccess() {
        if !viewModel.customerTickets.isEmpty {
            mainViewModel.clearSearch() // Clear main viewModel
            onTicketsFound(viewModel.customerTickets)
            mainViewModel.foundCustomerInfo = viewModel.foundCustomerInfo
            dismiss()
        } else if let ticket = viewModel.ticket {
            mainViewModel.clearSearch() // Clear main viewModel
            onTicketsFound([ticket])
            mainViewModel.foundCustomerInfo = viewModel.foundCustomerInfo
            dismiss()
        }
    }
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
                        } else if !viewModel.customerTickets.isEmpty || viewModel.ticket != nil {
                            VStack(spacing: 16) {
                                if !viewModel.customerTickets.isEmpty {
                                    ForEach(viewModel.customerTickets, id: \.id) { ticket in
                                        NavigationLink(destination: TicketDetailsCard(ticket: ticket)) {
                                            TicketResultCard(ticket: ticket)
                                                .padding(.horizontal)
                                        }
                                    }
                                } else if let ticket = viewModel.ticket {
                                    NavigationLink(destination: TicketDetailsCard(ticket: ticket)) {
                                        TicketResultCard(ticket: ticket)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.vertical)
                            .onChange(of: viewModel.customerTickets) { _, tickets in
                                if !tickets.isEmpty {
                                    handleSuccess()
                                }
                            }
                            .onChange(of: viewModel.ticket) { _, ticket in
                                if ticket != nil {
                                    handleSuccess()
                                }
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
                    Button(action: {
                        viewModel.clearSearch()
                        dismiss()
                    }) {
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

struct StoredCustomerView: View {
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
struct ReturningUserView: View {
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

struct SearchCard: View {
    @ObservedObject var viewModel: StatusCheckViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Enter Ticket # or Phone Number")
                .font(.headline)
                .foregroundColor(.gray)
            
            SearchField(
                text: $viewModel.searchText,
                placeholder: "Enter ticket # or phone",
                icon: "magnifyingglass.circle.fill",
                keyboardType: .numberPad,
                isValid: !viewModel.searchText.isEmpty,
                isFocused: $isTextFieldFocused,
                onSubmit: {
                    Task {
                        await viewModel.searchTicket()
                    }
                    isTextFieldFocused = false
                }
            )
            .disabled(viewModel.isLoading)  // Disable while loading
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}
struct CustomerTicketRow: View {
    let ticket: TicketDetails
    
    var displayProblemType: String {
        if let type = ticket.problem_type {
            return type == "API" ? "General Repair" : type
        }
        return "General Repair"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
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
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "wrench.and.screwdriver")
                        .foregroundColor(.gray)
                    
                    Text(displayProblemType)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(ticket.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}



struct SearchEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "ticket")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Enter a ticket number or phone number")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}



// Custom Search Field Style
struct CustomSearchFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// Ticket Details Card
struct TicketDetailsCard: View {
    let ticket: TicketDetails
    
    var body: some View {
        ScrollView {
            
        
        VStack(spacing: 20) {
            // Header with Status
            HStack {
                VStack(alignment: .leading) {
                    Text("Ticket #\(ticket.number)")
                        .font(.headline)
                    Text(ticket.customerName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()

                StatusBadge(status: ticket.status)
            }
            
            Divider()
            
            // Device & Issue Details
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(title: "Device", value: ticket.subject)
                if let business = ticket.customerBusinessName {
                    DetailRow(title: "Business", value: business)
                }
                DetailRow(title: "Created", value: ticket.createdAt.formatted(date: .abbreviated, time: .shortened))
                if let dueDate = ticket.dueDate {
                    DetailRow(title: "Due Date", value: dueDate.formatted(date: .abbreviated, time: .shortened))
                }
            }
            
            // Comments/Updates Section
            if !ticket.comments.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Updates")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    ForEach(ticket.comments.prefix(10), id: \.id) { comment in
                        if comment.hidden == false {
                            
                            
                            CommentView(comment: comment)
                        }
                        
                    }
                }
            }
        }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

// Supporting Views
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

struct CommentView: View {
    let comment: TicketComment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(comment.subject ?? "No Tech")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Text(comment.body ?? "No Comment")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("By \(comment.tech ?? "No Tech")")
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .padding(10)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct StatusBadge: View {
    let status: String
    
    var statusInfo: (color: Color, icon: String) {
        switch status.lowercased() {
        case "new", "marcus", "mike":
            return (.blue, "circle.fill")
        case "in progress", "diagnostic in progress", "diagnostic completed",
             "2- just approved! start work.", "d4b - in progress", "alamy - in progress":
            return (.orange, "arrow.triangle.2.circlepath")
        case "waiting for parts", "part arrived! awaiting customer":
            return (.purple, "clock.fill")
        case "waiting on customer":
            return (.yellow, "person.fill.questionmark")
        case "repair complete", "ready for pick-up":
            return (.green, "checkmark.circle.fill")
        case "resolved", "done->customer action needed", "scheduled", "cognism - stored device":
            return (.gray, "archivebox.fill")
        default:
            return (.gray, "circle.fill")
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: statusInfo.icon)
                .font(.system(size: 12))
            Text(status)
                .lineLimit(1)
        }
        .font(.system(size: 12, weight: .medium))
        .foregroundColor(statusInfo.color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(statusInfo.color.opacity(0.15))
        .cornerRadius(8)
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.95, blue: 0.97)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.black)
                
                Text("Loading...")
                    .foregroundColor(.black.opacity(0.5))
                    .font(.headline)
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
    }
}

struct GradientBackground: View {
    var body: some View {
        Color(red: 0.93, green: 0.95, blue: 0.97) // #EBEBEB
                  .ignoresSafeArea()
    }
}
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

struct CustomAssets: View {
    
    @State var xPosition: CGFloat = 0
    @State var yPosition: CGFloat = 0
    
    var body: some View {
        VStack {
            
            Text("My Position is x \(xPosition), y \(yPosition)")
                .foregroundStyle(.blue)
                .offset(x: xPosition, y: yPosition)
            
            Button ("Go Up"){
                yPosition -= 10
            }.buttonStyle(CorporateButtonStyle(isEnabled: true))
                .padding()
            
            
        }
    }
}


struct NewButton: View {
    @State var textToShow: String = "Repair Status"
 
  
    
    var body: some View {
        

            ZStack {
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(.blue.opacity(0.6).gradient)
                    .shadow(color: .blue.opacity(0.5), radius: 6, x: 0, y: 7)
                    
                    .frame(height: 50)
                    
                    .containerRelativeFrame(.horizontal) { width, axis in
                        width * 0.95
                    }
                Text(textToShow)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        
    }
}


struct ButtonView: View {
    @State  var textToShow: String = "Repair Status"
    @State  var imageToShow = "desktop"
    @State private var gradientColors = [Color.blue.opacity(0.3), Color.white.opacity(0.1)]
    @State private var animateGradient = false // State for color animation
    @State var frameWidth = 150.0
    @State var frameHeight = 150.0
    
    var body: some View {
        ZStack {
            ZStack {
                
                
                // Background for 3D effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 6, x: 4, y: 4) // Shadow for depth
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    )
                    .overlay{
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 1)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.85, green: 0.9, blue: 1.0),Color(red: 0.6, green: 0.7, blue: 0.9),
                                    Color(red: 0.92, green: 0.85, blue: 1.0), Color(red: 0.7, green: 0.6, blue: 0.8)
                                ]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        
                        
                        
                    }
            }
            .frame(width: 150, height: 150)
            .onAppear {
                // Start the gradient color animation
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    gradientColors = [.white, .black.opacity(0.1)]
                }
            }
                // Size animation
               

            // Content
            VStack {
                Image(imageToShow)
                    .resizable()
                    .scaledToFit()
                    .frame(width: (frameWidth / 5) * 2, height: (frameHeight / 5) * 2) // Adjust for better alignment
                    .opacity(0.6)
                Text(textToShow)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        } .preferredColorScheme(.light)
        .padding(9)
  
    }
}


struct CustomPickerView: View {
    @Binding var selectedOption: String
    let options = [
        ("Ticket Number", "number"),
        ("Name", "person.fill"),
        ("Phone Number", "phone.fill")
    ]

    var body: some View {
        HStack {
            ForEach(options, id: \.0) { option in
                Button(action: {
                    selectedOption = option.0
                    
                }) {
                    VStack {
                        Image(systemName: option.1)
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text(option.0)
                            .font(.caption)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedOption == option.0 ? Color.blue.opacity(0.5) : Color.gray.opacity(0.2))
                    )
                    .foregroundColor(selectedOption == option.0 ? .white : .black)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct CustomTextField: View {
    @Binding var text: String
    @State var topText: String
    @State private var animateGradient = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(topText)
                .font(.caption)
                .foregroundColor(.gray)
                .offset(y: 5)
                .padding(.horizontal)
            
            TextField("", text: $text)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 2)
                        .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            animateGradient ? Color(red: 0.85, green: 0.9, blue: 1.0) : Color(red: 0.6, green: 0.7, blue: 0.9),
                            Color(red: 0.92, green: 0.85, blue: 1.0), Color(red: 0.7, green: 0.6, blue: 0.8)
                        ]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        
                )
                .padding(.horizontal)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
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

struct States {
    static let states = [
        "AL": "Alabama",
        "AK": "Alaska",
        "AZ": "Arizona",
        "AR": "Arkansas",
        "CA": "California",
        "CO": "Colorado",
        "CT": "Connecticut",
        "DE": "Delaware",
        "FL": "Florida",
        "GA": "Georgia",
        "HI": "Hawaii",
        "ID": "Idaho",
        "IL": "Illinois",
        "IN": "Indiana",
        "IA": "Iowa",
        "KS": "Kansas",
        "KY": "Kentucky",
        "LA": "Louisiana",
        "ME": "Maine",
        "MD": "Maryland",
        "MA": "Massachusetts",
        "MI": "Michigan",
        "MN": "Minnesota",
        "MS": "Mississippi",
        "MO": "Missouri",
        "MT": "Montana",
        "NE": "Nebraska",
        "NV": "Nevada",
        "NH": "New Hampshire",
        "NJ": "New Jersey",
        "NM": "New Mexico",
        "NY": "New York",
        "NC": "North Carolina",
        "ND": "North Dakota",
        "OH": "Ohio",
        "OK": "Oklahoma",
        "OR": "Oregon",
        "PA": "Pennsylvania",
        "RI": "Rhode Island",
        "SC": "South Carolina",
        "SD": "South Dakota",
        "TN": "Tennessee",
        "TX": "Texas",
        "UT": "Utah",
        "VT": "Vermont",
        "VA": "Virginia",
        "WA": "Washington",
        "WV": "West Virginia",
        "WI": "Wisconsin",
        "WY": "Wyoming",
        "DC": "District of Columbia"
    ]
    
    let stateAbbreviations = Array(states.keys).sorted()
    let stateNames = Array(states.values).sorted()
}

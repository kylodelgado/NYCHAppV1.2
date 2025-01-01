//
//  StatusCheckView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/11/24.
//


import SwiftUI

struct StatusCheckView: View {
    @StateObject private var viewModel = StatusCheckViewModel()
   
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 20) {
                // Search Card (remains the same)
                SearchCard(viewModel: viewModel)
                
                // Results Section
                ScrollView {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if let ticket = viewModel.ticket {
                        // Single ticket view
                        TicketDetailsCard(ticket: ticket)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if !viewModel.customerTickets.isEmpty {
                        // List of tickets
                        VStack(spacing: 12) {
                            Text("Found \(viewModel.customerTickets.count) tickets")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.top)
                            
                            ForEach(viewModel.customerTickets, id: \.id) { ticket in
                                NavigationLink(destination: TicketDetailsCard(ticket: ticket)) {
                                    CustomerTicketRow(ticket: ticket)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    } else {
                        SearchEmptyStateView()
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("Check Status")
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
            
            HStack {
                TextField("Search", text: $viewModel.searchText)
                    .textFieldStyle(CustomSearchFieldStyle())
                    .focused($isTextFieldFocused)
                    .keyboardType(.numberPad)
                    .onSubmit {
                        isTextFieldFocused = false
                    }
                
                Button {
                    Task {
                        await viewModel.searchTicket()
                    }
                    isTextFieldFocused = false
                } label: {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.blue)
                }
                .disabled(viewModel.searchText.isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal)
            .onTapGesture {
                isTextFieldFocused = false
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
    
    var statusColor: Color {
        switch status.lowercased() {
        // New/Initial States - Blue
        case "new", "marcus", "mike":
            return Color(red: 0.0, green: 0.47, blue: 1.0)  // Brighter blue
            
        // In Progress States - Orange
        case "in progress", "diagnostic in progress", "diagnostic completed",
             "2- just approved! start work.", "d4b - in progress", "alamy - in progress":
            return Color(red: 1.0, green: 0.6, blue: 0.0)  // Warmer orange
            
        // Waiting States - Purple/Pink
        case "waiting for parts", "part arrived! awaiting customer":
            return Color(red: 0.69, green: 0.32, blue: 0.87)  // Rich purple
            
        // Customer Action Required - Yellow
        case "waiting on customer":
            return Color(red: 0.95, green: 0.77, blue: 0.06)  // Warm yellow
            
        // Completed States - Green
        case "repair complete", "ready for pick-up":
            return Color(red: 0.2, green: 0.8, blue: 0.4)  // Bright green
            
        // Resolved/Closed States - Gray
        case "resolved", "done->customer action needed", "scheduled", "cognism - stored device":
            return Color(red: 0.5, green: 0.55, blue: 0.6)  // Cool gray
            
        default:
            return Color(red: 0.6, green: 0.6, blue: 0.6)
        }
    }
    
    var body: some View {
        Text(status)
            .font(.system(size: 12, weight: .medium))  // Slightly larger font
            .padding(.horizontal, 12)  // More horizontal padding
            .padding(.vertical, 6)     // More vertical padding
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(statusColor.opacity(0.15))  // Lighter background
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(statusColor.opacity(0.3), lineWidth: 1)  // Subtle border
                    )
            )
            .foregroundColor(statusColor)
    }
}
#Preview {
    NavigationStack {
        StatusCheckView()
    }
}

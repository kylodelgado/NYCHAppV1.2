//
//  StatusCheckView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/11/24.
//

import SwiftUI



struct StatusCheckView: View {
    @StateObject private var viewModel = StatusCheckViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 20) {
                // Status Search Card
                VStack(spacing: 16) {
                    Text("Enter Repair Ticket Number")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        TextField("Ticket Number", text: $viewModel.searchText)
                            .textFieldStyle(CustomSearchFieldStyle())
                            .keyboardType(.numberPad)
                        
                        Button {
                            Task {
                                await viewModel.searchTicket()
                            }
                        } label: {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.blue)
                        }
                        .disabled(viewModel.searchText.isEmpty || viewModel.isLoading)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                // Ticket Details Section
                if viewModel.isLoading {
                    LoadingView()
                } else if let ticket = viewModel.ticket {
                    TicketDetailsCard(ticket: ticket)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Instructions or empty state
                    VStack(spacing: 12) {
                        Image(systemName: "ticket")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Enter your ticket number to check repair status")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                Spacer()
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
        case "new", "marcus", "mike":
            return .blue
        case "in progress", "diagnostic in progress", "diagnostic completed", "2- just approved! start work.", "d4b - in progress", "alamy - in progress":
            return .orange
        case "waiting for parts", "part arrived! awaiting customer":
            return .purple
        case "waiting on customer":
            return .yellow
        case "repair complete":
            return .green
        case "resolved", "done->customer action needed", "scheduled", "cognism - stored device", "ready for pick-up":
            return .gray
        // Add more cases if specific colors are needed for other statuses
        default:
            return .gray  // Default for any status not explicitly handled
        }
    }
    
    var body: some View {
        Text(status)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
}
#Preview {
    NavigationStack {
        StatusCheckView()
    }
}

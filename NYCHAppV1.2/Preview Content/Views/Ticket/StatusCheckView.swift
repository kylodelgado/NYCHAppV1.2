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


#Preview {
    NavigationStack {
        StatusCheckView()
    }
}

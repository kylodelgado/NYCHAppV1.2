//
//  ExistingCustomerView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/30/24.
//

import SwiftUI

struct ExistingCustomerView: View {
    @StateObject private var viewModel = StatusCheckViewModel()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        TestField()
//        ZStack {
//            GradientBackground()
//            
//            VStack(spacing: 20) {
//                // Status Search Card
//                VStack(spacing: 16) {
//                    Text("Enter Repair Ticket Number")
//                        .font(.headline)
//                        .foregroundColor(.gray)
//                    
//                    HStack {
//                        TextField("Ticket Number", text: $viewModel.searchText)
//                            .textFieldStyle(CustomSearchFieldStyle())
//                            .keyboardType(.numberPad)
//                        
//                        Button {
//                            Task {
//                                await viewModel.searchTicket()
//                            }
//                        } label: {
//                            Image(systemName: "magnifyingglass.circle.fill")
//                                .font(.system(size: 44))
//                                .foregroundColor(.blue)
//                        }
//                        .disabled(viewModel.searchText.isEmpty || viewModel.isLoading)
//                    }
//                    .padding(.horizontal)
//                }
//                .padding()
//                .background(
//                    RoundedRectangle(cornerRadius: 15)
//                        .fill(Color.white)
//                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//                )
//                .padding(.horizontal)
//                
//                // Ticket Details Section
//                if viewModel.isLoading {
//                    LoadingView()
//                } else if let ticket = viewModel.ticket {
//                    TicketDetailsCard(ticket: ticket)
//                        .transition(.move(edge: .bottom).combined(with: .opacity))
//                } else {
//                    // Instructions or empty state
//                    VStack(spacing: 12) {
//                        Image(systemName: "ticket")
//                            .font(.system(size: 50))
//                            .foregroundColor(.gray.opacity(0.5))
//                        
//                        Text("Enter your ticket number to check repair status")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                            .multilineTextAlignment(.center)
//                    }
//                    .padding()
//                }
//                
//                Spacer()
//            }
//            .padding(.top)
//        }
//        .navigationTitle("Check Status")
//        .navigationBarTitleDisplayMode(.large)
//        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
//            Button("OK") {
//                viewModel.clearError()
//            }
//        } message: {
//            if let error = viewModel.errorMessage {
//                Text(error)
//            }
//        }
    }
}

#Preview {
    ExistingCustomerView()
}

////
////  DifferentTicketSearchView.swift
////  NYCHAppV1.2
////
////  Created by Brandon Delgado on 1/2/25.
////
//
//import SwiftUI
//
//struct DifferentTicketSearchView: View {
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var viewModel = StatusCheckViewModel()
//    @FocusState private var isSearchFocused: Bool
//    let onTicketsFound: ([TicketDetails]) -> Void
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                GradientBackground()
//                
//                VStack(spacing: 20) {
//                    // Search Field
//                    VStack(spacing: 16) {
//                        SearchField(
//                            text: $viewModel.searchText,
//                            placeholder: "Enter ticket # or phone number",
//                            icon: viewModel.searchText.count == 5 ? "ticket" : "phone",
//                            keyboardType: .numberPad,
//                            isValid: !viewModel.searchText.isEmpty,
//                            isFocused: _isSearchFocused
//                        ) {
//                            Task {
//                                await viewModel.searchTicket()
//                            }
//                        }
//                        .padding()
//                        .background(
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(AppTheme.backgroundColor)
//                                .shadow(color: AppTheme.cardShadow, radius: 5)
//                        )
//                        .padding(.horizontal)
//                    }
//                    
//                    // Results
//                    ScrollView {
//                        if viewModel.isLoading {
//                            LoadingView()
//                        } else if !viewModel.customerTickets.isEmpty {
//                            VStack(spacing: 16) {
//                                ForEach(viewModel.customerTickets, id: \.id) { ticket in
//                                    TicketResultCard(ticket: ticket)
//                                        .padding(.horizontal)
//                                }
//                            }
//                            .padding(.vertical)
//                        } else {
//                            EmptySearchState()
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Check Different Ticket")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: { dismiss() }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundStyle(.gray)
//                    }
//                }
//            }
//            .onChange(of: viewModel.customerTickets) { tickets in
//                if !tickets.isEmpty {
//                    onTicketsFound(tickets)
//                }
//            }
//        }
//    }
//}
//
//struct TicketResultCard: View {
//    let ticket: TicketDetails
//    @State private var isPressed = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Ticket #\(ticket.number)")
//                        .font(AppTheme.headlineFont)
//                        .foregroundColor(AppTheme.primaryColor)
//                    Text(ticket.subject)
//                        .font(AppTheme.bodyFont)
//                        .foregroundColor(AppTheme.secondaryColor)
//                }
//                
//                Spacer()
//                
//                StatusBadge(status: ticket.status)
//            }
//            
//            Divider()
//            
//            HStack {
//                Text(ticket.customerName)
//                    .font(AppTheme.bodyFont)
//                    .foregroundColor(AppTheme.secondaryColor)
//                
//                Spacer()
//                
//                Text(ticket.createdAt.formatted(date: .abbreviated, time: .shortened))
//                    .font(.caption)
//                    .foregroundColor(AppTheme.secondaryColor)
//            }
//        }
//        .padding()
//        .background(AppTheme.backgroundColor)
//        .cornerRadius(12)
//        .shadow(
//            color: AppTheme.cardShadow,
//            radius: isPressed ? 2 : 4,
//            x: 0,
//            y: isPressed ? 1 : 2
//        )
//        .scaleEffect(isPressed ? 0.98 : 1.0)
//        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
//        .onTapGesture {
//            withAnimation {
//                isPressed = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    isPressed = false
//                }
//            }
//        }
//    }
//}
//
//struct EmptySearchState: View {
//    var body: some View {
//        VStack(spacing: 12) {
//            Image(systemName: "magnifyingglass")
//                .font(.system(size: 50))
//                .foregroundColor(AppTheme.secondaryColor.opacity(0.5))
//            
//            Text("Enter a ticket number or phone number")
//                .font(AppTheme.bodyFont)
//                .foregroundColor(AppTheme.secondaryColor)
//                .multilineTextAlignment(.center)
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    DifferentTicketSearchView()
//}

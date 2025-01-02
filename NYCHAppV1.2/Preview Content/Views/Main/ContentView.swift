//
//  ContentView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/7/24.
//
import SwiftUI
import Foundation
import SwiftData
enum Route: Hashable {
    case statusCheck
    case newRepair
    case quickQuote
    case contact
    case existingCustomer
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var navigationPath = NavigationPath()
    @State private var showContactSheet = false
    @State private var showCustomerSelection = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                GradientBackground()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Company Logo
                        Image("nychlogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .padding(.top, 20)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                        
                        // Quick Actions Section
                        VStack(spacing: 20) {
                            HStack {
                                if showCustomerSelection {
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            showCustomerSelection = false
                                        }
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                Text(!showCustomerSelection ? "Quick Actions" : "New Repair")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(.primary)
                                
                                if showCustomerSelection {
                                    Spacer()
                                }
                            }
                            
                            if showCustomerSelection {
                                // Customer selection buttons with transition
                                VStack(spacing: 16) {
                                    ActionCard(
                                        title: "New Customer",
                                        iconName: "person.badge.plus",
                                        description: "Register as a new customer",
                                        color: .blue
                                    ) {
                                        withAnimation {
                                            navigationPath.append(Route.newRepair)
                                            showCustomerSelection = false
                                        }
                                    }
                                    
                                    ActionCard(
                                        title: "Existing Customer",
                                        iconName: "person.fill.checkmark",
                                        description: "Sign in for repair",
                                        color: .green
                                    ) {
                                        withAnimation {
                                            navigationPath.append(Route.existingCustomer)
                                            showCustomerSelection = false
                                        }
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            } else {
                                // Main action buttons with grid layout
                                LazyVGrid(
                                    columns: [
                                        GridItem(.flexible(), spacing: 16),
                                        GridItem(.flexible(), spacing: 16)
                                    ],
                                    spacing: 16
                                ) {
                                    ActionCard(
                                        title: "Your Tickets",
                                        iconName: "ticket.fill",
                                        description: "View & track repairs",
                                        color: .blue
                                    ) {
                                        navigationPath.append(Route.statusCheck)
                                    }
                                    
                                    ActionCard(
                                        title: "New Repair",
                                        iconName: "wrench.and.screwdriver.fill",
                                        description: "Start repair request",
                                        color: .green
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            showCustomerSelection = true
                                        }
                                    }
                                    
                                    ActionCard(
                                        title: "Contact Us",
                                        iconName: "phone.circle.fill",
                                        description: "Get in touch",
                                        color: .orange
                                    ) {
                                        showContactSheet = true
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(UIColor.systemBackground).opacity(0.95))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                    }
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .statusCheck:
                    TicketTrackerView()
                case .newRepair:
                    SubmitCustomerInfoView()
                case .existingCustomer:
                    ExistingCustomerView()
                case .quickQuote:
                    QuickQuoteView()
                case .contact:
                    ContactView()
                }
            }
        }
        .sheet(isPresented: $showContactSheet) {
            ContactOptionsSheet()
        }.preferredColorScheme(.light)
    }
}


struct ActionCard: View {
    let title: String
    let iconName: String
    let description: String
    let color: Color
    var action: (() -> Void)? = nil
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action?()
            }
        }) {
            VStack(spacing: 16) {
                // Icon with background
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: iconName)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(color)
                    )
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(
                color: color.opacity(0.1),
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
            .scaleEffect(isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
// Contact Options Sheet
struct ContactOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    if let phoneURL = URL(string: "tel:1234567890") {
                        UIApplication.shared.open(phoneURL)
                    }
                } label: {
                    Label("Call Us", systemImage: "phone.fill")
                }
                
                Button {
                    if let emailURL = URL(string: "mailto:support@nych.com") {
                        UIApplication.shared.open(emailURL)
                    }
                } label: {
                    Label("Email Us", systemImage: "envelope.fill")
                }
                
                // Add more contact options as needed
            }
            .navigationTitle("Contact Us")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// We need to create these views:
struct QuickQuoteView: View {
    var body: some View {
        Text("Quick Quote View - Coming Soon")
    }
}

struct ContactView: View {
    var body: some View {
        Text("Contact View - Coming Soon")
    }
}


struct RecentActivityList: View {
    let activities: [CustomerInformation]
    
    var body: some View {
        ForEach(activities) { activity in
            HStack {
                VStack(alignment: .leading) {
                    Text("Repair #\(activity.customerID)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(activity.timestamp.formatted())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            
            if activity.id != activities.last?.id {
                Divider()
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.circle")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No recent activity")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Your recent repair requests will appear here")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}
#Preview {
    ContentView()
        .modelContainer(for: CustomerInformation.self, inMemory: true)
}


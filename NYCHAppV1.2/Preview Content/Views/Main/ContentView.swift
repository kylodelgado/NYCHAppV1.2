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
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var customerInfo: [CustomerInformation]
    @State private var navigationPath = NavigationPath()
    @State private var showContactSheet = false  // For contact options
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                GradientBackground()
                
                VStack(spacing: 25) {
                    // Company Logo
                    Image("nychlogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                        .padding(.top, 20)
                    
                    // Quick Actions Section
                    VStack(spacing: 16) {
                        Text("Quick Actions")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        // Primary Actions Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            // Status Check Button
                            ActionCard(
                                title: "Check Status",
                                iconName: "magnifyingglass.circle.fill",
                                description: "Track repair progress",
                                color: .blue
                            ) {
                                navigationPath.append(Route.statusCheck)
                            }
                            
                            // New Repair Button
                            ActionCard(
                                title: "New Repair",
                                iconName: "wrench.and.screwdriver.fill",
                                description: "Start repair request",
                                color: .green
                            ) {
                                navigationPath.append(Route.newRepair)
                            }
                            
                            // Quick Quote Button
                            ActionCard(
                                title: "Quick Quote",
                                iconName: "dollarsign.circle.fill",
                                description: "Get price estimate",
                                color: .purple
                            ) {
                                navigationPath.append(Route.quickQuote)
                            }
                            
                            // Contact Button
                            ActionCard(
                                title: "Contact Us",
                                iconName: "phone.circle.fill",
                                description: "Get in touch",
                                color: .orange
                            ) {
                                showContactSheet = true
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
                    VStack(alignment: .leading, spacing: 16) {
                                            Text("Recent Activity")
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                            
                                            if customerInfo.isEmpty {
                                                EmptyStateView()
                                            } else {
                                                RecentActivityList(activities: customerInfo)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                        )
                                        .padding(.horizontal)
                                        
                                        Spacer()
                                    
                }
            }
            .navigationTitle("Welcome")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .statusCheck:
                    StatusCheckView()
                case .newRepair:
                    SubmitCustomerInfoView()
                case .quickQuote:
                    QuickQuoteView() // We'll need to create this
                case .contact:
                    ContactView() // We'll need to create this
                }
            }
            .sheet(isPresented: $showContactSheet) {
                ContactOptionsSheet() // We'll create this
            }.preferredColorScheme(.light)
        }
    }
}

struct ActionCard: View {
    let title: String
    let iconName: String
    let description: String
    let color: Color
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: color.opacity(0.2), radius: 5, x: 0, y: 2)
        )
        .onTapGesture {
            if let action = action {
                action()
            }
        }
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
}


//
//  StatusCheckView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/11/24.
//

import SwiftUI

struct StatusCheckView: View {
    
    @State private var animate = false
  
    @State var checkTicket = ""
    @State var pressingButton = false
    @State private var navigateToDetails = false // State variable to control navigation
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        animate ? Color(red: 0.85, green: 0.9, blue: 1.0).opacity(0.3) : Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.3),
                        animate ? Color(red: 0.92, green: 0.85, blue: 1.0).opacity(0.3) : Color(red: 0.7, green: 0.6, blue: 0.8).opacity(0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)
                
                VStack {
                    CustomTextField(text: $checkTicket, topText: "Check Ticket By")
  
                    Button {
                        Task {
                            do {
                                let ticket = try await fetchAndDecodeTicketDetails(byTickerNumber: checkTicket)
                                print("Ticket details: \(ticket.tickets[0])")
                                navigateToDetails = true // Trigger navigation after successful fetch
                            } catch {
                                print("Failed to fetch ticket details: \(error)")
                            }
                        }
                    } label: {
                        ButtonView(textToShow: "Check Status", imageToShow: "status", frameWidth: 380, frameHeight: 180)
                    }
//                    
//                    .navigationDestination(isPresented: $navigateToDetails) {
//                        MainTicketView()
//                            .navigationBarBackButtonHidden(true)
//                    }

//                    
//                    Image("nychlogo")
//                        .resizable()
//                        .scaledToFit()
//                        .opacity(0.5)
                }
            }
            .onAppear {
                // Start the animation when the view appears
                animate.toggle()
            }
            .navigationTitle("Hi There")
        } .preferredColorScheme(.light)
    }
}
    

#Preview {
    StatusCheckView()
}




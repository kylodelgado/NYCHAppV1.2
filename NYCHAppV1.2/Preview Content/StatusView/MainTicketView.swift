//
//  MainTicketView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/11/24.
//

import SwiftUI

struct MainTicketView: View {
    @State private var animate = false // State variable to toggle animation
    @State var checkTicketBy = "Ticket Number"
    @State var checkOptions = ["Ticket Number", "Name", "Phone Number"]
    @State var checkTicket = "44000"
    @State var pressingButton = false
    
    @State var ticketNumber = "40873"
    @State var subject = "Custom PC - Restart On Own + Fans Run At High Speed"
    @State var customerName = "David Lora"
    @State var status = "Awaiting Payment"
    @State var dueDate = "May 17, 2024"
    @State var location = "New York Computer Help - Midtown"
    @State var deviceType = "Custom PC"
    @State var problemType = "Fans running at high speed"
    @State var billingStatus = "Invoiced"
    @State var accessories = "Power adapter"

    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        animate ? Color(red: 0.85, green: 0.9, blue: 1.0) : Color(red: 0.6, green: 0.7, blue: 0.9),
                        animate ? Color(red: 0.92, green: 0.85, blue: 1.0) : Color(red: 0.7, green: 0.6, blue: 0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration:15).repeatForever(autoreverses: true), value: animate)
                

                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .frame(width: 300, height: 380)
                            .padding()
                            .overlay{
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(lineWidth: 2)
                                    .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                         Color(red: 0.85, green: 0.9, blue: 1.0),Color(red: 0.6, green: 0.7, blue: 0.9),
                                        Color(red: 0.92, green: 0.85, blue: 1.0), Color(red: 0.7, green: 0.6, blue: 0.8)
                                    ]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    
                                    .frame(width: 300, height: 380)
                                
                            }
                        VStack {
                            
                            
                            
                            
                        
                        
                        
                        }
                   
                   
                    
                }
                .onAppear {
                    // Start the animation when the view appears
                    animate.toggle()
                }
                .navigationTitle("Hi \(customerName.split(separator: " ").first.map(String.init) ?? "")!")
            
        } .preferredColorScheme(.light)
    }
}

#Preview {
    MainTicketView()
}

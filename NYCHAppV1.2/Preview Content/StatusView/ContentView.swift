//
//  ContentView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/7/24.
//

import SwiftUI

struct ContentView: View {
    @State private var animate = false
    @State var newTicketView = false
    @State var goToCustomerForm = false

    var body: some View {
            NavigationStack {
                ZStack {
                   
                        
                        
                        // Background with animated gradient
                        LinearGradient(
                            gradient: Gradient(colors: [
                                animate ? Color(red: 0.85, green: 0.9, blue: 1.0).opacity(0.3) : Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.3),
                                animate ? Color(red: 0.92, green: 0.85, blue: 1.0).opacity(0.3) : Color(red: 0.7, green: 0.6, blue: 0.8).opacity(0.4)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .edgesIgnoringSafeArea(.all)
                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animate)
                        
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial.quaternary)
                            .frame(width: 380, height: 700)
                            .padding()
                            .overlay{
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(lineWidth: 4)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.85, green: 0.9, blue: 1.0),Color(red: 0.6, green: 0.7, blue: 0.9),
                                            Color(red: 0.92, green: 0.85, blue: 1.0), Color(red: 0.7, green: 0.6, blue: 0.8)
                                        ]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                
                                    .frame(width: 380, height: 700)
                                
                            }
                    
                    VStack(spacing: 20) {
                        // Rows of buttons
                        HStack(spacing: 20) {
                            NavigationLink {
                                
                                StatusCheckView()
                                
                                   
                            } label: {
                                ButtonView(textToShow: "Check Status", imageToShow: "status")
                            }
                            
                            Button {
                                newTicketView.toggle()
                               
                            } label: {
                                ButtonView(textToShow: "Diagnostics", imageToShow: "diag")
                                
                            } .navigationDestination(isPresented: $newTicketView){
                                SubmitCustomerInfoView()
                            }
                        }
                        
                        HStack(spacing: 20) {
                            Button {
                                print("Data Recovery Button Tapped")
                            } label: {
                                ButtonView(textToShow: "", imageToShow: "hd")
                            }
                            
                            Button {
                                print("On Site Visit Button Tapped")
                            } label: {
                                ButtonView(textToShow: "", imageToShow: "")
                            }
                        }
                        
                        HStack(spacing: 20) {
                            Button {
                                print("Protection Plan Button Tapped")
                            } label: {
                                ButtonView(textToShow: "Protection Plan", imageToShow: "shield")
                            }
                            
                            Button {
                                print("Contact Us Button Tapped")
                            } label: {
                                ButtonView(textToShow: "Contact Us", imageToShow: "contact")
                            }
                        }
                        
                        // Logo
//                        Image("nychlogo")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 100)
//                            .opacity(0.8)
//                            .padding(.top, 20)
                    }
                    .padding()
                }
                .navigationTitle("Hi There")
                .onAppear {
                                // Trigger the animation when the view appears
                                animate.toggle()
                            }
            } .preferredColorScheme(.light)
        }
    }
#Preview {
    ContentView()
}



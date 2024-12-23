////
////  LandingView.swift
////  NYCHAppV1.2
////
////  Created by Brandon Delgado on 12/11/24.
////
//
//import SwiftUI
//
//struct LandingView: View {
//    @State private var animate = false
//    @State var isPressed: Bool = false
//    var body: some View {
//            NavigationStack {
//                ZStack {
//                    // Background with animated gradient
//                    LinearGradient(
//                            gradient: Gradient(colors: animate ?
//                                [Color(red: 0.85, green: 0.9, blue: 1.0), Color(red: 0.92, green: 0.85, blue: 1.0)] :
//                                [Color(red: 0.6, green: 0.7, blue: 0.9), Color(red: 0.7, green: 0.6, blue: 0.8)]
//                            ),
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                        .edgesIgnoringSafeArea(.all)
//                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animate)
//                        
//                    VStack(spacing: 20) {
//                        // Rows of buttons
//                        HStack(spacing: 20) {
//                            NavigationLink {
//                                StatusCheckView()
//                                   
//                                
//                            } label: {
//                                ButtonView(textToShow: "Check Status", imageToShow: "status", isPressed: isPressed)
//                            }
//                            
//                            Button {
//                                print("Diagnostics Button Tapped")
//                                isPressed.toggle()
//                            } label: {
//                                ButtonView(textToShow: "Diagnostics", imageToShow: "diag", isPressed: isPressed)
//                            }
//                        }
//                        
//                        HStack(spacing: 20) {
//                            Button {
//                                print("Data Recovery Button Tapped")
//                            } label: {
//                                ButtonView(textToShow: "Data Recovery", imageToShow: "hdd")
//                            }
//                            
//                            Button {
//                                print("On Site Visit Button Tapped")
//                            } label: {
//                                ButtonView(textToShow: "On Site Visit", imageToShow: "onsite")
//                            }
//                        }
//                        
//                        HStack(spacing: 20) {
//                            Button {
//                                print("Protection Plan Button Tapped")
//                            } label: {
//                                ButtonView(textToShow: "Protection Plan", imageToShow: "shield")
//                            }
//                            
//                            Button {
//                                print("Contact Us Button Tapped")
//                            } label: {
//                                ButtonView(textToShow: "Contact Us", imageToShow: "contact")
//                            }
//                        }
//                        
//                        // Logo
//                        Image("nychlogo")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 100)
//                            .opacity(0.5)
//                            .padding(.top, 20)
//                    }
//                    .padding()
//                }
//                .navigationTitle("Hi There")
//                .onAppear {
//                                // Trigger the animation when the view appears
//                                animate.toggle()
//                            }
//            }
//        }
//    }
//#Preview {
//    LandingView()
//}
//
//

//
//  LandingView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/11/24.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        NavigationStack{

        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.85, green: 0.9, blue: 1.0), Color(red: 0.92, green: 0.85, blue: 1.0)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                
                HStack {
                    NavigationLink {
                        Text("Hello")
                    } label: {
                        ButtonView(textToShow: "Check Status", imageToShow: "status")
                    }
                    
                    Button {
                        
                    } label: {
                        ButtonView(textToShow: "Diagnostics", imageToShow: "diag")
                    }
                    
                    
                }
                HStack {
                    Button {
                        
                    } label: {
                        ButtonView(textToShow: "Data Recovery", imageToShow: "hdd")
                    }
                    Button {
                        
                    } label: {
                        ButtonView(textToShow: "On Site Visit", imageToShow: "onsite")
                    }
                    
                    
                }
                HStack {
                    Button {
                        
                    } label: {
                        ButtonView(textToShow: "Protection Plan", imageToShow: "shield")
                    }
                    Button {
                        
                    } label: {
                        ButtonView(textToShow: "Contact Us", imageToShow: "contact")
                    }
                    
                    
                }
                Image("nychlogo")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.5)
            }
        }
        .navigationTitle("Hi There")
    }
        
    }
}

#Preview {
    LandingView()
}


struct ButtonView: View {
    @State var textToShow: String = "Repair Status"
    @State var imageToShow = "desktop"
    
    var body: some View {
        ZStack {
            // Background for 3D effect
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.5), radius: 6, x: 4, y: 4) // Shadow for depth
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black.opacity(0.3), lineWidth: 3)
                        .blur(radius: 1) // Creates a subtle bevel effect
                )
                .frame(width: 140, height: 140)

            // Content
            VStack {
                Image(imageToShow)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60) // Adjust for better alignment
                    .opacity(0.6)
                Text(textToShow)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        } .padding(9)
    }
}


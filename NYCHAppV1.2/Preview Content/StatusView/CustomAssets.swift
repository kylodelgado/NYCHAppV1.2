//
//  CustomAssets.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/11/24.
//

import SwiftUI

struct CustomAssets: View {
    var body: some View {
        NewButton()
    }
}



#Preview {
    CustomAssets()
}


struct NewButton: View {
    @State var textToShow: String = "Repair Status"
 
  
    
    var body: some View {
        

            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.blue.opacity(0.6).gradient)
                    .shadow(color: .blue.opacity(0.5), radius: 6, x: 0, y: 7)
                    
                    .frame(height: 50)
                    
                    .containerRelativeFrame(.horizontal) { width, axis in
                        width * 0.95
                    }
                Text(textToShow)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        
    }
}





struct ButtonView: View {
    @State  var textToShow: String = "Repair Status"
    @State  var imageToShow = "desktop"
    @State private var gradientColors = [Color.blue.opacity(0.3), Color.white.opacity(0.1)]
    @State private var animateGradient = false // State for color animation
    @State var frameWidth = 150.0
    @State var frameHeight = 150.0
    
    var body: some View {
        ZStack {
            ZStack {
                
                
                // Background for 3D effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 6, x: 4, y: 4) // Shadow for depth
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    )
                    .overlay{
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 1)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.85, green: 0.9, blue: 1.0),Color(red: 0.6, green: 0.7, blue: 0.9),
                                    Color(red: 0.92, green: 0.85, blue: 1.0), Color(red: 0.7, green: 0.6, blue: 0.8)
                                ]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        
                        
                        
                    }
            }
            .frame(width: 150, height: 150)
            .onAppear {
                // Start the gradient color animation
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    gradientColors = [.white, .black.opacity(0.1)]
                }
            }
                // Size animation
               

            // Content
            VStack {
                Image(imageToShow)
                    .resizable()
                    .scaledToFit()
                    .frame(width: (frameWidth / 5) * 2, height: (frameHeight / 5) * 2) // Adjust for better alignment
                    .opacity(0.6)
                Text(textToShow)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        } .preferredColorScheme(.light)
        .padding(9)
  
    }
}


struct CustomPickerView: View {
    @Binding var selectedOption: String
    let options = [
        ("Ticket Number", "number"),
        ("Name", "person.fill"),
        ("Phone Number", "phone.fill")
    ]

    var body: some View {
        HStack {
            ForEach(options, id: \.0) { option in
                Button(action: {
                    selectedOption = option.0
                    
                }) {
                    VStack {
                        Image(systemName: option.1)
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text(option.0)
                            .font(.caption)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedOption == option.0 ? Color.blue.opacity(0.5) : Color.gray.opacity(0.2))
                    )
                    .foregroundColor(selectedOption == option.0 ? .white : .black)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct CustomTextField: View {
    @Binding var text: String
    @State var topText: String
    @State private var animateGradient = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(topText)
                .font(.caption)
                .foregroundColor(.gray)
                .offset(y: 5)
                .padding(.horizontal)
            
            TextField("", text: $text)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 2)
                        .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            animateGradient ? Color(red: 0.85, green: 0.9, blue: 1.0) : Color(red: 0.6, green: 0.7, blue: 0.9),
                            Color(red: 0.92, green: 0.85, blue: 1.0), Color(red: 0.7, green: 0.6, blue: 0.8)
                        ]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        
                )
                .padding(.horizontal)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}


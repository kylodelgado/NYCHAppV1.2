//
//  TestViews.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/11/24.
//

import SwiftUI

struct TestViews: View {
    @State var textToShow: String = "Repair Status"
    @State var imageToShow = "desktop"
    
    var body: some View {
        ZStack {
            // Background for 3D effect
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
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
                .frame(width: 120, height: 120)

            // Content
            VStack {
                Image(imageToShow)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60) // Adjust for better alignment
                Text(textToShow)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    TestViews()
}

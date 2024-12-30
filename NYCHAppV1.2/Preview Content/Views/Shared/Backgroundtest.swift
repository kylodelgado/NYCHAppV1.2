//
//  Backgroundtest.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftUI

struct Backgroundtest: View {
    
    var body: some View {
        ZStack {
            
            
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color(.systemGray6),  // Very light gray
                        Color(.systemBackground),  // System background (usually white)
                        Color(.systemGray6)   // Very light gray
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            //            .overlay(
            //                // Top border gradient
            //                VStack {
            //                    LinearGradient(
            //                        gradient: Gradient(
            //                            colors: [
            //                                Color.blue.opacity(0.7),
            //                                Color.blue.opacity(0.5)
            //                            ]
            //                        ),
            //                        startPoint: .leading,
            //                        endPoint: .trailing
            //                    )
            //                    .frame(height: 4)
            //                    Spacer()
            //                }
            //            )
            //            .ignoresSafeArea()
        }
    }
}

    #Preview {
        ZStack {
            GradientBackground()
            Text("Test Content")
                .font(.title)
        }
    }
#Preview {
    Backgroundtest()
}

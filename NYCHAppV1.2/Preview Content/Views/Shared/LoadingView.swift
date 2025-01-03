//
//  LoadingView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.95, blue: 0.97)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.black)
                
                Text("Loading...")
                    .foregroundColor(.black.opacity(0.5))
                    .font(.headline)
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
    }
}

#Preview {
    LoadingView()
}

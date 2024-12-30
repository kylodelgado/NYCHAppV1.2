//
//  GradientBackground.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftUI

struct GradientBackground: View {
    var body: some View {
        Color(red: 0.93, green: 0.95, blue: 0.97) // #EBEBEB
                  .ignoresSafeArea()
    }
}
#Preview {
    ZStack {
        GradientBackground()
        Text("Test Content")
            .font(.title)
    }
}

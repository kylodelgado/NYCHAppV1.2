//
//  ProgressBar.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/7/24.
//

import SwiftUI

struct ProgressBar: View {
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.blue)
                    .opacity(1)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2)
                            .fill(.ultraThickMaterial)
                    }

                HStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                        .containerRelativeFrame(.horizontal) { width, axis in
                            width * 0.7
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("In Progress")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .containerRelativeFrame(.horizontal) { width, axis in
                width * 0.9
            }
            .containerRelativeFrame(.vertical) { height, axis in
                height * 0.03
            }
        }
    }
}

#Preview {
    ProgressBar()
}

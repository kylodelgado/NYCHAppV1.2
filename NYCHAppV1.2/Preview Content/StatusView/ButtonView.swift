////
////  ButtonView.swift
////  NYCHAppV1.2
////
////  Created by Brandon Delgado on 12/11/24.
////
//
//
//struct ButtonView: View {
//    @State var textToShow: String = "Repair Status"
//    @State var imageToShow = "desktop"
//    @State private var isPressed = false // State for button tap animation
//    @State private var gradientColors = [Color.blue.opacity(0.3), Color.white.opacity(0.1)]
//    @State private var animateGradient = false // State for color animation
//    @State var frameSize = 150.0
//    @State private var isAnimatingLabel = false // State for label animation
//
//    var body: some View {
//        ZStack {
//            // Background for 3D effect
//            RoundedRectangle(cornerRadius: 20)
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(colors: gradientColors),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .shadow(color: .black.opacity(0.5), radius: 6, x: 4, y: 4) // Shadow for depth
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color.black.opacity(0.3), lineWidth: 3)
//                        .blur(radius: 1) // Creates a subtle bevel effect
//                )
//                .frame(width: frameSize, height: frameSize) // Size animation
//                .onTapGesture {
//                    // Animate button press
//                    withAnimation(.easeInOut(duration: 0.2)) {
//                        isAnimatingLabel.toggle()
//                    }
//                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            isAnimatingLabel.toggle()
//                        }
//                    }
//                }
//
//            // Content
//            VStack {
//                Image(imageToShow)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 60, height: 60) // Adjust for better alignment
//                    .opacity(0.6)
//                Text(textToShow)
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .scaleEffect(isAnimatingLabel ? 1.2 : 1.0) // Label scale animation
//                    .foregroundColor(isAnimatingLabel ? .yellow : .white) // Label color change
//            }
//        }
//        .padding(9)
//        .onAppear {
//            // Start the gradient color animation
//            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
//                gradientColors = [.white, .black.opacity(0.1)]
//            }
//        }
//    }
//}

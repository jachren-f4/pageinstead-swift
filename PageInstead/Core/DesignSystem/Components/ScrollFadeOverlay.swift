//
//  ScrollFadeOverlay.swift
//  PageInstead
//
//  Created by Claude on 2025-01-03.
//  Gradient overlay that fades scrolling content behind headers
//

import SwiftUI

/// A gradient overlay that fades scrolling content behind the top of the screen
/// Uses the "Strong" variant (150px height) with pronounced fade effect
struct ScrollFadeOverlay: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 26/255, green: 0, blue: 51/255).opacity(1.0), location: 0.0),
                .init(color: Color(red: 26/255, green: 0, blue: 51/255).opacity(1.0), location: 0.2),
                .init(color: Color(red: 26/255, green: 0, blue: 51/255).opacity(0.85), location: 0.4),
                .init(color: Color(red: 26/255, green: 0, blue: 51/255).opacity(0.5), location: 0.6),
                .init(color: Color(red: 26/255, green: 0, blue: 51/255).opacity(0.15), location: 0.8),
                .init(color: Color(red: 26/255, green: 0, blue: 51/255).opacity(0.0), location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 150)
        .allowsHitTesting(false) // Allow tap events to pass through
    }
}

/// View modifier to add scroll fade overlay to any view
struct ScrollFadeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                ScrollFadeOverlay()
                    .ignoresSafeArea(edges: .top)
            }
    }
}

extension View {
    /// Adds a gradient fade overlay at the top of the view that fades scrolling content
    func scrollFadeOverlay() -> some View {
        modifier(ScrollFadeModifier())
    }
}

#Preview {
    ZStack {
        // Background matching the app's gradient
        AnimatedGradientBackground()

        ScrollView {
            VStack(spacing: 16) {
                ForEach(1...10, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Card \(index)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("This is sample content to demonstrate the scroll fade effect. As you scroll up, content will gradually fade behind the gradient overlay.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .liquidGlassCard()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 100)
            .padding(.bottom, 40)
        }
        .scrollFadeOverlay()

        // Header overlay
        VStack {
            HStack {
                Text("Preview")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            Spacer()
        }
    }
}

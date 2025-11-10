import SwiftUI

struct FairUseAttributionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                AnimatedGradientBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Top spacing
                        Spacer()
                            .frame(height: 20)

                        // Header - scrollable
                        Text("Fair Use & Attribution")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        // Card 1: Our Fair Use Statement
                        GlassCard(standard: {
                            VStack(spacing: 16) {
                                Text("Our Fair Use Statement")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("PageInstead uses short book excerpts to help you break free from digital distractions and discover inspiring ideas. We believe this falls under fair use because:")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)

                                    Text("• We use brief quotes (typically 1-3 sentences) from much longer works")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)

                                    Text("• Our purpose is transformative—we're not republishing books, we're using quotes as a tool for behavior change and book discovery")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)

                                    Text("• We provide full attribution and direct links to purchase each book")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)

                                    Text("• We help authors by driving readers to discover and buy their books")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)
                                }
                            }
                        })
                        .padding(.horizontal)

                        // Card 2: How We Attribute
                        GlassCard(standard: {
                            VStack(spacing: 16) {
                                Text("How We Attribute")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Every quote in PageInstead includes complete attribution:")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)

                                    Text("• Author name and book title")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)

                                    Text("• Book cover image")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)

                                    Text("• Direct link to purchase on Amazon")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)

                                    Text("• Book category and description")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)

                                    // Stats badge
                                    HStack {
                                        Text("292 quotes • 147 books")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.95))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.3))

                                                    RoundedRectangle(cornerRadius: 16)
                                                        .strokeBorder(Color(red: 196/255, green: 181/255, blue: 253/255).opacity(0.4), lineWidth: 1)
                                                }
                                            )
                                        Spacer()
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        })
                        .padding(.horizontal)

                        // Card 3: For Authors & Publishers
                        GlassCard(standard: {
                            VStack(spacing: 16) {
                                Text("For Authors & Publishers")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("We believe PageInstead promotes reading culture and drives book sales. However, we respect your rights as a creator.")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)

                                    Group {
                                        Text("If you're an author or publisher with concerns about how we've used your work, please contact us at ")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white.opacity(0.85))
                                        + Text("support@pageinstead.com")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(red: 96/255, green: 165/255, blue: 250/255))
                                    }
                                    .lineSpacing(8)

                                    Text("We're happy to:")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)
                                        .padding(.top, 4)

                                    Text("• Remove specific quotes upon request")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)

                                    Text("• Discuss any attribution concerns")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)

                                    Text("• Explore partnership opportunities")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineSpacing(8)
                                }
                            }
                        })
                        .padding(.horizontal)

                        Spacer(minLength: 120)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    FairUseAttributionView()
}

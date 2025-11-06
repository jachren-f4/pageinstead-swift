import SwiftUI

// MARK: - Preference Key for Anchor Tracking

struct TutorialAnchorKey: PreferenceKey {
    static var defaultValue: [String: CGPoint] = [:]

    static func reduce(value: inout [String: CGPoint], nextValue: () -> [String: CGPoint]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - View Extension

extension View {
    /// Marks this view for tutorial highlighting by tracking its center point
    func tutorialAnchor(id: String) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: TutorialAnchorKey.self,
                    value: [id: CGPoint(
                        x: geometry.frame(in: .global).midX,
                        y: geometry.frame(in: .global).midY
                    )]
                )
            }
        )
    }
}

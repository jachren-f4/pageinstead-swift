import SwiftUI

/// Arrow pointer for tooltips using rotated rectangle approach
struct TooltipArrow: View {
    enum Direction {
        case up, down
    }

    let direction: Direction
    let color: Color
    let size: CGFloat

    init(direction: Direction, color: Color = Color.white.opacity(0.12), size: CGFloat = 12) {
        self.direction = direction
        self.color = color
        self.size = size
    }

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(45))
            .offset(y: direction == .up ? size / 2 : -size / 2)
    }
}

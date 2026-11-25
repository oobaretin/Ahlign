import SwiftUI

struct RepetitionProgressRing: View {
    let current: Int
    let total: Int
    let color: Color

    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(current) / CGFloat(total)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(current)/\(total)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(width: 44, height: 44)
        .accessibilityLabel("Repetition \(current) of \(total)")
    }
}
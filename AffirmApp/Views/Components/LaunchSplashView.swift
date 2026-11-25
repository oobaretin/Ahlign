import SwiftUI

struct LaunchSplashView: View {
    @State private var pulse = 0.4

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Ahlign")
                    .font(DesignTokens.Typography.screenTitle)
                    .foregroundStyle(.white)
                Text("Root → Crown")
                    .font(DesignTokens.Typography.subhead)
                    .foregroundStyle(.white.opacity(0.5))
                Circle()
                    .fill(DesignTokens.accentPurple.opacity(pulse))
                    .frame(width: 10, height: 10)
                    .shadow(color: DesignTokens.accentPurple.opacity(pulse), radius: 12)
            }
        }
        .onAppear {
            guard !UIAccessibility.isReduceMotionEnabled else {
                pulse = 0.8
                return
            }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                pulse = 1
            }
        }
        .preferredColorScheme(.dark)
    }
}
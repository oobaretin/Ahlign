import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    var onComplete: () -> Void

    private let pages: [(title: String, body: String, icon: String, showFigure: Bool)] = [
        ("Listen", "A calm voice guides each affirmation from Root to Crown.", "waveform", false),
        ("Glow", "Each center pulses with every repetition, then holds steady as you rise.", "sparkles", true),
        ("Ready", "Defaults are set. You can customize affirmations anytime in Settings.", "figure.mind.and.body", false),
    ]

    @State private var page = 0
    @State private var figurePulse = 0.55

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [.purple.opacity(0.2), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: DesignTokens.sectionSpacing) {
                Spacer()

                if pages[page].showFigure {
                    MeditationFigureView(
                        activeStep: .root,
                        lockedIDs: [],
                        pulseScale: 1,
                        pulseGlow: figurePulse,
                        showAllLocked: false,
                        style: .homePreview
                    )
                    .frame(height: 280)
                    .padding(.horizontal, DesignTokens.horizontalPadding)
                    .onAppear { startFigureBreathing() }
                } else {
                    Image(systemName: pages[page].icon)
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(DesignTokens.accentPurple)
                        .symbolEffect(.pulse, options: .repeating)
                }

                Text(pages[page].title)
                    .font(DesignTokens.Typography.screenTitle)
                    .foregroundStyle(.white)

                Text(pages[page].body)
                    .font(DesignTokens.Typography.subhead)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.72))
                    .padding(.horizontal, 32)

                HStack(spacing: 8) {
                    ForEach(0 ..< pages.count, id: \.self) { i in
                        Circle()
                            .fill(i == page ? Color.white : Color.white.opacity(0.25))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 8)

                Spacer()

                Button {
                    if page < pages.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        OnboardingStore.markSeen()
                        onComplete()
                        isPresented = false
                    }
                } label: {
                    Text(page == pages.count - 1 ? "I'm ready" : "Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignTokens.accentPurple)
                .padding(.horizontal, DesignTokens.buttonHorizontalPadding)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func startFigureBreathing() {
        guard !UIAccessibility.isReduceMotionEnabled else {
            figurePulse = 0.7
            return
        }
        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
            figurePulse = 0.9
        }
    }
}

enum OnboardingStore {
    private static let key = "hasSeenOnboarding"

    static var shouldShow: Bool {
        !UserDefaults.standard.bool(forKey: key)
    }

    static func markSeen() {
        UserDefaults.standard.set(true, forKey: key)
    }
}
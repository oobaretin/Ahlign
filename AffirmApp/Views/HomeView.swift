import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @StateObject private var viewModel = SessionViewModel()
    @State private var showSession = false
    @State private var showPaywall = false
    @State private var showOnboarding = OnboardingStore.shouldShow
    @State private var showSplash = !OnboardingStore.shouldShow
    @State private var homePulse = 0.65
    @State private var isEnteringJourney = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                LinearGradient(
                    colors: [.purple.opacity(0.15), .black, .pink.opacity(0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                mainContent
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    LaunchSplashView()
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
            .fullScreenCover(isPresented: $showSession) {
                MeditationPlayerView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(isPresented: $showOnboarding, onComplete: {
                    if !subscriptions.hasPremiumAccess {
                        showPaywall = true
                    }
                })
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(subscriptions: subscriptions)
            }
            .onChange(of: subscriptions.hasPremiumAccess) { _, hasAccess in
                viewModel.hasPremiumAccess = hasAccess
            }
            .onAppear {
                viewModel.hasPremiumAccess = subscriptions.hasPremiumAccess
                if showSplash {
                    Task {
                        try? await Task.sleep(for: .milliseconds(1400))
                        withAnimation(.easeOut(duration: 0.45)) {
                            showSplash = false
                        }
                    }
                }
                startHomeBreathing()
            }
        }
    }

    private var mainContent: some View {
        VStack(spacing: DesignTokens.sectionSpacing) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ahlign")
                        .font(DesignTokens.Typography.screenTitle)
                        .foregroundStyle(.white)
                    Text("Root → Crown · ~\(viewModel.estimatedMinutes) min")
                        .font(DesignTokens.Typography.subhead)
                        .foregroundStyle(.white.opacity(0.55))
                }
                Spacer()
                NavigationLink {
                    SettingsView(viewModel: viewModel)
                } label: {
                    Image(systemName: "gearshape")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white.opacity(0.75))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Settings")
                .disabled(isEnteringJourney)
            }
            .padding(.horizontal, DesignTokens.horizontalPadding)
            .padding(.top, 16)

            if viewModel.stats.completedJourneys > 0 {
                Text("Journeys completed: \(viewModel.stats.completedJourneys)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }

            MeditationFigureView(
                activeStep: .root,
                lockedIDs: [],
                pulseScale: isEnteringJourney ? 1.06 : 1,
                pulseGlow: homePulse,
                showAllLocked: false,
                style: .homePreview
            )
            .frame(height: 420)
            .padding(.horizontal, DesignTokens.horizontalPadding)
            .scaleEffect(isEnteringJourney ? 1.02 : 1)
            .animation(.easeInOut(duration: 0.85), value: isEnteringJourney)

            Text(sessionSummary)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, DesignTokens.horizontalPadding)

            Button {
                beginJourney()
            } label: {
                Text(isEnteringJourney ? "Starting…" : "Begin journey")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignTokens.accentPurple)
            .padding(.horizontal, DesignTokens.buttonHorizontalPadding)
            .disabled(isEnteringJourney)

            NavigationLink {
                SetupView(viewModel: viewModel)
            } label: {
                Text("Customize affirmations")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .disabled(isEnteringJourney)
            .padding(.bottom, 24)

            Spacer(minLength: 0)
        }
    }

    private func beginJourney() {
        guard !isEnteringJourney else { return }
        viewModel.hasPremiumAccess = subscriptions.hasPremiumAccess
        guard subscriptions.hasPremiumAccess else {
            showPaywall = true
            return
        }
        isEnteringJourney = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if !UIAccessibility.isReduceMotionEnabled {
            withAnimation(.easeInOut(duration: 0.9)) {
                homePulse = 1
            }
        }

        Task {
            try? await Task.sleep(for: .milliseconds(1300))
            viewModel.startSession()
            showSession = true
            isEnteringJourney = false
            startHomeBreathing()
        }
    }

    private var sessionSummary: String {
        let first = viewModel.configuration(for: .root).affirmation.english
        let last = viewModel.configuration(for: .crown).affirmation.english
        return "\(first) → … → \(last)"
    }

    private func startHomeBreathing() {
        guard !UIAccessibility.isReduceMotionEnabled else {
            homePulse = 0.6
            return
        }
        withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
            homePulse = 0.82
        }
    }
}
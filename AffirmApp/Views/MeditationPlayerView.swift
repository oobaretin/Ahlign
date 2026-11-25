import SwiftUI

struct MeditationPlayerView: View {
    @ObservedObject var viewModel: SessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEndConfirm = false
    @State private var preparePulse: CGFloat = 0.45

    private var config: ChakraConfiguration {
        viewModel.configuration(for: viewModel.currentStep)
    }

    var body: some View {
        NavigationStack {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.showCompletion {
                CompletionView(viewModel: viewModel)
            } else if viewModel.isPreparing {
                preparingOverlay
            } else {
                sessionContent
            }

            if let banner = viewModel.statusBanner, !viewModel.isPreparing {
                VStack {
                    Text(banner)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.top, 56)
                    Spacer()
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
        }
    }

    private var preparingOverlay: some View {
        VStack(spacing: 24) {
            MeditationFigureView(
                activeStep: .root,
                lockedIDs: [],
                pulseScale: 1.08,
                pulseGlow: preparePulse,
                showAllLocked: false,
                style: .seated
            )
            .frame(maxHeight: 380)
            .padding(.horizontal, DesignTokens.horizontalPadding)
            .onAppear { startPrepareBreathing() }

            Text("Settle in…")
                .font(DesignTokens.Typography.subhead)
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func startPrepareBreathing() {
        guard !UIAccessibility.isReduceMotionEnabled else {
            preparePulse = 0.85
            return
        }
        withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
            preparePulse = 1
        }
    }

    private var sessionContent: some View {
        VStack(spacing: 12) {
            HStack {
                progressDots
                Spacer()
                RepetitionProgressRing(
                    current: viewModel.currentRepetition,
                    total: max(1, config.repetitionCount),
                    color: viewModel.currentStep.color
                )
            }
            .padding(.horizontal, DesignTokens.horizontalPadding)
            .padding(.top, 8)

            Text("\(viewModel.currentStep.rawValue) · \(viewModel.currentStep.headerPhrase)")
                .font(DesignTokens.Typography.sessionPhase)
                .foregroundStyle(viewModel.currentStep.color)

            MeditationFigureView(
                activeStep: viewModel.currentStep,
                lockedIDs: viewModel.lockedChakraIDs,
                pulseScale: viewModel.pulseScale,
                pulseGlow: viewModel.pulseGlow,
                showAllLocked: false
            )
            .frame(maxHeight: 410)
            .padding(.horizontal, DesignTokens.horizontalPadding)
            .contentShape(Rectangle())
            .onTapGesture {
                if viewModel.settings.tapToAdvance {
                    viewModel.advanceToNextRepetition()
                }
            }
            .accessibilityHint(viewModel.settings.tapToAdvance ? "Double tap to advance repetition" : "")

            Text(config.affirmation.english)
                .font(DesignTokens.Typography.affirmation)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.horizontal, DesignTokens.horizontalPadding)

            Spacer()

            HStack(spacing: 16) {
                Button {
                    viewModel.togglePause()
                } label: {
                    Label(
                        viewModel.isPaused ? "Resume" : "Pause",
                        systemImage: viewModel.isPaused ? "play.fill" : "pause.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignTokens.accentPurple)

                if viewModel.settings.tapToAdvance {
                    Button {
                        viewModel.advanceToNextRepetition()
                    } label: {
                        Label("Next", systemImage: "forward.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(.white.opacity(0.55))
                }
            }
            .padding(.horizontal, DesignTokens.horizontalPadding)

            Button("End session") {
                showEndConfirm = true
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.red.opacity(0.85))
            .padding(.bottom, 24)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEndConfirm = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .alert("End session?", isPresented: $showEndConfirm) {
            Button("Keep going", role: .cancel) {}
            Button("End", role: .destructive) {
                viewModel.endSession()
                dismiss()
            }
        } message: {
            Text("Your progress in this journey will be lost.")
        }
    }

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(ChakraStep.allCases) { step in
                Circle()
                    .fill(dotColor(for: step))
                    .frame(width: step == viewModel.currentStep ? 9 : 7, height: step == viewModel.currentStep ? 9 : 7)
            }
        }
    }

    private func dotColor(for step: ChakraStep) -> Color {
        if viewModel.lockedChakraIDs.contains(step.rawValue) {
            return step.color
        }
        if step == viewModel.currentStep {
            return .white
        }
        return .white.opacity(0.25)
    }
}

struct CompletionView: View {
    @ObservedObject var viewModel: SessionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: DesignTokens.stackSpacing) {
            Text("Aligned")
                .font(DesignTokens.Typography.screenTitle)
                .foregroundStyle(
                    LinearGradient(colors: ChakraStep.allCases.map(\.color), startPoint: .leading, endPoint: .trailing)
                )
                .padding(.top, 12)

            MeditationFigureView(
                activeStep: .crown,
                lockedIDs: Set(ChakraStep.allCases.map(\.rawValue)),
                pulseScale: 1,
                pulseGlow: 1,
                showAllLocked: true
            )
            .frame(maxHeight: 440)
            .padding(.horizontal, DesignTokens.horizontalPadding)

            Text("You are aligned.")
                .font(DesignTokens.Typography.subhead)
                .foregroundStyle(.white.opacity(0.85))

            Spacer()

            Button {
                viewModel.restartSameSession()
            } label: {
                Text("Journey again")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .tint(.white)
            .padding(.horizontal, DesignTokens.buttonHorizontalPadding)

            Button {
                viewModel.endSession()
                dismiss()
            } label: {
                Text("Done")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignTokens.accentPurple)
            .padding(.horizontal, DesignTokens.buttonHorizontalPadding)
            .padding(.bottom, 32)
        }
    }
}
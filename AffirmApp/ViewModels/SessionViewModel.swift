import SwiftUI
import UIKit

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var configurations: [ChakraConfiguration]
    @Published var settings: AppSettings
    @Published var stats: SessionStats
    @Published var currentStep: ChakraStep = .root
    @Published var completedSteps: Set<ChakraStep> = []
    @Published var currentRepetition: Int = 0
    @Published var glowPhase: ChakraGlowPhase = .idle
    @Published var pulseScale: CGFloat = 1.0
    @Published var pulseGlow: CGFloat = 0.5
    @Published var isSessionActive = false
    @Published var showCompletion = false
    @Published var lockedChakraIDs: Set<Int> = []
    @Published var statusBanner: String?
    @Published var isPreparing = false
    @Published var isPaused = false
    @Published var hasPremiumAccess = false

    let audioPlayer = AffirmationAudioPlayer()
    private var pulseTask: Task<Void, Never>?
    private var sessionTask: Task<Void, Never>?

    init() {
        configurations = SessionStore.loadConfigurations()
        settings = SessionStore.loadSettings()
        stats = SessionStore.loadStats()
    }

    var estimatedMinutes: Int {
        configurations.estimatedDurationMinutes(
            voiceEnabled: settings.voiceEnabled,
            intervalSeconds: settings.affirmationIntervalSeconds
        )
    }

    func saveSetup() {
        SessionStore.saveConfigurations(configurations)
        SessionStore.saveSettings(settings)
    }

    func applyDefaultRepetitionsToAll() {
        let value = settings.defaultRepetitionsPerChakra
        for i in configurations.indices {
            configurations[i].repetitionCount = value
        }
        saveSetup()
    }

    func configuration(for step: ChakraStep) -> ChakraConfiguration {
        configurations.first { $0.step == step }!
    }

    func startSession() {
        saveSetup()
        cancelSessionWork()
        currentStep = .root
        completedSteps = []
        lockedChakraIDs = []
        currentRepetition = 0
        glowPhase = .idle
        showCompletion = false
        isSessionActive = true
        isPaused = false
        isPreparing = true
        statusBanner = nil

        sessionTask = Task {
            try? await Task.sleep(for: .milliseconds(850))
            guard isSessionActive else { return }
            isPreparing = false
            glowPhase = .pulsing
            await runRepetitionCycle()
        }
    }

    func togglePause() {
        guard isSessionActive, !showCompletion, !isPreparing else { return }
        isPaused.toggle()
        if isPaused {
            audioPlayer.stop()
            pulseTask?.cancel()
            statusBanner = "Paused"
        } else {
            statusBanner = nil
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    func advanceToNextRepetition() {
        guard isSessionActive, !showCompletion, !isPreparing else { return }
        audioPlayer.stop()
        pulseTask?.cancel()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        skipCurrentRepetition = true
    }

    private var skipCurrentRepetition = false

    func endSession() {
        cancelSessionWork()
        audioPlayer.stop()
        isSessionActive = false
        showCompletion = false
        isPreparing = false
        isPaused = false
        glowPhase = .idle
        statusBanner = nil
    }

    private func cancelSessionWork() {
        sessionTask?.cancel()
        pulseTask?.cancel()
        sessionTask = nil
    }

    private func waitWhilePaused() async {
        while isPaused, isSessionActive {
            try? await Task.sleep(for: .milliseconds(200))
        }
    }

    private func affirmationGap() async {
        let seconds = settings.affirmationIntervalSeconds
        guard seconds > 0 else { return }
        let steps = Int(seconds / 0.2)
        for _ in 0 ..< steps {
            await waitWhilePaused()
            guard isSessionActive, !skipCurrentRepetition else { return }
            try? await Task.sleep(for: .milliseconds(200))
        }
    }

    private func runRepetitionCycle() async {
        guard isSessionActive, !showCompletion else { return }

        let config = configuration(for: currentStep)
        let total = max(1, config.repetitionCount)
        glowPhase = .pulsing

        for rep in 1 ... total {
            await waitWhilePaused()
            guard isSessionActive, currentStep == config.step else { return }

            skipCurrentRepetition = false
            currentRepetition = rep

            await triggerPulse()

            if skipCurrentRepetition { continue }

            let result = await audioPlayer.speak(
                text: config.affirmation.english,
                settings: settings,
                hasPremiumAccess: hasPremiumAccess
            )
            showSpeakStatus(result)

            if skipCurrentRepetition { continue }

            await affirmationGap()
            if skipCurrentRepetition { continue }
        }

        guard isSessionActive else { return }
        await lockCurrentChakra()
    }

    private func showSpeakStatus(_ result: AffirmationAudioPlayer.SpeakResult) {
        switch result {
        case .success:
            break
        case .fellBackToSystemVoice:
            statusBanner = "Using built-in voice"
            Task {
                try? await Task.sleep(for: .seconds(2.5))
                if statusBanner == "Using built-in voice" { statusBanner = nil }
            }
        case .silentTiming:
            if !settings.voiceEnabled {
                statusBanner = "Silent mode"
            }
        }
    }

    private func triggerPulse() async {
        let reduceMotion = UIAccessibility.isReduceMotionEnabled
        if reduceMotion {
            withAnimation(.easeInOut(duration: 0.35)) {
                pulseGlow = 1.0
                pulseScale = 1.0
            }
            return
        }

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        pulseTask?.cancel()
        pulseTask = Task {
            withAnimation(.easeInOut(duration: 0.45)) {
                pulseScale = 1.12
                pulseGlow = 1.0
            }
            try? await Task.sleep(for: .milliseconds(450))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.55)) {
                pulseScale = 0.94
                pulseGlow = 0.55
            }
            try? await Task.sleep(for: .milliseconds(550))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.4)) {
                pulseScale = 1.0
                pulseGlow = 0.75
            }
        }
    }

    private func lockCurrentChakra() async {
        glowPhase = .locked
        lockedChakraIDs.insert(currentStep.rawValue)
        completedSteps.insert(currentStep)
        pulseScale = 1.0
        pulseGlow = 1.0
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        glowPhase = .transitioning
        try? await Task.sleep(for: .milliseconds(900))
        guard isSessionActive else { return }

        if let next = currentStep.next {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentStep = next
            }
            currentRepetition = 0
            glowPhase = .pulsing
            await runRepetitionCycle()
        } else {
            glowPhase = .locked
            showCompletion = true
            SessionStore.recordJourneyCompleted()
            stats = SessionStore.loadStats()
        }
    }

    func restartSameSession() {
        showCompletion = false
        startSession()
    }
}
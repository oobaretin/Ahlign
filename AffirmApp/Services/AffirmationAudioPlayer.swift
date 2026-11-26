import AVFoundation
import Combine

@MainActor
final class AffirmationAudioPlayer: NSObject, ObservableObject {
    enum SpeakResult {
        case success
        case fellBackToSystemVoice
        case silentTiming
    }

    @Published private(set) var isSpeaking = false

    private var player: AVAudioPlayer?
    private let synthesizer = AVSpeechSynthesizer()
    private let elevenLabs = ElevenLabsService()
    private var continuation: CheckedContinuation<Void, Never>?

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func speak(text: String, settings: AppSettings, hasPremiumAccess: Bool) async -> SpeakResult {
        isSpeaking = true
        defer { isSpeaking = false }

        if settings.voiceEnabled, hasPremiumAccess, settings.useElevenLabs, !settings.elevenLabsAPIKey.isEmpty {
            do {
                let url = try await elevenLabs.synthesize(text: text, settings: settings)
                try await playFile(url: url)
                return .success
            } catch {
                await speakWithSystemVoice(text: text)
                return .fellBackToSystemVoice
            }
        }

        if settings.voiceEnabled {
            await speakWithSystemVoice(text: text)
            return .success
        }

        return .silentTiming
    }

    private func playFile(url: URL) async throws {
        player = try AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
        let duration = player?.duration ?? 1
        try? await Task.sleep(for: .seconds(duration + 0.1))
    }

    private func speakWithSystemVoice(text: String) async {
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            continuation = cont
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.82
            utterance.pitchMultiplier = 0.95
            utterance.preUtteranceDelay = 0.05
            synthesizer.speak(utterance)
        }
    }

    func stop() {
        player?.stop()
        synthesizer.stopSpeaking(at: .immediate)
        continuation?.resume()
        continuation = nil
        isSpeaking = false
    }
}

extension AffirmationAudioPlayer: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            continuation?.resume()
            continuation = nil
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            continuation?.resume()
            continuation = nil
        }
    }
}
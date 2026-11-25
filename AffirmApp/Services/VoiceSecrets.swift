import Foundation

/// Production ElevenLabs key: set `ElevenLabsAPIKey` in the target’s Info (xcconfig / build setting).
/// Never shown in Settings for release builds.
enum VoiceSecrets {
    static var elevenLabsAPIKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "ElevenLabsAPIKey") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
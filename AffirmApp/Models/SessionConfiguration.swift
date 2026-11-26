import Foundation

struct ChakraConfiguration: Codable, Identifiable {
    var id: Int { step.rawValue }
    let step: ChakraStep
    var selectedAffirmationID: String
    var repetitionCount: Int

    var affirmation: Affirmation {
        AffirmationLibrary.affirmations(for: step)
            .first { $0.id == selectedAffirmationID }
            ?? AffirmationLibrary.affirmations(for: step)[0]
    }

    static func defaultConfigurations() -> [ChakraConfiguration] {
        ChakraStep.allCases.map { step in
            let first = AffirmationLibrary.affirmations(for: step)[0]
            return ChakraConfiguration(
                step: step,
                selectedAffirmationID: first.id,
                repetitionCount: 7
            )
        }
    }
}

enum ElevenLabsDefaults {
    static let voiceID = "45UYeUCUrGxt4rWuj2Ir"
    static let legacyVoiceID = "EXAVITQu4vr4xnSDxMaL"
}

struct AppSettings: Codable {
    var voiceEnabled: Bool = true
    var useElevenLabs: Bool = false
    /// In-memory only; never encoded to UserDefaults (see Keychain / VoiceSecrets).
    var elevenLabsAPIKey: String = ""
    var elevenLabsVoiceID: String = ElevenLabsDefaults.voiceID
    var pulseIntervalWhenMuted: TimeInterval = 4.0
    var tapToAdvance: Bool = true
    var defaultRepetitionsPerChakra: Int = 7
    /// Pause between affirmations (seconds), after voice or during silent mode.
    var affirmationIntervalSeconds: Double = 2.0

    enum CodingKeys: String, CodingKey {
        case voiceEnabled
        case useElevenLabs
        case elevenLabsVoiceID
        case pulseIntervalWhenMuted
        case tapToAdvance
        case defaultRepetitionsPerChakra
        case affirmationIntervalSeconds
    }

    mutating func hydrateCredentialFromSecureStores() {
        let bundled = VoiceSecrets.elevenLabsAPIKey
        let keychain = KeychainStorage.elevenLabsAPIKey() ?? ""
        if !keychain.isEmpty {
            elevenLabsAPIKey = keychain
        } else if !bundled.isEmpty {
            elevenLabsAPIKey = bundled
            useElevenLabs = true
        } else {
            elevenLabsAPIKey = ""
        }
    }
}

struct SessionStats: Codable {
    var completedJourneys: Int = 0
}

enum SessionStore {
    private static let configKey = "chakraConfigurations"
    private static let settingsKey = "appSettings"
    private static let statsKey = "sessionStats"

    static func loadConfigurations() -> [ChakraConfiguration] {
        guard let data = UserDefaults.standard.data(forKey: configKey),
              let configs = try? JSONDecoder().decode([ChakraConfiguration].self, from: data) else {
            return ChakraConfiguration.defaultConfigurations()
        }
        return configs
    }

    static func saveConfigurations(_ configs: [ChakraConfiguration]) {
        let sanitized = configs.map { config -> ChakraConfiguration in
            var c = config
            c.repetitionCount = min(99, max(1, c.repetitionCount))
            if AffirmationLibrary.affirmations(for: c.step).first(where: { $0.id == c.selectedAffirmationID }) == nil {
                c.selectedAffirmationID = AffirmationLibrary.affirmations(for: c.step)[0].id
            }
            return c
        }
        guard let data = try? JSONEncoder().encode(sanitized) else { return }
        UserDefaults.standard.set(data, forKey: configKey)
    }

    static func loadSettings() -> AppSettings {
        var migratedLegacyKey = false
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let legacyKey = json["elevenLabsAPIKey"] as? String,
           !legacyKey.isEmpty,
           KeychainStorage.elevenLabsAPIKey() == nil {
            KeychainStorage.setElevenLabsAPIKey(legacyKey)
            migratedLegacyKey = true
        }

        var settings: AppSettings
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        } else {
            settings = AppSettings()
        }

        var needsSave = false
        if settings.elevenLabsVoiceID == ElevenLabsDefaults.legacyVoiceID {
            settings.elevenLabsVoiceID = ElevenLabsDefaults.voiceID
            needsSave = true
        }

        settings.hydrateCredentialFromSecureStores()
        if migratedLegacyKey { needsSave = true }

        if needsSave { saveSettings(settings) }
        return settings
    }

    static func saveSettings(_ settings: AppSettings) {
        #if DEBUG
        if !settings.elevenLabsAPIKey.isEmpty {
            KeychainStorage.setElevenLabsAPIKey(settings.elevenLabsAPIKey)
        }
        #endif

        var storable = settings
        storable.elevenLabsAPIKey = ""
        guard let data = try? JSONEncoder().encode(storable) else { return }
        UserDefaults.standard.set(data, forKey: settingsKey)
    }

    static func loadStats() -> SessionStats {
        guard let data = UserDefaults.standard.data(forKey: statsKey),
              let stats = try? JSONDecoder().decode(SessionStats.self, from: data) else {
            return SessionStats()
        }
        return stats
    }

    static func saveStats(_ stats: SessionStats) {
        guard let data = try? JSONEncoder().encode(stats) else { return }
        UserDefaults.standard.set(data, forKey: statsKey)
    }

    static func recordJourneyCompleted() {
        var stats = loadStats()
        stats.completedJourneys += 1
        saveStats(stats)
    }
}

extension Array where Element == ChakraConfiguration {
    /// Rough session length for Home subtitle (~5s per voiced rep + transitions).
    func estimatedDurationMinutes(voiceEnabled: Bool, intervalSeconds: TimeInterval) -> Int {
        let repSeconds = voiceEnabled ? 5.0 : 2.0
        let reps = reduce(0) { $0 + $1.repetitionCount }
        let transitions = 7.0 * 1.2
        let total = Double(reps) * (repSeconds + intervalSeconds) + transitions + 8
        return Swift.max(3, Int(ceil(total / 60)))
    }
}
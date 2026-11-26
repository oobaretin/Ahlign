import Foundation

enum ElevenLabsError: Error {
    case missingAPIKey
    case invalidResponse
    case httpStatus(Int)
}

/// ElevenLabs text-to-speech. Requires API key in settings.
final class ElevenLabsService {
    private let session: URLSession
    private let maxTextLength = 500

    init(session: URLSession = .shared) {
        self.session = session
    }

    private static let audioCacheDirectory: URL = {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("elevenlabs", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    private func cacheURL(for text: String, voiceID: String) -> URL {
        let hash = "\(voiceID)_\(text)".data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
        return Self.audioCacheDirectory.appendingPathComponent("\(hash).mp3")
    }

    func synthesize(text: String, settings: AppSettings) async throws -> URL {
        guard settings.useElevenLabs, !settings.elevenLabsAPIKey.isEmpty else {
            throw ElevenLabsError.missingAPIKey
        }

        let sanitized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitized.isEmpty, sanitized.count <= maxTextLength else {
            throw ElevenLabsError.invalidResponse
        }
        guard settings.elevenLabsVoiceID.count <= 64,
              settings.elevenLabsVoiceID.allSatisfy({ $0.isLetter || $0.isNumber })
        else {
            throw ElevenLabsError.invalidResponse
        }

        let cached = cacheURL(for: sanitized, voiceID: settings.elevenLabsVoiceID)
        if FileManager.default.fileExists(atPath: cached.path) {
            return cached
        }

        guard let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(settings.elevenLabsVoiceID)") else {
            throw ElevenLabsError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue(settings.elevenLabsAPIKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")

        let body: [String: Any] = [
            "text": sanitized,
            "model_id": "eleven_multilingual_v2",
            "voice_settings": [
                "stability": 0.75,
                "similarity_boost": 0.75,
                "style": 0.15,
                "use_speaker_boost": true
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ElevenLabsError.invalidResponse }
        guard (200 ... 299).contains(http.statusCode) else { throw ElevenLabsError.httpStatus(http.statusCode) }

        try data.write(to: cached, options: .atomic)
        return cached
    }
}
import SwiftUI

enum ChakraStep: Int, CaseIterable, Identifiable, Codable {
    case root = 1
    case sacral = 2
    case solarPlexus = 3
    case heart = 4
    case throat = 5
    case thirdEye = 6
    case crown = 7

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .root: return "ROOT"
        case .sacral: return "SACRAL"
        case .solarPlexus: return "SOLAR PLEXUS"
        case .heart: return "HEART"
        case .throat: return "THROAT"
        case .thirdEye: return "THIRD EYE"
        case .crown: return "CROWN"
        }
    }

    var headerPhrase: String {
        switch self {
        case .root: return "I AM"
        case .sacral: return "I FEEL"
        case .solarPlexus: return "I DO"
        case .heart: return "I LOVE"
        case .throat: return "I SPEAK"
        case .thirdEye: return "I SEE"
        case .crown: return "I UNDERSTAND"
        }
    }

    var color: Color {
        switch self {
        case .root: return Color(red: 1, green: 0.2, blue: 0.4)
        case .sacral: return Color(red: 1, green: 0.55, blue: 0)
        case .solarPlexus: return Color(red: 1, green: 0.84, blue: 0)
        case .heart: return Color(red: 0, green: 1, blue: 0.53)
        case .throat: return Color(red: 0, green: 0.9, blue: 1)
        case .thirdEye: return Color(red: 0.62, green: 0.31, blue: 0.87)
        case .crown: return Color(red: 0.88, green: 0.69, blue: 1)
        }
    }

    /// Normalized Y along the spine (0 = bottom, 1 = top) for seated figure layout.
    var spinePosition: CGFloat {
        switch self {
        case .root: return 0.08
        case .sacral: return 0.22
        case .solarPlexus: return 0.38
        case .heart: return 0.52
        case .throat: return 0.68
        case .thirdEye: return 0.82
        case .crown: return 0.94
        }
    }

    var usesBustLayout: Bool {
        self == .throat || self == .thirdEye || self == .crown
    }

    var next: ChakraStep? {
        ChakraStep(rawValue: rawValue + 1)
    }
}

struct Affirmation: Identifiable, Codable, Hashable {
    let id: String
    let english: String
}

enum ChakraGlowPhase: Equatable {
    case idle
    case pulsing
    case locked
    case transitioning
}
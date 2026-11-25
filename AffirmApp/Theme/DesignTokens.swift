import SwiftUI

enum DesignTokens {
    static let horizontalPadding: CGFloat = 20
    static let buttonHorizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 24
    static let stackSpacing: CGFloat = 16

    static let accent = Color("AccentColor", bundle: nil)
        .opacity(1)
    static let accentPurple = Color(red: 0.6, green: 0.35, blue: 1)

    enum Typography {
        static let screenTitle = Font.system(size: 22, weight: .bold, design: .rounded)
        static let sessionPhase = Font.system(size: 13, weight: .semibold, design: .rounded)
        static let affirmation = Font.system(size: 20, weight: .medium, design: .default)
        static let caption = Font.caption
        static let subhead = Font.subheadline
    }
}
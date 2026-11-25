import SwiftUI
import UIKit

struct ReferenceMeditationImageView: View {
    var style: MeditationFigureStyle

    var body: some View {
        Group {
            if MeditationChakraLayout.hasArtwork {
                Image(MeditationChakraLayout.artworkName)
                    .resizable()
                    .scaledToFit()
                    .accessibilityHidden(true)
            } else {
                StippledMeditationOutlineView(style: style)
            }
        }
    }
}
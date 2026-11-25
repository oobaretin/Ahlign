import CoreGraphics
import UIKit

/// Chakra anchor positions (0…1) relative to `MeditationPoseSeated` artwork (wireframe lotus, 764×1024).
enum MeditationChakraLayout {
    static let artworkName = "MeditationPoseSeated"

    static var hasArtwork: Bool {
        UIImage(named: artworkName) != nil
    }

    static var artworkPixelSize: CGSize? {
        UIImage(named: artworkName)?.size
    }

    /// Fits artwork like `scaledToFit` inside the container.
    static func fittedRect(container: CGSize, imageSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }
        let scale = min(container.width / imageSize.width, container.height / imageSize.height)
        let w = imageSize.width * scale
        let h = imageSize.height * scale
        return CGRect(
            x: (container.width - w) / 2,
            y: (container.height - h) / 2,
            width: w,
            height: h
        )
    }

    /// Normalized X of the white center line on `MeditationPoseSeated` (wireframe spine).
    static let artworkSpineX: CGFloat = 0.499

    static func anchorOnArtwork(for step: ChakraStep) -> CGPoint {
        let x = artworkSpineX
        switch step {
        case .root: return CGPoint(x: x, y: 0.772)
        case .sacral: return CGPoint(x: x, y: 0.662)
        case .solarPlexus: return CGPoint(x: x, y: 0.552)
        case .heart: return CGPoint(x: x, y: 0.448)
        case .throat: return CGPoint(x: x, y: 0.348)
        case .thirdEye: return CGPoint(x: x, y: 0.248)
        case .crown: return CGPoint(x: x, y: 0.138)
        }
    }

    static func anchorOnVector(for step: ChakraStep) -> CGPoint {
        MeditationSilhouetteArt.anchor(for: step)
    }

    static func position(
        for step: ChakraStep,
        in container: CGSize,
        useBustVectorLayout: Bool
    ) -> CGPoint {
        let layoutRect: CGRect
        if hasArtwork, let imageSize = artworkPixelSize {
            layoutRect = fittedRect(container: container, imageSize: imageSize)
            let n = anchorOnArtwork(for: step)
            return CGPoint(x: layoutRect.minX + n.x * layoutRect.width, y: layoutRect.minY + n.y * layoutRect.height)
        }

        let insetX = container.width * 0.08
        let insetY = container.height * 0.05
        let rectW = container.width - insetX * 2
        let rectH = container.height - insetY * 2
        let n: CGPoint = if useBustVectorLayout {
            MeditationSilhouetteArt.bustAnchor(for: step)
        } else {
            MeditationSilhouetteArt.anchor(for: step)
        }
        return CGPoint(x: insetX + n.x * rectW, y: insetY + n.y * rectH)
    }
}
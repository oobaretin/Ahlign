import SwiftUI

/// Normalized anchors (0…1) on the seated lotus figure — tuned to match reference spine placement.
enum MeditationSilhouetteArt {
    static func anchor(for step: ChakraStep) -> CGPoint {
        switch step {
        case .root: return CGPoint(x: 0.50, y: 0.86)
        case .sacral: return CGPoint(x: 0.50, y: 0.73)
        case .solarPlexus: return CGPoint(x: 0.50, y: 0.60)
        case .heart: return CGPoint(x: 0.50, y: 0.48)
        case .throat: return CGPoint(x: 0.50, y: 0.36)
        case .thirdEye: return CGPoint(x: 0.50, y: 0.24)
        case .crown: return CGPoint(x: 0.50, y: 0.11)
        }
    }

    static func bustAnchor(for step: ChakraStep) -> CGPoint {
        switch step {
        case .throat: return CGPoint(x: 0.50, y: 0.72)
        case .thirdEye: return CGPoint(x: 0.50, y: 0.48)
        case .crown: return CGPoint(x: 0.50, y: 0.22)
        default: return anchor(for: step)
        }
    }

    /// Seated lotus — meditating figure with arms on knees (reference style).
    static func seatedLotusPaths(in rect: CGRect) -> [Path] {
        let w = rect.width
        let h = rect.height
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * w, y: rect.minY + y * h)
        }

        var head = Path()
        head.addEllipse(in: CGRect(
            x: p(0.38, 0).x,
            y: p(0, 0.04).y,
            width: w * 0.24,
            height: h * 0.14
        ))

        var shoulders = Path()
        shoulders.move(to: p(0.50, 0.18))
        shoulders.addQuadCurve(to: p(0.32, 0.28), control: p(0.38, 0.20))
        shoulders.move(to: p(0.50, 0.18))
        shoulders.addQuadCurve(to: p(0.68, 0.28), control: p(0.62, 0.20))

        var torso = Path()
        torso.move(to: p(0.42, 0.26))
        torso.addQuadCurve(to: p(0.40, 0.54), control: p(0.44, 0.40))
        torso.move(to: p(0.58, 0.26))
        torso.addQuadCurve(to: p(0.60, 0.54), control: p(0.56, 0.40))

        var leftArm = Path()
        leftArm.move(to: p(0.32, 0.28))
        leftArm.addQuadCurve(to: p(0.22, 0.58), control: p(0.18, 0.38))
        leftArm.addQuadCurve(to: p(0.38, 0.62), control: p(0.28, 0.66))

        var rightArm = Path()
        rightArm.move(to: p(0.68, 0.28))
        rightArm.addQuadCurve(to: p(0.78, 0.58), control: p(0.82, 0.38))
        rightArm.addQuadCurve(to: p(0.62, 0.62), control: p(0.72, 0.66))

        var legs = Path()
        legs.move(to: p(0.40, 0.54))
        legs.addQuadCurve(to: p(0.18, 0.78), control: p(0.12, 0.60))
        legs.addQuadCurve(to: p(0.50, 0.92), control: p(0.22, 0.94))
        legs.addQuadCurve(to: p(0.82, 0.78), control: p(0.78, 0.94))
        legs.addQuadCurve(to: p(0.60, 0.54), control: p(0.88, 0.60))

        var spine = Path()
        spine.move(to: p(0.50, 0.10))
        spine.addLine(to: p(0.50, 0.88))

        return [head, shoulders, torso, leftArm, rightArm, legs, spine]
    }

    static func bustPaths(in rect: CGRect) -> [Path] {
        let w = rect.width
        let h = rect.height
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * w, y: rect.minY + y * h)
        }

        var head = Path()
        head.addEllipse(in: CGRect(
            x: p(0.34, 0).x,
            y: p(0, 0.12).y,
            width: w * 0.32,
            height: h * 0.38
        ))

        var neck = Path()
        neck.move(to: p(0.44, 0.50))
        neck.addLine(to: p(0.56, 0.50))
        neck.addLine(to: p(0.54, 0.72))
        neck.addLine(to: p(0.46, 0.72))
        neck.closeSubpath()

        var spine = Path()
        spine.move(to: p(0.50, 0.28))
        spine.addLine(to: p(0.50, 0.78))

        return [head, neck, spine]
    }
}

enum MeditationFigureStyle {
    case homePreview
    case seated
    case bust
    case bustSession
    case completion
}

/// Glowing stippled strokes like the reference video frames.
struct StippledMeditationOutlineView: View {
    var style: MeditationFigureStyle

    var body: some View {
        Canvas { context, size in
            let inset = CGSize(width: size.width * 0.08, height: size.height * 0.05)
            let rect = CGRect(
                x: inset.width,
                y: inset.height,
                width: size.width - inset.width * 2,
                height: size.height - inset.height * 2
            )

            let paths: [Path] = switch style {
            case .bust, .bustSession:
                MeditationSilhouetteArt.bustPaths(in: rect)
            case .seated, .homePreview, .completion:
                MeditationSilhouetteArt.seatedLotusPaths(in: rect)
            }

            for path in paths {
                let dotted = StrokeStyle(lineWidth: 1.4, lineCap: .round, dash: [1, 4])
                context.drawLayer { layer in
                    layer.addFilter(.blur(radius: 6))
                    layer.stroke(path, with: .color(.white.opacity(0.45)), style: dotted)
                }
                context.drawLayer { layer in
                    layer.addFilter(.blur(radius: 2))
                    layer.stroke(path, with: .color(.white.opacity(0.55)), style: dotted)
                }
                context.stroke(path, with: .color(.white.opacity(0.85)), style: dotted)
            }
        }
        .allowsHitTesting(false)
    }
}
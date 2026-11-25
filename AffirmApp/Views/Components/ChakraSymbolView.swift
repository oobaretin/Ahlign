import SwiftUI

struct ChakraSymbolView: View {
    let step: ChakraStep
    let size: CGFloat
    var isActive: Bool
    var isLocked: Bool
    var pulseScale: CGFloat
    var pulseGlow: CGFloat

    var body: some View {
        let intensity = isLocked ? 1.0 : (isActive ? pulseGlow : 0.22)
        let scale = isActive && !isLocked ? pulseScale : 1.0

        ZStack {
            Circle()
                .fill(step.color.opacity(0.35 * intensity))
                .frame(width: size * 1.8, height: size * 1.8)
                .blur(radius: size * 0.35)

            symbolLayers(intensity: intensity)
                .frame(width: size, height: size)
        }
        .scaleEffect(scale)
        .animation(.easeInOut(duration: 0.3), value: pulseScale)
    }

    @ViewBuilder
    private func symbolLayers(intensity: Double) -> some View {
        let strokeColor = step.color.opacity(0.9 * intensity)
        let fillColor = step.color.opacity(0.25 * intensity)

        switch step {
        case .root:
            styledSymbol(LotusPetalShape(petals: 4), stroke: strokeColor, fill: fillColor)
        case .sacral, .solarPlexus, .heart, .throat:
            styledSymbol(LotusPetalShape(petals: 6), stroke: strokeColor, fill: fillColor)
        case .thirdEye:
            styledSymbol(ThirdEyeShape(), stroke: strokeColor, fill: fillColor)
        case .crown:
            styledSymbol(CrownFanShape(), stroke: strokeColor, fill: fillColor)
        }
    }

    private func styledSymbol<S: Shape>(_ shape: S, stroke: Color, fill: Color) -> some View {
        ZStack {
            shape.fill(fill)
            shape.stroke(stroke, lineWidth: 1.2)
        }
        .shadow(color: stroke, radius: size * 0.15)
    }
}

struct LotusPetalShape: Shape {
    let petals: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.38

        for i in 0 ..< petals {
            let angle = (Double(i) / Double(petals)) * .pi * 2 - .pi / 2
            let petalCenter = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius * 0.55,
                y: center.y + CGFloat(sin(angle)) * radius * 0.55
            )
            path.addEllipse(in: CGRect(
                x: petalCenter.x - radius * 0.35,
                y: petalCenter.y - radius * 0.45,
                width: radius * 0.7,
                height: radius * 0.9
            ))
        }
        path.addEllipse(in: CGRect(
            x: center.x - radius * 0.22,
            y: center.y - radius * 0.22,
            width: radius * 0.44,
            height: radius * 0.44
        ))
        return path
    }
}

struct ThirdEyeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.addEllipse(in: CGRect(x: w * 0.32, y: h * 0.38, width: w * 0.36, height: h * 0.24))
        path.move(to: CGPoint(x: w * 0.08, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.32, y: h * 0.5))
        path.move(to: CGPoint(x: w * 0.68, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.5))
        return path
    }
}

struct CrownFanShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY * 0.85)
        let count = 14
        for i in 0 ..< count {
            let t = Double(i) / Double(count - 1)
            let angle = .pi + t * .pi
            let end = CGPoint(
                x: center.x + CGFloat(cos(angle)) * rect.width * 0.48,
                y: center.y + CGFloat(sin(angle)) * rect.height * 0.55
            )
            path.move(to: center)
            path.addLine(to: end)
            path.addEllipse(in: CGRect(x: end.x - 4, y: end.y - 4, width: 8, height: 8))
        }
        return path
    }
}
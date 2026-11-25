import SwiftUI

struct MeditationFigureView: View {
    var activeStep: ChakraStep
    var lockedIDs: Set<Int>
    var pulseScale: CGFloat
    var pulseGlow: CGFloat
    var showAllLocked: Bool
    var style: MeditationFigureStyle = .seated
    /// Step digits beside symbols; journey progress uses the dot strip in the player instead.
    var showSideNumbers: Bool = false

    private let steps = ChakraStep.allCases

    private var effectiveStyle: MeditationFigureStyle {
        if showAllLocked { return .completion }
        if style == .homePreview { return .homePreview }
        if activeStep.usesBustLayout, !MeditationChakraLayout.hasArtwork { return .bustSession }
        return style
    }

    private var useBustVectorLayout: Bool {
        activeStep.usesBustLayout && !showAllLocked && style != .homePreview && !MeditationChakraLayout.hasArtwork
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let isHome = style == .homePreview
            let hasArt = MeditationChakraLayout.hasArtwork

            ZStack {
                if showAllLocked, !hasArt {
                    RadiatingRaysView()
                        .opacity(0.9)
                }

                if !hasArt {
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(showAllLocked ? 0.12 : 0.06), .clear],
                                center: .center,
                                startRadius: 8,
                                endRadius: min(w, h) * 0.48
                            )
                        )
                        .frame(width: w * 0.85, height: h * 0.75)
                        .position(x: w * 0.5, y: h * 0.52)
                }

                ReferenceMeditationImageView(style: effectiveStyle)
                    .frame(width: w, height: h)

                ForEach(steps) { step in
                    let anchor = MeditationChakraLayout.position(
                        for: step,
                        in: CGSize(width: w, height: h),
                        useBustVectorLayout: useBustVectorLayout
                    )
                    let isActive = step == activeStep && !showAllLocked && !isHome
                    let isLocked = lockedIDs.contains(step.rawValue) || showAllLocked

                    let symbolSize: CGFloat = {
                        if isHome { return 22 }
                        if isActive { return 50 }
                        if isLocked {
                            let calmLateJourney = activeStep.rawValue >= 6 && !showAllLocked
                            return calmLateJourney ? 32 : 36
                        }
                        return hasArt ? 11 : 12
                    }()

                    let showNumber = showSideNumbers && (isActive || isLocked || showAllLocked)

                    let lockedGlow: CGFloat = {
                        guard isLocked, !isActive else { return 1 }
                        if activeStep.rawValue >= 6, !showAllLocked { return 0.55 }
                        return 0.85
                    }()

                    chakraMarker(
                        step: step,
                        symbolSize: symbolSize,
                        isActive: isActive,
                        isLocked: isLocked || (isHome && step != .root),
                        isHome: isHome,
                        showNumber: showNumber,
                        lockedGlow: lockedGlow
                    )
                    .position(anchor)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Step \(step.rawValue), \(step.headerPhrase)")
                    .accessibilityAddTraits(isActive ? [.isSelected] : [])
                }
            }
        }
    }

    @ViewBuilder
    private func chakraMarker(
        step: ChakraStep,
        symbolSize: CGFloat,
        isActive: Bool,
        isLocked: Bool,
        isHome: Bool,
        showNumber: Bool,
        lockedGlow: CGFloat
    ) -> some View {
        let box = max(symbolSize + 12, 36)
        let numberOffset = box / 2 + 14

        ZStack {
            ChakraSymbolView(
                step: step,
                size: symbolSize,
                isActive: isActive,
                isLocked: isLocked,
                pulseScale: isActive ? pulseScale : 1,
                pulseGlow: isActive ? pulseGlow : (isLocked ? lockedGlow : (isHome ? 0.5 : 0.22))
            )
            .frame(width: box, height: box)

            if showNumber, !isHome {
                Text("\(step.rawValue)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(step.color.opacity(labelOpacity(step: step, isHome: isHome, isActive: isActive, isLocked: isLocked)))
                    .fixedSize()
                    .offset(x: -numberOffset, y: 0)
            }
        }
    }

    private func labelOpacity(step: ChakraStep, isHome: Bool, isActive: Bool, isLocked: Bool) -> Double {
        if isActive || isLocked { return 0.95 }
        if isHome { return 0.65 }
        return 0.28
    }
}

struct RadiatingRaysView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let pulse = (sin(t * 0.9) + 1) / 2
            Canvas { context, size in
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.52)
                let rayCount = 28
                for i in 0 ..< rayCount {
                    let angle = (Double(i) / Double(rayCount)) * .pi * 2
                    let length = size.width * (0.42 + 0.14 * pulse)
                    var path = Path()
                    path.move(to: center)
                    path.addLine(to: CGPoint(
                        x: center.x + CGFloat(cos(angle)) * length,
                        y: center.y + CGFloat(sin(angle)) * length
                    ))
                    context.stroke(
                        path,
                        with: .color(.white.opacity(0.06 + 0.14 * pulse)),
                        lineWidth: 0.9
                    )
                }
            }
        }
    }
}
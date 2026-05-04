//
//  Shimmer.swift
//  WeatherApp
//
//  Lightweight diagonal sweep used while list-style content is `.redacted`/loading; masks to the host view's alpha.
//

import SwiftUI

// MARK: - Modifier

struct ShimmerModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    private var cycleSeconds: Double { 2.65 }

    func body(content: Content) -> some View {
        content
            .overlay {
                TimelineView(.animation(minimumInterval: 1 / 90)) { timeline in
                    GeometryReader { geo in
                        let w = max(geo.size.width, 1)
                        let h = max(geo.size.height, 1)
                        let t = CGFloat(
                            timeline.date.timeIntervalSinceReferenceDate
                                .truncatingRemainder(dividingBy: cycleSeconds) / cycleSeconds
                        )
                        let stripeH = hypot(w, h) * 2.0
                        let stripeW = max(w, h) * 0.52
                        let corner = max(min(w, h) * 0.22, 8)

                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .fill(sweepGradient)
                            .frame(width: stripeW, height: stripeH)
                            .rotationEffect(.degrees(13))
                            .offset(x: (t - 0.5) * (w * 2.1 + stripeW))
                            .frame(width: w, height: h)
                            .blur(radius: max(22, min(w, h) * 0.11))
                            .blendMode(blendMode)
                    }
                    .allowsHitTesting(false)
                }
            }
            .mask(content)
            .compositingGroup()
    }

    private var blendMode: BlendMode {
        colorScheme == .dark ? .plusLighter : .multiply
    }

    private var sweepGradient: LinearGradient {
        let edge = Color.clear
        let low: Color =
            colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.018)
        let peak: Color =
            colorScheme == .dark ? .white.opacity(0.52) : .black.opacity(0.095)

        return LinearGradient(
            gradient: Gradient(stops: [
                .init(color: edge, location: 0),
                .init(color: low, location: 0.32),
                .init(color: peak, location: 0.5),
                .init(color: low, location: 0.68),
                .init(color: edge, location: 1),
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - View

extension View {
    func shimmer(_ enabled: Bool) -> some View {
        Group {
            if enabled {
                self.modifier(ShimmerModifier())
            } else {
                self
            }
        }
    }
}

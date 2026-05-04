//
//  WeatherSymbol.swift
//  WeatherApp
//

import SwiftUI

struct WeatherSymbol: View {
    let systemName: String
    var size: CGFloat
    var square: CGFloat?
    @Environment(\.colorScheme) private var colorScheme
    
    init(systemName: String, size: CGFloat = 22, square: CGFloat? = nil) {
        self.systemName = systemName
        self.size = size
        self.square = square
    }

    var body: some View {
        let palette = Self.palette(for: systemName, scheme: colorScheme)
        Image(systemName: systemName)
            .font(.system(size: size))
            .symbolRenderingMode(.palette)
            .foregroundStyle(palette.base, palette.accent1, palette.accent2)
            .frame(width: square, height: square, alignment: .center)
            .accessibilityHidden(true)
    }
}

private extension WeatherSymbol {
    struct Palette {
        let base: Color
        let accent1: Color
        let accent2: Color
    }

    static func palette(for systemName: String, scheme: ColorScheme) -> Palette {
        let name = systemName.lowercased()

        let cloud: Color = (scheme == .dark)
            ? Color(red: 0.74, green: 0.78, blue: 0.86)
            : Color(red: 0.42, green: 0.46, blue: 0.52)

        let cloudSecondary: Color = (scheme == .dark)
            ? Color(red: 0.60, green: 0.64, blue: 0.74)
            : Color(red: 0.52, green: 0.56, blue: 0.62)

        let sun: Color = (scheme == .dark)
            ? Color(red: 1.00, green: 0.86, blue: 0.24)
            : Color(red: 1.00, green: 0.74, blue: 0.12)

        let sun2: Color = (scheme == .dark)
            ? Color(red: 1.00, green: 0.92, blue: 0.45)
            : Color(red: 1.00, green: 0.84, blue: 0.28)

        let rain: Color = (scheme == .dark)
            ? Color(red: 0.42, green: 0.82, blue: 1.00)
            : Color(red: 0.10, green: 0.56, blue: 0.93)

        let rain2: Color = (scheme == .dark)
            ? Color(red: 0.20, green: 0.62, blue: 1.00)
            : Color(red: 0.18, green: 0.70, blue: 1.00)

        let snow: Color = (scheme == .dark)
            ? Color.white.opacity(0.95)
            : Color(red: 0.96, green: 0.98, blue: 1.0)

        let bolt: Color = (scheme == .dark)
            ? Color(red: 1.00, green: 0.93, blue: 0.38)
            : Color(red: 1.00, green: 0.82, blue: 0.20)

        let horizonLine: Color = (scheme == .dark)
            ? Color(red: 0.90, green: 0.92, blue: 0.96)
            : Color(red: 0.18, green: 0.20, blue: 0.26)

        if name.contains("sun") && name.contains("cloud") {
            return Palette(base: cloud, accent1: sun, accent2: sun2)
        }
        if name == "sunrise.fill" || name == "sunset.fill" {
            switch name {
            case "sunset.fill":
                let disk: Color = (scheme == .dark)
                    ? Color(red: 1.00, green: 0.58, blue: 0.32)
                    : Color(red: 0.96, green: 0.40, blue: 0.22)
                let halo: Color = (scheme == .dark)
                    ? Color(red: 1.00, green: 0.80, blue: 0.48)
                    : Color(red: 1.00, green: 0.62, blue: 0.35)
                return Palette(base: disk, accent1: halo, accent2: horizonLine)
            default:
                return Palette(base: sun, accent1: sun2, accent2: horizonLine)
            }
        }
        if name.contains("sun") {
            return Palette(base: sun, accent1: sun2, accent2: sun)
        }
        if name.contains("snow") || name == "snowflake" {
            return Palette(base: cloud, accent1: snow, accent2: snow)
        }
        if name.contains("bolt") || name.contains("thunder") {
            return Palette(base: cloud, accent1: bolt, accent2: rain)
        }
        if name.contains("rain") || name.contains("drizzle") || name.contains("sleet") || name.contains("hail") {
            return Palette(base: cloud, accent1: rain, accent2: rain2)
        }
        if name.contains("fog") {
            return Palette(base: cloud, accent1: cloudSecondary, accent2: cloudSecondary)
        }
        return Palette(base: cloud, accent1: cloudSecondary, accent2: cloudSecondary)
    }
}


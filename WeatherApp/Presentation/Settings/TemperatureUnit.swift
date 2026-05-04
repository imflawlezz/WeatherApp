//
//  TemperatureUnit.swift
//  WeatherApp
//
//  Metric vs imperial toggle stored in `AppStorage`, exposed as `EnvironmentValues.temperatureUnit`,
//  with small number formatters shared by multiple weather views.
//

import SwiftUI

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case metric
    case imperial

    var id: String { rawValue }
}

// MARK: - Environment

private struct TemperatureUnitKey: EnvironmentKey {
    static let defaultValue: TemperatureUnit = .metric
}

extension EnvironmentValues {
    var temperatureUnit: TemperatureUnit {
        get { self[TemperatureUnitKey.self] }
        set { self[TemperatureUnitKey.self] = newValue }
    }
}

// MARK: - Formatters

enum WeatherFormatters {
    static func temperature(_ celsius: Double, unit: TemperatureUnit) -> String {
        switch unit {
        case .metric:
            return String(format: "%.0f°", celsius)
        case .imperial:
            let f = celsius * 9 / 5 + 32
            return String(format: "%.0f°", f)
        }
    }

    static func speedKmh(_ kmh: Double, unit: TemperatureUnit) -> String {
        switch unit {
        case .metric:
            return String(format: "%.0f km/h", kmh)
        case .imperial:
            let mph = kmh * 0.621_371
            return String(format: "%.0f mph", mph)
        }
    }
}

//
//  WMOWeatherPresentationMapper.swift
//  WeatherApp
//
//  Bridges Open-Meteo WMO weather codes to SF Symbol names and `Localizable` keys (`wmo.*`).
//

import Foundation

enum WMOWeatherPresentationMapper {
    // MARK: - Symbols

    static func symbolName(forWMOCode code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill"
        case 1, 2: return "cloud.sun.fill"
        case 3: return "cloud.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55: return "cloud.drizzle.fill"
        case 56, 57: return "cloud.sleet.fill"
        case 61, 63: return "cloud.rain.fill"
        case 65: return "cloud.heavyrain.fill"
        case 66, 67: return "cloud.hail.fill"
        case 71, 73, 75: return "cloud.snow.fill"
        case 77: return "snowflake"
        case 80, 81: return "cloud.sun.rain.fill"
        case 82: return "cloud.heavyrain.fill"
        case 85, 86: return "cloud.snow.fill"
        case 95: return "cloud.bolt.rain.fill"
        case 96, 99: return "cloud.bolt.fill"
        default: return "cloud.sun.fill"
        }
    }

    // MARK: - Localized keys

    static func descriptionKey(forWMOCode code: Int) -> String {
        switch code {
        case 0: return "wmo.clear"
        case 1: return "wmo.mainly_clear"
        case 2: return "wmo.partly_cloudy"
        case 3: return "wmo.overcast"
        case 45, 48: return "wmo.fog"
        case 51, 53, 55: return "wmo.drizzle"
        case 56, 57: return "wmo.freezing_drizzle"
        case 61, 63, 65: return "wmo.rain"
        case 66, 67: return "wmo.freezing_rain"
        case 71, 73, 75, 77: return "wmo.snow"
        case 80, 81, 82: return "wmo.rain_showers"
        case 85, 86: return "wmo.snow_showers"
        case 95: return "wmo.thunderstorm"
        case 96, 99: return "wmo.thunderstorm_hail"
        default: return "wmo.unknown"
        }
    }
}

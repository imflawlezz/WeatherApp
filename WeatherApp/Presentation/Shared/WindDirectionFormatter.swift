//
//  WindDirectionFormatter.swift
//  WeatherApp
//

import Foundation

enum WindDirectionFormatter {
    static func localizationKey(degrees: Double) -> String {
        let normalized = (degrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let index = Int((normalized + 22.5) / 45.0) % 8
        switch index {
        case 0: return "wind.n"
        case 1: return "wind.ne"
        case 2: return "wind.e"
        case 3: return "wind.se"
        case 4: return "wind.s"
        case 5: return "wind.sw"
        case 6: return "wind.w"
        default: return "wind.nw"
        }
    }

    static func arrowSymbolName(degrees: Double) -> String {
        let normalized = (degrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let index = Int((normalized + 22.5) / 45.0) % 8
        switch index {
        case 0: return "arrow.up"
        case 1: return "arrow.up.right"
        case 2: return "arrow.right"
        case 3: return "arrow.down.right"
        case 4: return "arrow.down"
        case 5: return "arrow.down.left"
        case 6: return "arrow.left"
        default: return "arrow.up.left"
        }
    }
}

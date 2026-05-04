//
//  HourlyWeatherPoint.swift
//  WeatherApp
//

import Foundation

public struct HourlyWeatherPoint: Sendable, Hashable, Identifiable {
    public let id: String
    public let date: Date
    public let temperatureCelsius: Double
    public let conditionSymbolName: String

    public init(id: String, date: Date, temperatureCelsius: Double, conditionSymbolName: String) {
        self.id = id
        self.date = date
        self.temperatureCelsius = temperatureCelsius
        self.conditionSymbolName = conditionSymbolName
    }
}

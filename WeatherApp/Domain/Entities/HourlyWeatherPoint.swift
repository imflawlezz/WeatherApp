//
//  HourlyWeatherPoint.swift
//  WeatherApp
//
//  Single hour in the near-term strip; `id` is the raw Open-Meteo time string for stable diffing.
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

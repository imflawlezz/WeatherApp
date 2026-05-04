//
//  CurrentWeatherSnapshot.swift
//  WeatherApp
//
//  Snapshot of conditions at forecast request time. `conditionDescriptionKey` resolves through
//  `WeatherL10n` / String Catalog (`wmo.*` keys).
//

import Foundation

public struct CurrentWeatherSnapshot: Sendable, Hashable {
    public let temperatureCelsius: Double
    public let apparentTemperatureCelsius: Double
    public let humidityPercent: Double
    public let precipitationMm: Double
    public let windSpeedKmh: Double
    public let windDirectionDegrees: Double
    public let pressureHpa: Double
    public let conditionSymbolName: String
    public let conditionDescriptionKey: String

    public init(
        temperatureCelsius: Double,
        apparentTemperatureCelsius: Double,
        humidityPercent: Double,
        precipitationMm: Double,
        windSpeedKmh: Double,
        windDirectionDegrees: Double,
        pressureHpa: Double,
        conditionSymbolName: String,
        conditionDescriptionKey: String
    ) {
        self.temperatureCelsius = temperatureCelsius
        self.apparentTemperatureCelsius = apparentTemperatureCelsius
        self.humidityPercent = humidityPercent
        self.precipitationMm = precipitationMm
        self.windSpeedKmh = windSpeedKmh
        self.windDirectionDegrees = windDirectionDegrees
        self.pressureHpa = pressureHpa
        self.conditionSymbolName = conditionSymbolName
        self.conditionDescriptionKey = conditionDescriptionKey
    }
}

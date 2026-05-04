//
//  ForecastDay.swift
//  WeatherApp
//

import Foundation

public struct ForecastDay: Sendable, Hashable, Identifiable {
    public let id: String
    public let date: Date
    public let summary: ForecastDaySummary
    public let detail: ForecastDayDetail

    public init(id: String, date: Date, summary: ForecastDaySummary, detail: ForecastDayDetail) {
        self.id = id
        self.date = date
        self.summary = summary
        self.detail = detail
    }
}

public struct ForecastDaySummary: Sendable, Hashable {
    public let tempMinCelsius: Double
    public let tempMaxCelsius: Double
    public let pressureHectopascals: Double
    public let precipitationMm: Double
    public let conditionSymbolName: String

    public init(
        tempMinCelsius: Double,
        tempMaxCelsius: Double,
        pressureHectopascals: Double,
        precipitationMm: Double,
        conditionSymbolName: String
    ) {
        self.tempMinCelsius = tempMinCelsius
        self.tempMaxCelsius = tempMaxCelsius
        self.pressureHectopascals = pressureHectopascals
        self.precipitationMm = precipitationMm
        self.conditionSymbolName = conditionSymbolName
    }
}

public struct ForecastDayDetail: Sendable, Hashable {
    public let conditionDescriptionKey: String
    public let feelsLikeMaxCelsius: Double
    public let humidityPercent: Double
    public let windSpeedKmh: Double
    public let windDirectionDegrees: Double
    public let pressureHectopascals: Double
    public let sunrise: Date?
    public let sunset: Date?

    public init(
        conditionDescriptionKey: String,
        feelsLikeMaxCelsius: Double,
        humidityPercent: Double,
        windSpeedKmh: Double,
        windDirectionDegrees: Double,
        pressureHectopascals: Double,
        sunrise: Date?,
        sunset: Date?
    ) {
        self.conditionDescriptionKey = conditionDescriptionKey
        self.feelsLikeMaxCelsius = feelsLikeMaxCelsius
        self.humidityPercent = humidityPercent
        self.windSpeedKmh = windSpeedKmh
        self.windDirectionDegrees = windDirectionDegrees
        self.pressureHectopascals = pressureHectopascals
        self.sunrise = sunrise
        self.sunset = sunset
    }
}

public struct CityWeatherForecast: Sendable, Hashable {
    public let displayName: String
    public let coordinate: GeoCoordinate
    public let current: CurrentWeatherSnapshot?
    public let hourly: [HourlyWeatherPoint]
    public let days: [ForecastDay]

    public init(
        displayName: String,
        coordinate: GeoCoordinate,
        current: CurrentWeatherSnapshot?,
        hourly: [HourlyWeatherPoint],
        days: [ForecastDay]
    ) {
        self.displayName = displayName
        self.coordinate = coordinate
        self.current = current
        self.hourly = hourly
        self.days = days
    }
}

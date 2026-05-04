//
//  WeatherRepositoryProtocol.swift
//  WeatherApp
//
//  Domain-level facade for retrieving a `CityWeatherForecast` either free-text (`cityQuery`)
//  or pinned to geographic coordinates (`at:displayName:`).
//

import Foundation

public protocol WeatherRepositoryProtocol: Sendable {
    func fetchWeather(
        cityQuery: String,
        completion: @escaping @Sendable (Result<CityWeatherForecast, WeatherAppError>) -> Void
    )

    func fetchWeather(
        at coordinate: GeoCoordinate,
        displayName: String,
        completion: @escaping @Sendable (Result<CityWeatherForecast, WeatherAppError>) -> Void
    )
}

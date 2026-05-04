//
//  WeatherRepositoryProtocol.swift
//  WeatherApp
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

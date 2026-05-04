//
//  FetchCityForecastUseCase.swift
//  WeatherApp
//
//  Validates user search input (trim, minimum length) before delegating to the repository,
//  so presenters don't need to reconstruct those rules.
//

import Foundation

/// Search-by-name facade used by SwiftUI presenters.
public protocol FetchCityForecastUseCaseProtocol: Sendable {
    func execute(
        cityQuery: String,
        completion: @escaping @Sendable (Result<CityWeatherForecast, WeatherAppError>) -> Void
    )
}

/// Default implementation wired from `WeatherDependencies.make()`.
public struct FetchCityForecastUseCase: FetchCityForecastUseCaseProtocol {
    private let repository: WeatherRepositoryProtocol
    private let minimumQueryLength: Int

    public init(repository: WeatherRepositoryProtocol, minimumQueryLength: Int = 1) {
        self.repository = repository
        self.minimumQueryLength = minimumQueryLength
    }

    public func execute(
        cityQuery: String,
        completion: @escaping @Sendable (Result<CityWeatherForecast, WeatherAppError>) -> Void
    ) {
        let trimmed = cityQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            completion(.failure(.emptySearchQuery))
            return
        }
        if trimmed.count < minimumQueryLength {
            completion(.failure(.searchQueryTooShort(minLength: minimumQueryLength)))
            return
        }
        repository.fetchWeather(cityQuery: trimmed, completion: completion)
    }
}

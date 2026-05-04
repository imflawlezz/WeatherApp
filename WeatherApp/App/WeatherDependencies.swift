//
//  WeatherDependencies.swift
//  WeatherApp
//

import Foundation

@MainActor
struct WeatherDependencies {
    let repository: WeatherRepositoryProtocol
    let location: LocationProviding
    let placeResolver: PlaceNameResolving
    let fetchCityForecast: FetchCityForecastUseCaseProtocol

    static func make() -> WeatherDependencies {
        let httpClient = URLSessionHTTPClient()
        let reachability = NetworkReachability()
        let repository = OpenMeteoWeatherRepository(
            httpClient: httpClient,
            reachability: reachability
        )
        let location = CoreLocationService()
        let placeResolver = CoreLocationPlaceResolver()
        let fetchCityForecast = FetchCityForecastUseCase(repository: repository, minimumQueryLength: 1)
        return WeatherDependencies(
            repository: repository,
            location: location,
            placeResolver: placeResolver,
            fetchCityForecast: fetchCityForecast
        )
    }
}

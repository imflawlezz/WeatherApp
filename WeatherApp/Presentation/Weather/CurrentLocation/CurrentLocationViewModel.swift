//
//  CurrentLocationViewModel.swift
//  WeatherApp
//

import Foundation

@MainActor
@Observable
final class CurrentLocationViewModel {
    var forecast: CityWeatherForecast?
    var isLoading = false
    var errorLocalizationKey: String?

    private let repository: WeatherRepositoryProtocol
    private let location: LocationProviding
    private let placeResolver: PlaceNameResolving

    init(
        repository: WeatherRepositoryProtocol,
        location: LocationProviding,
        placeResolver: PlaceNameResolving
    ) {
        self.repository = repository
        self.location = location
        self.placeResolver = placeResolver
    }

    func refresh(onComplete: (() -> Void)? = nil) {
        errorLocalizationKey = nil
        isLoading = true
        forecast = nil
        location.requestWhenInUseAuthorization()
        location.fetchCoordinate { [weak self] result in
            Task { @MainActor in
                guard let self else {
                    onComplete?()
                    return
                }
                switch result {
                case let .failure(error):
                    self.isLoading = false
                    self.errorLocalizationKey = error.localizationKey
                    onComplete?()
                case let .success(coordinate):
                    self.placeResolver.resolveDisplayLine(for: coordinate) { name in
                        self.repository.fetchWeather(at: coordinate, displayName: name) { res in
                            Task { @MainActor in
                                self.isLoading = false
                                switch res {
                                case let .success(model):
                                    self.forecast = model
                                case let .failure(err):
                                    self.errorLocalizationKey = err.localizationKey
                                }
                                onComplete?()
                            }
                        }
                    }
                }
            }
        }
    }
}

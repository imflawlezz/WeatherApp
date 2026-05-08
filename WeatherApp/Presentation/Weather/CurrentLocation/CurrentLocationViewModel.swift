//
//  CurrentLocationViewModel.swift
//  WeatherApp
//
//  Orchestrates authorization, a fresh coordinate, reverse geocoding, and repository fetch for
//  the GPS tab. Surfaced state is plain properties for `@Bindable` consumers.
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
    private var lastCoordinate: GeoCoordinate?

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
                    self.lastCoordinate = coordinate
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

    func refreshDisplayNameForCurrentCoordinate() {
        guard let lastCoordinate else { return }
        placeResolver.resolveDisplayLine(for: lastCoordinate) { [weak self] name in
            Task { @MainActor in
                guard let self, let old = self.forecast else { return }
                guard old.coordinate == lastCoordinate else { return }
                self.forecast = CityWeatherForecast(
                    displayName: name,
                    coordinate: old.coordinate,
                    current: old.current,
                    hourly: old.hourly,
                    days: old.days
                )
            }
        }
    }
}

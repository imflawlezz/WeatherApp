//
//  CitySearchViewModel.swift
//  WeatherApp
//

import Foundation

@MainActor
@Observable
final class CitySearchViewModel {
    var searchText: String = ""
    var forecast: CityWeatherForecast?
    var isLoading = false
    var errorLocalizationKey: String?

    private let fetchCityForecast: FetchCityForecastUseCaseProtocol
    private var lastAutoSearchHint: String?

    init(fetchCityForecast: FetchCityForecastUseCaseProtocol) {
        self.fetchCityForecast = fetchCityForecast
    }

    func applyDefaultCityHintIfNeeded() {
        let hint = UserDefaults.standard.string(forKey: AppStorageKeys.defaultCityHint) ?? ""
        guard !hint.isEmpty, searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        searchText = hint
    }

    func autoSearchIfPossible(usingDefaultCityHint hint: String) {
        let trimmed = hint.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !isLoading else { return }
        guard forecast == nil else { return }
        guard lastAutoSearchHint != trimmed else { return }
        lastAutoSearchHint = trimmed
        searchText = trimmed
        search()
    }

    func search(onComplete: (() -> Void)? = nil) {
        errorLocalizationKey = nil
        isLoading = true
        forecast = nil
        let query = searchText
        fetchCityForecast.execute(cityQuery: query) { [weak self] result in
            guard let vm = self else {
                Task { @MainActor in onComplete?() }
                return
            }
            Task { @MainActor in
                defer { onComplete?() }
                vm.isLoading = false
                switch result {
                case let .success(forecast):
                    vm.forecast = forecast
                case let .failure(error):
                    vm.errorLocalizationKey = error.localizationKey
                }
            }
        }
    }
}

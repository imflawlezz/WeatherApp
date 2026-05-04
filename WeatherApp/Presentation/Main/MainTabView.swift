//
//  MainTabView.swift
//  WeatherApp
//

import SwiftUI

struct MainTabView: View {
    let deps: WeatherDependencies

    @AppStorage(AppStorageKeys.temperatureUnit) private var temperatureUnitRaw = TemperatureUnit.metric.rawValue
    @Environment(\.locale) private var locale

    @State private var selection: RootTab = .here
    @State private var currentLocationModel: CurrentLocationViewModel
    @State private var citySearchModel: CitySearchViewModel

    private enum RootTab: Hashable {
        case here
        case search
        case settings
    }

    init(deps: WeatherDependencies) {
        self.deps = deps
        _currentLocationModel = State(
            wrappedValue: CurrentLocationViewModel(
                repository: deps.repository,
                location: deps.location,
                placeResolver: deps.placeResolver
            )
        )
        _citySearchModel = State(wrappedValue: CitySearchViewModel(fetchCityForecast: deps.fetchCityForecast))
    }

    private var temperatureUnit: TemperatureUnit {
        TemperatureUnit(rawValue: temperatureUnitRaw) ?? .metric
    }

    var body: some View {
        TabView(selection: $selection) {
            Tab(value: RootTab.here) {
                CurrentLocationTabRoot(viewModel: currentLocationModel)
            } label: {
                Label(WeatherL10n.string("tab.current", locale: locale), systemImage: "location.circle.fill")
            }

            Tab(value: RootTab.search, role: .search) {
                CitySearchTabRoot(viewModel: citySearchModel)
            } label: {
                Label(WeatherL10n.string("tab.search", locale: locale), systemImage: "magnifyingglass")
            }

            Tab(value: RootTab.settings) {
                SettingsView()
            } label: {
                Label(WeatherL10n.string("tab.settings", locale: locale), systemImage: "gearshape.fill")
            }
        }
        .environment(\.temperatureUnit, temperatureUnit)
    }
}

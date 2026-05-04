//
//  AppStorageKeys.swift
//  WeatherApp
//
//  Centralized `@AppStorage` / `UserDefaults` key strings to avoid typos across SwiftUI views.
//

import Foundation

enum AppStorageKeys {
    static let localeOverride = "weatherapp.localeOverride"
    static let temperatureUnit = "weatherapp.temperatureUnit"
    static let defaultCityHint = "weatherapp.defaultCityHint"
}

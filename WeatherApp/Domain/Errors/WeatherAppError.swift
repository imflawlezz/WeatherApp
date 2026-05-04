//
//  WeatherAppError.swift
//  WeatherApp
//
//  Cross-layer failure surface: networking, decoding, search validation, and location.
//  UI maps these to string catalog keys via `WeatherAppError.localizationKey`.
//

import Foundation

public enum WeatherAppError: Error, Sendable, Equatable {
    case emptySearchQuery
    case searchQueryTooShort(minLength: Int)
    case notConnectedToInternet
    case invalidResponse
    case decodingFailed
    case noLocationResults
    case noForecastData
    case httpStatus(code: Int)
    case locationDenied
    case locationUnavailable
}

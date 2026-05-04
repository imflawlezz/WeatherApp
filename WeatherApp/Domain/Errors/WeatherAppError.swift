//
//  WeatherAppError.swift
//  WeatherApp
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

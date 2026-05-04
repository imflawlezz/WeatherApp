//
//  WeatherAppError+UserText.swift
//  WeatherApp
//

import Foundation

extension WeatherAppError {
    var localizationKey: String {
        switch self {
        case .emptySearchQuery:
            return "error.empty_query"
        case .searchQueryTooShort:
            return "error.query_too_short"
        case .notConnectedToInternet:
            return "error.offline"
        case .invalidResponse:
            return "error.invalid_response"
        case .decodingFailed:
            return "error.decoding"
        case .noLocationResults:
            return "error.no_city"
        case .noForecastData:
            return "error.no_forecast"
        case .httpStatus:
            return "error.http"
        case .locationDenied:
            return "error.location_denied"
        case .locationUnavailable:
            return "error.location_unavailable"
        }
    }
}

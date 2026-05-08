//
//  OpenMeteoAPI.swift
//  WeatherApp
//
//  URL construction for Open-Meteo's geocoding service and consolidated forecast endpoint.
//

import Foundation

enum OpenMeteoAPI {
    // MARK: - Geocoding

    static func geocodeURL(query: String, language: String?) -> URL? {
        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        var items: [URLQueryItem] = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: "1"),
            URLQueryItem(name: "format", value: "json"),
        ]
        if let language, !language.isEmpty {
            items.append(URLQueryItem(name: "language", value: language))
        } else {
            items.append(URLQueryItem(name: "language", value: "en"))
        }
        components?.queryItems = items
        return components?.url
    }

    // MARK: - Forecast

    static func forecastURL(coordinate: GeoCoordinate) -> URL? {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(
                name: "current",
                value: "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m,pressure_msl"
            ),
            URLQueryItem(name: "hourly", value: "temperature_2m,weather_code"),
            URLQueryItem(
                name: "daily",
                value: "weathercode,temperature_2m_max,temperature_2m_min,precipitation_sum,apparent_temperature_max,relative_humidity_2m_max,windspeed_10m_max,winddirection_10m_dominant,pressure_msl_max,sunrise,sunset"
            ),
            URLQueryItem(name: "forecast_days", value: "7"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "windspeed_unit", value: "kmh"),
        ]
        return components?.url
    }
}

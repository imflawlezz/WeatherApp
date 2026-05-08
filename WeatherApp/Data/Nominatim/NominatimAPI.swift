//
//  NominatimAPI.swift
//  WeatherApp
//
//  Reverse geocoding via OpenStreetMap Nominatim (no API key).
//

import Foundation

enum NominatimAPI {
    static func reverseURL(coordinate: GeoCoordinate, language: String?) -> URL? {
        var components = URLComponents(string: "https://nominatim.openstreetmap.org/reverse")
        var items: [URLQueryItem] = [
            URLQueryItem(name: "format", value: "jsonv2"),
            URLQueryItem(name: "lat", value: String(coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(coordinate.longitude)),
            URLQueryItem(name: "zoom", value: "10"),
            URLQueryItem(name: "addressdetails", value: "1"),
        ]
        if let language, !language.isEmpty {
            items.append(URLQueryItem(name: "accept-language", value: language))
        }
        components?.queryItems = items
        return components?.url
    }
}


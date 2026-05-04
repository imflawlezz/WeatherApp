//
//  OpenMeteoGeocodeDTO.swift
//  WeatherApp
//
//  Geocoding search results (`/v1/search`). `results` may be null/empty when nothing matches.
//

import Foundation

struct OpenMeteoGeocodeDTO: Decodable {
    let results: [OpenMeteoGeocodeResultDTO]?
}

// MARK: - Result row

struct OpenMeteoGeocodeResultDTO: Decodable {
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
}

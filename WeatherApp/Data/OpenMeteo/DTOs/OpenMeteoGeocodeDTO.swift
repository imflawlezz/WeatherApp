//
//  OpenMeteoGeocodeDTO.swift
//  WeatherApp
//

import Foundation

struct OpenMeteoGeocodeDTO: Decodable {
    let results: [OpenMeteoGeocodeResultDTO]?
}

struct OpenMeteoGeocodeResultDTO: Decodable {
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
}

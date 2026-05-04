//
//  GeoCoordinate.swift
//  WeatherApp
//
//  Shared latitude/longitude value type for repository + mapping layers.
//

import Foundation

public struct GeoCoordinate: Sendable, Hashable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

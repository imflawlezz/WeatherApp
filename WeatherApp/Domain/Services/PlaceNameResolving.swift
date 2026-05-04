//
//  PlaceNameResolving.swift
//  WeatherApp
//
//  Human-readable place line for a coordinate (used as `CityWeatherForecast.displayName`
//  on the "current location" path).
//

import Foundation

@MainActor
public protocol PlaceNameResolving: AnyObject {
    func resolveDisplayLine(for coordinate: GeoCoordinate, completion: @escaping (String) -> Void)
}

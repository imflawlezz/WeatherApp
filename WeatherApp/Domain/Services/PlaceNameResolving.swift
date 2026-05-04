//
//  PlaceNameResolving.swift
//  WeatherApp
//

import Foundation

@MainActor
public protocol PlaceNameResolving: AnyObject {
    func resolveDisplayLine(for coordinate: GeoCoordinate, completion: @escaping (String) -> Void)
}

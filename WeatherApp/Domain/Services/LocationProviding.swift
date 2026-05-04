//
//  LocationProviding.swift
//  WeatherApp
//

import Foundation

@MainActor
public protocol LocationProviding: AnyObject {
    func requestWhenInUseAuthorization()
    func fetchCoordinate(completion: @escaping (Result<GeoCoordinate, WeatherAppError>) -> Void)
}

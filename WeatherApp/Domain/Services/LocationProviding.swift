//
//  LocationProviding.swift
//  WeatherApp
//
//  Lightweight abstraction around Core Location authorization + a best-effort GPS fix,
//  expressed as typed `WeatherAppError` outcomes for the caller.
//

import Foundation

@MainActor
public protocol LocationProviding: AnyObject {
    func requestWhenInUseAuthorization()
    func fetchCoordinate(completion: @escaping (Result<GeoCoordinate, WeatherAppError>) -> Void)
}

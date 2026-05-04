//
//  CoreLocationService.swift
//  WeatherApp
//
//  `LocationProviding` via `CLLocationManager`: resolves permission churn and one-shot fixes
//  on the main actor while satisfying delegate concurrency requirements (`nonisolated`).
//

import CoreLocation
import Foundation

@MainActor
final class CoreLocationService: NSObject, LocationProviding, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var coordinateCompletion: ((Result<GeoCoordinate, WeatherAppError>) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    // MARK: - LocationProviding

    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func fetchCoordinate(completion: @escaping (Result<GeoCoordinate, WeatherAppError>) -> Void) {
        coordinateCompletion = completion
        switch manager.authorizationStatus {
        case .denied, .restricted:
            completion(.failure(.locationDenied))
            coordinateCompletion = nil
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        @unknown default:
            completion(.failure(.locationUnavailable))
            coordinateCompletion = nil
        }
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else {
                self.coordinateCompletion?(.failure(.locationUnavailable))
                self.coordinateCompletion = nil
                return
            }
            let coord = GeoCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.coordinateCompletion?(.success(coord))
            self.coordinateCompletion = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError _: Error) {
        Task { @MainActor in
            self.coordinateCompletion?(.failure(.locationUnavailable))
            self.coordinateCompletion = nil
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                if self.coordinateCompletion != nil {
                    self.manager.requestLocation()
                }
            case .denied, .restricted:
                self.coordinateCompletion?(.failure(.locationDenied))
                self.coordinateCompletion = nil
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
}

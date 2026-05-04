//
//  CoreLocationPlaceResolver.swift
//  WeatherApp
//

import CoreLocation
import Foundation
import MapKit

@MainActor
final class CoreLocationPlaceResolver: PlaceNameResolving {
    func resolveDisplayLine(for coordinate: GeoCoordinate, completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        Task { @MainActor in
            let fallback = String(localized: String.LocalizationValue("location.place_fallback"))
            guard let request = MKReverseGeocodingRequest(location: location) else {
                completion(fallback)
                return
            }
            do {
                let mapItems = try await request.mapItems
                guard let address = mapItems.first?.address else {
                    completion(fallback)
                    return
                }
                if let short = address.shortAddress, !short.isEmpty {
                    completion(short)
                } else if !address.fullAddress.isEmpty {
                    completion(address.fullAddress)
                } else {
                    completion(fallback)
                }
            } catch {
                completion(fallback)
            }
        }
    }
}

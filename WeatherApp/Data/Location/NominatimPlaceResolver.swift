//
//  NominatimPlaceResolver.swift
//  WeatherApp
//
//  Reverse-geocodes coordinates through OpenStreetMap Nominatim. This allows requesting a
//  response language via `accept-language`, which Apple reverse geocoding does not expose on iOS 26+.
//

import Foundation

@MainActor
final class NominatimPlaceResolver: PlaceNameResolving, @unchecked Sendable {
    private let httpClient: HTTPClientProtocol

    init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }

    func resolveDisplayLine(for coordinate: GeoCoordinate, completion: @escaping (String) -> Void) {
        let fallback = String(localized: String.LocalizationValue("location.place_fallback"))
        guard let url = NominatimAPI.reverseURL(coordinate: coordinate, language: preferredLanguageIdentifier()) else {
            completion(fallback)
            return
        }

        httpClient.get(url: url) { result in
            Task { @MainActor in
                switch result {
                case .failure:
                    completion(fallback)
                case let .success((data, _)):
                    do {
                        let dto = try JSONDecoder().decode(NominatimReverseDTO.self, from: data)
                        if let name = self.displayName(from: dto), !name.isEmpty {
                            completion(name)
                        } else {
                            completion(fallback)
                        }
                    } catch {
                        completion(fallback)
                    }
                }
            }
        }
    }

    private func preferredLanguageIdentifier() -> String? {
        let override = UserDefaults.standard.string(forKey: AppStorageKeys.localeOverride) ?? ""
        if !override.isEmpty { return override }
        return Bundle.main.preferredLocalizations.first
    }

    private func displayName(from dto: NominatimReverseDTO) -> String? {
        if let address = dto.address {
            let locality = [address.city, address.town, address.village, address.hamlet, address.municipality]
                .compactMap { $0 }
                .first
            let admin = address.state ?? address.county
            let country = address.country
            let short = [locality, admin, country].compactMap { $0 }.joined(separator: ", ")
            if !short.isEmpty { return short }
        }
        return dto.displayName
    }
}


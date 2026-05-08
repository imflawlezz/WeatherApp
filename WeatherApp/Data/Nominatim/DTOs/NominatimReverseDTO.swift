//
//  NominatimReverseDTO.swift
//  WeatherApp
//
//  Minimal subset of Nominatim reverse response used for display naming.
//

import Foundation

struct NominatimReverseDTO: Decodable {
    let displayName: String?
    let address: Address?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case address
    }

    struct Address: Decodable {
        let city: String?
        let town: String?
        let village: String?
        let hamlet: String?
        let municipality: String?
        let county: String?
        let state: String?
        let country: String?
        let countryCode: String?

        enum CodingKeys: String, CodingKey {
            case city, town, village, hamlet, municipality, county, state, country
            case countryCode = "country_code"
        }
    }
}


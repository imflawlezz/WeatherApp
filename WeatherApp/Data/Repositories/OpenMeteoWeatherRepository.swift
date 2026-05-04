//
//  OpenMeteoWeatherRepository.swift
//  WeatherApp
//

import Foundation

final class OpenMeteoWeatherRepository: WeatherRepositoryProtocol, @unchecked Sendable {
    private let httpClient: HTTPClientProtocol
    private let reachability: NetworkReachabilityProtocol

    init(
        httpClient: HTTPClientProtocol,
        reachability: NetworkReachabilityProtocol
    ) {
        self.httpClient = httpClient
        self.reachability = reachability
    }

    func fetchWeather(
        cityQuery: String,
        completion: @escaping @Sendable (Result<CityWeatherForecast, WeatherAppError>) -> Void
    ) {
        guard reachability.isReachable() else {
            completion(.failure(.notConnectedToInternet))
            return
        }
        guard let geocodeURL = OpenMeteoAPI.geocodeURL(query: cityQuery) else {
            completion(.failure(.invalidResponse))
            return
        }

        httpClient.get(url: geocodeURL) { [httpClient] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success((data, _)):
                Task { @MainActor in
                    let decoder = Self.makeDecoder()
                    do {
                        let geo = try decoder.decode(OpenMeteoGeocodeDTO.self, from: data)
                        guard let first = geo.results?.first else {
                            completion(.failure(.noLocationResults))
                            return
                        }
                        let coordinate = GeoCoordinate(latitude: first.latitude, longitude: first.longitude)
                        let cityLine: String
                        if let country = first.country, !country.isEmpty {
                            cityLine = "\(first.name), \(country)"
                        } else {
                            cityLine = first.name
                        }
                        Self.requestForecast(
                            httpClient: httpClient,
                            coordinate: coordinate,
                            displayName: cityLine,
                            completion: completion
                        )
                    } catch {
                        completion(.failure(.decodingFailed))
                    }
                }
            }
        }
    }

    func fetchWeather(
        at coordinate: GeoCoordinate,
        displayName: String,
        completion: @escaping @Sendable (Result<CityWeatherForecast, WeatherAppError>) -> Void
    ) {
        guard reachability.isReachable() else {
            completion(.failure(.notConnectedToInternet))
            return
        }
        Self.requestForecast(
            httpClient: httpClient,
            coordinate: coordinate,
            displayName: displayName,
            completion: completion
        )
    }

    private static func requestForecast(
        httpClient: HTTPClientProtocol,
        coordinate: GeoCoordinate,
        displayName: String,
        completion: @escaping @Sendable (Result<CityWeatherForecast, WeatherAppError>) -> Void
    ) {
        guard let forecastURL = OpenMeteoAPI.forecastURL(coordinate: coordinate) else {
            completion(.failure(.invalidResponse))
            return
        }

        httpClient.get(url: forecastURL) { result2 in
            Task { @MainActor in
                let decoder2 = Self.makeDecoder()
                switch result2 {
                case let .failure(error):
                    completion(.failure(error))
                case let .success((data2, _)):
                    do {
                        let forecastDTO = try decoder2.decode(OpenMeteoForecastDTO.self, from: data2)
                        let model = try OpenMeteoForecastMapper.mapWeatherForecast(
                            displayName: displayName,
                            coordinate: coordinate,
                            dto: forecastDTO
                        )
                        completion(.success(model))
                    } catch let error as WeatherAppError {
                        completion(.failure(error))
                    } catch {
                        completion(.failure(.decodingFailed))
                    }
                }
            }
        }
    }

    private static func makeDecoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .useDefaultKeys
        return d
    }
}

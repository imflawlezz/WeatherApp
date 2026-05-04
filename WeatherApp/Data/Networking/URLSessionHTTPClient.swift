//
//  URLSessionHTTPClient.swift
//  WeatherApp
//
//  Minimal anonymous GET abstraction over `URLSession`; maps failures to `WeatherAppError`.
//

import Foundation

protocol HTTPClientProtocol: Sendable {
    func get(
        url: URL,
        completion: @escaping @Sendable (Result<(Data, HTTPURLResponse), WeatherAppError>) -> Void
    )
}

final class URLSessionHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(
        url: URL,
        completion: @escaping @Sendable (Result<(Data, HTTPURLResponse), WeatherAppError>) -> Void
    ) {
        let task = session.dataTask(with: url) { data, response, _ in
            guard let data else {
                completion(.failure(.invalidResponse))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            guard (200 ... 299).contains(http.statusCode) else {
                completion(.failure(.httpStatus(code: http.statusCode)))
                return
            }
            completion(.success((data, http)))
        }
        task.resume()
    }
}

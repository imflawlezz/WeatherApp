//
//  NetworkReachability.swift
//  WeatherApp
//
//  Wraps `NWPathMonitor` for a synchronous "path satisfied?" check before network work.
//

import Foundation
import Network

protocol NetworkReachabilityProtocol: Sendable {
    func isReachable() -> Bool
}

final class NetworkReachability: NetworkReachabilityProtocol, @unchecked Sendable {
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "dev.imflawlezz.WeatherApp.reachability")
    private var satisfied = true

    init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            self?.satisfied = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    func isReachable() -> Bool {
        var value = false
        queue.sync { value = satisfied }
        return value
    }
}

//
//  WeatherAppApp.swift
//  WeatherApp
//

import SwiftUI

@main
struct WeatherAppApp: App {
    @State private var deps = WeatherDependencies.make()
    @AppStorage(AppStorageKeys.localeOverride) private var localeOverride = ""

    init() {
        UserDefaults.standard.register(defaults: ["UseFloatingTabBar": false])
    }

    var body: some Scene {
        WindowGroup {
            RootView(deps: deps)
                .environment(\.locale, localeForOverride(localeOverride))
        }
    }

    private func localeForOverride(_ id: String) -> Locale {
        if id.isEmpty {
            return Locale.autoupdatingCurrent
        }
        return Locale(identifier: id)
    }
}

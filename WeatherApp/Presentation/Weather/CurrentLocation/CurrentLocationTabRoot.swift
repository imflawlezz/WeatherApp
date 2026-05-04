//
//  CurrentLocationTabRoot.swift
//  WeatherApp
//

import SwiftUI

struct CurrentLocationTabRoot: View {
    @Bindable var viewModel: CurrentLocationViewModel

    @Environment(\.locale) private var locale

    var body: some View {
        NavigationStack {
            WeatherPageContentView(
                forecast: viewModel.forecast,
                isLoading: viewModel.isLoading,
                errorLocalizationKey: viewModel.errorLocalizationKey
            )
            .navigationTitle(WeatherL10n.string("tab.current", locale: locale))
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    viewModel.refresh {
                        continuation.resume()
                    }
                }
            }
            .navigationDestination(for: ForecastDay.self) { day in
                DayDetailView(day: day)
            }
        }
        .task {
            if viewModel.forecast == nil, !viewModel.isLoading {
                viewModel.refresh()
            }
        }
    }
}

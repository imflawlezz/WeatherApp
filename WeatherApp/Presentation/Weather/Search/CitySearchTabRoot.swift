//
//  CitySearchTabRoot.swift
//  WeatherApp
//

import SwiftUI

struct CitySearchTabRoot: View {
    @Bindable var viewModel: CitySearchViewModel
    @AppStorage(AppStorageKeys.defaultCityHint) private var defaultCityHint = ""

    @Environment(\.locale) private var locale

    var body: some View {
        NavigationStack {
            WeatherPageContentView(
                forecast: viewModel.forecast,
                isLoading: viewModel.isLoading,
                errorLocalizationKey: viewModel.errorLocalizationKey,
                showsSearchEmptyState: true
            )
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture { dismissKeyboard() }
            .navigationTitle(WeatherL10n.string("tab.search", locale: locale))
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                placement: .automatic,
                prompt: Text(verbatim: WeatherL10n.string("search.prompt", locale: locale))
            )
            .searchToolbarBehavior(.minimize)
            .onSubmit(of: .search) {
                viewModel.search()
            }
            .refreshable {
                let trimmed = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    viewModel.search {
                        continuation.resume()
                    }
                }
            }
            .navigationDestination(for: ForecastDay.self) { day in
                DayDetailView(day: day)
            }
        }
        .onAppear {
            viewModel.applyDefaultCityHintIfNeeded()
            viewModel.autoSearchIfPossible(usingDefaultCityHint: defaultCityHint)
        }
        .onChange(of: defaultCityHint) { _, newValue in
            viewModel.autoSearchIfPossible(usingDefaultCityHint: newValue)
        }
    }

    private func dismissKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}

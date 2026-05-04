//
//  SettingsView.swift
//  WeatherApp
//
//  User-facing preferences (`AppStorage`): language override, temperature units, default search
//  hint, plus a keyboard "Done" shortcut for the city field.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @AppStorage(AppStorageKeys.localeOverride) private var localeOverride = ""
    @AppStorage(AppStorageKeys.temperatureUnit) private var temperatureUnitRaw = TemperatureUnit.metric.rawValue
    @AppStorage(AppStorageKeys.defaultCityHint) private var defaultCityHint = ""

    @Environment(\.locale) private var locale
    @FocusState private var defaultCityFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $localeOverride) {
                        Text(WeatherL10n.string("settings.language.system", locale: locale)).tag("")
                        Text(WeatherL10n.string("settings.language.en", locale: locale)).tag("en")
                        Text(WeatherL10n.string("settings.language.de", locale: locale)).tag("de")
                        Text(WeatherL10n.string("settings.language.nb", locale: locale)).tag("nb")
                        Text(WeatherL10n.string("settings.language.pl", locale: locale)).tag("pl")
                        Text(WeatherL10n.string("settings.language.ru", locale: locale)).tag("ru")
                    } label: {
                        Label(WeatherL10n.string("settings.language", locale: locale), systemImage: "globe")
                    }
                }

                Section {
                    Picker(WeatherL10n.string("settings.temperature", locale: locale), selection: $temperatureUnitRaw) {
                        Text(WeatherL10n.string("settings.temperature.metric", locale: locale))
                            .tag(TemperatureUnit.metric.rawValue)
                        Text(WeatherL10n.string("settings.temperature.imperial", locale: locale))
                            .tag(TemperatureUnit.imperial.rawValue)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text(WeatherL10n.string("settings.section.units", locale: locale))
                }

                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "text.magnifyingglass")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        TextField(WeatherL10n.string("settings.default_city.placeholder", locale: locale), text: $defaultCityHint)
                            .textInputAutocapitalization(.words)
                            .focused($defaultCityFocused)
                    }
                } header: {
                    Text(WeatherL10n.string("settings.section.search", locale: locale))
                }

                Section {
                    LabeledContent(WeatherL10n.string("settings.version", locale: locale), value: "1.0")
                } header: {
                    Text(WeatherL10n.string("settings.section.about", locale: locale))
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                if defaultCityFocused {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer(minLength: 0)
                        Button(WeatherL10n.string("keyboard.done", locale: locale)) {
                            defaultCityFocused = false
                            dismissKeyboardIfNeeded()
                        }
                    }
                }
            }
            .navigationTitle(WeatherL10n.string("tab.settings", locale: locale))
        }
    }

    private func dismissKeyboardIfNeeded() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

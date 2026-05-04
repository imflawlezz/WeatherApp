//
//  DayDetailView.swift
//  WeatherApp
//

import SwiftUI

struct DayDetailView: View {
    let day: ForecastDay

    @Environment(\.temperatureUnit) private var temperatureUnit
    @Environment(\.locale) private var locale

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(verbatim: WeatherL10n.capitalizeFirstLetter(
                    in: WeatherL10n.titleStyleDateSubstringAfterComma(
                        in: day.date.formatted(Date.FormatStyle(date: .complete, time: .omitted).locale(locale)),
                        locale: locale
                    ),
                    locale: locale
                ))
                    .font(.headline)
                    .foregroundStyle(.secondary)

                headerCard

                detailsCard
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle(WeatherL10n.string("detail.title", locale: locale))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            WeatherSymbol(systemName: day.summary.conditionSymbolName, size: 34, square: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: WeatherL10n.string(day.detail.conditionDescriptionKey, locale: locale))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(
                    String(
                        format: WeatherL10n.string("weather.hero.hilo", locale: locale),
                        locale: locale,
                        arguments: [
                            WeatherFormatters.temperature(day.summary.tempMinCelsius, unit: temperatureUnit) as CVarArg,
                            WeatherFormatters.temperature(day.summary.tempMaxCelsius, unit: temperatureUnit) as CVarArg
                        ]
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text(
                    String(
                        format: WeatherL10n.string("weather.hero.feels", locale: locale),
                        locale: locale,
                        arguments: [temperatureString(day.detail.feelsLikeMaxCelsius) as CVarArg]
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            row(
                icon: "cloud.rain.fill",
                title: WeatherL10n.string("detail.precipitation", locale: locale),
                value: String(
                    format: WeatherL10n.string("detail.precipitation.value", locale: locale),
                    locale: locale,
                    arguments: [day.summary.precipitationMm as CVarArg]
                )
            )
            Divider().padding(.leading, 44)
            row(
                icon: "humidity.fill",
                title: WeatherL10n.string("detail.humidity", locale: locale),
                value: String(
                    format: WeatherL10n.string("detail.humidity.value", locale: locale),
                    locale: locale,
                    arguments: [Int(day.detail.humidityPercent.rounded()) as CVarArg]
                )
            )
            Divider().padding(.leading, 44)
            windRow
            Divider().padding(.leading, 44)
            row(
                icon: "gauge.with.dots.needle.67percent",
                title: WeatherL10n.string("detail.pressure", locale: locale),
                value: String(
                    format: WeatherL10n.string("detail.pressure.value", locale: locale),
                    locale: locale,
                    arguments: [Int(day.detail.pressureHectopascals.rounded()) as CVarArg]
                )
            )

            if let sunrise = day.detail.sunrise, let sunset = day.detail.sunset {
                Divider().padding(.leading, 44)
                row(
                    icon: "sun.horizon.fill",
                    title: WeatherL10n.string("detail.sun", locale: locale),
                    value: String(
                        format: WeatherL10n.string("detail.sun.short", locale: locale),
                        locale: locale,
                        arguments: [
                            formattedTime(sunrise) as CVarArg,
                            formattedTime(sunset) as CVarArg
                        ]
                    )
                )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
    }

    private var windRow: some View {
        let directionKey = WindDirectionFormatter.localizationKey(degrees: day.detail.windDirectionDegrees)
        let directionText = WeatherL10n.string(directionKey, locale: locale)
        let speedText = WeatherFormatters.speedKmh(day.detail.windSpeedKmh, unit: temperatureUnit)
        return HStack(spacing: 10) {
            Image(systemName: "wind")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
                .frame(width: 26)

            Text(WeatherL10n.string("detail.wind", locale: locale))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer(minLength: 8)

            HStack(spacing: 6) {
                Text(speedText)
                Image(systemName: WindDirectionFormatter.arrowSymbolName(degrees: day.detail.windDirectionDegrees))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(directionText)
                    .foregroundStyle(.secondary)
            }
            .font(.body.weight(.medium))
            .foregroundStyle(.primary)
        }
        .padding(.vertical, 10)
    }

    private func row(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
                .frame(width: 26)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer(minLength: 8)
            Text(value)
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 10)
    }

    private func formattedTime(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .omitted, time: .shortened).locale(locale))
    }

    private func temperatureString(_ celsius: Double) -> String {
        WeatherFormatters.temperature(celsius, unit: temperatureUnit)
    }
}

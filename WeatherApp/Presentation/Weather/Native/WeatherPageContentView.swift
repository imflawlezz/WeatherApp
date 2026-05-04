//
//  WeatherPageContentView.swift
//  WeatherApp
//
//  Shared scrolling weather layout for both main tabs (GPS and search).
//  Owns placeholder/shimmer loading, offline/error placeholders, grouped sections,
//  and hourly sun markers derived from today's sunrise/sunset.
//

import SwiftUI

// MARK: - WeatherPageContentView

struct WeatherPageContentView: View {
    let forecast: CityWeatherForecast?
    let isLoading: Bool
    let errorLocalizationKey: String?
    var showsSearchEmptyState: Bool = false

    @Environment(\.temperatureUnit) private var tempUnit
    @Environment(\.locale) private var locale

    // MARK: - Body

    var body: some View {
        Group {
            if isLoading, forecast == nil {
                ScrollView {
                    let placeholder = Self.placeholderForecast
                    VStack(alignment: .leading, spacing: 20) {
                        hero(for: placeholder)
                        hourlySection(for: placeholder)
                        metricsSection(for: placeholder)
                        dailySection(for: placeholder)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                }
                .redacted(reason: .placeholder)
                .shimmer(true)
                .disabled(true)
            } else if let errorLocalizationKey, forecast == nil {
                ScrollView {
                    ContentUnavailableView {
                        Label {
                            Text(verbatim: WeatherL10n.string("weather.empty.error_title", locale: locale))
                        } icon: {
                            Image(systemName: "icloud.slash")
                        }
                    } description: {
                        Text(verbatim: WeatherL10n.string(errorLocalizationKey, locale: locale))
                    }
                    .frame(maxWidth: .infinity, minHeight: 520)
                }
            } else if let forecast {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        hero(for: forecast)
                        hourlySection(for: forecast)
                        metricsSection(for: forecast)
                        dailySection(for: forecast)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                }
                .redacted(reason: isLoading ? .placeholder : [])
                .shimmer(isLoading)
                .disabled(isLoading)
            } else {
                if showsSearchEmptyState {
                    ScrollView {
                        ContentUnavailableView {
                            Label {
                                Text(verbatim: WeatherL10n.string("search.empty.title", locale: locale))
                            } icon: {
                                Image(systemName: "magnifyingglass")
                            }
                        } description: {
                            Text(verbatim: WeatherL10n.string("search.empty.detail", locale: locale))
                        }
                        .frame(maxWidth: .infinity, minHeight: 520)
                    }
                } else {
                    ScrollView {
                        ContentUnavailableView {
                            Label {
                                Text(verbatim: WeatherL10n.string("weather.empty.prompt_title", locale: locale))
                            } icon: {
                                Image(systemName: "location.magnifyingglass")
                            }
                        } description: {
                            Text(verbatim: WeatherL10n.string("weather.empty.prompt_detail", locale: locale))
                        }
                        .frame(maxWidth: .infinity, minHeight: 520)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Sections

    @ViewBuilder
    private func hero(for forecast: CityWeatherForecast) -> some View {
        let current = forecast.current
        let today = forecast.days.first
        VStack(spacing: 10) {
            Text(verbatim: forecast.displayName)
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity)

            WeatherSymbol(
                systemName: current?.conditionSymbolName ?? today?.summary.conditionSymbolName ?? "cloud.sun.fill",
                size: 64,
                square: 76
            )

            if let current {
                Text(WeatherFormatters.temperature(current.temperatureCelsius, unit: tempUnit))
                    .font(.system(size: 56, weight: .thin, design: .rounded))
                    .minimumScaleFactor(0.5)
                Text(verbatim: "\(WeatherL10n.string("weather.hero.feels_prefix", locale: locale)) \(WeatherFormatters.temperature(current.apparentTemperatureCelsius, unit: tempUnit))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if let today = forecast.days.first {
                Text(WeatherFormatters.temperature(today.summary.tempMaxCelsius, unit: tempUnit))
                    .font(.system(size: 56, weight: .thin, design: .rounded))
                    .minimumScaleFactor(0.5)
            }

            if let today = forecast.days.first {
                Text(verbatim: "\(WeatherL10n.string("weather.hero.min", locale: locale)) \(WeatherFormatters.temperature(today.summary.tempMinCelsius, unit: tempUnit)) · \(WeatherL10n.string("weather.hero.max", locale: locale)) \(WeatherFormatters.temperature(today.summary.tempMaxCelsius, unit: tempUnit))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let current {
                Text(verbatim: WeatherL10n.string(current.conditionDescriptionKey, locale: locale))
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
            } else if let today = forecast.days.first {
                Text(verbatim: WeatherL10n.string(today.detail.conditionDescriptionKey, locale: locale))
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func hourlySection(for forecast: CityWeatherForecast) -> some View {
        if forecast.hourly.isEmpty {
            EmptyView()
        } else {
            let sunWindow = todaySunWindow(for: forecast)
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: WeatherL10n.string("weather.section.hourly", locale: locale))
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                ScrollView(.horizontal, showsIndicators: false) {
                    let cellWidth: CGFloat = 56
                    let cellSpacing: CGFloat = 14
                    let horizontalPadding: CGFloat = 12
                    let cardHeight: CGFloat = 96

                    let items = buildHourlyItems(hours: forecast.hourly, sunWindow: sunWindow)
                    HStack(spacing: cellSpacing) {
                        ForEach(items) { item in
                            hourlyCell(item: item, sunWindow: sunWindow)
                                .frame(width: cellWidth)
                                .padding(.vertical, 10)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .frame(height: cardHeight)
                }
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
            }
        }
    }

    @ViewBuilder
    private func metricsSection(for forecast: CityWeatherForecast) -> some View {
        if let current = forecast.current {
            let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: WeatherL10n.string("weather.section.details", locale: locale))
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                LazyVGrid(columns: columns, spacing: 12) {
                    metricCard(icon: "humidity.fill", titleKey: "detail.humidity") {
                        Text(
                            String(
                                format: WeatherL10n.string("detail.humidity.value", locale: locale),
                                locale: locale,
                                arguments: [Int(current.humidityPercent.rounded()) as CVarArg]
                            )
                        )
                    }

                    metricCard(icon: "cloud.rain.fill", titleKey: "detail.precipitation") {
                        Text(
                            String(
                                format: WeatherL10n.string("detail.precipitation.value", locale: locale),
                                locale: locale,
                                arguments: [current.precipitationMm as CVarArg]
                            )
                        )
                    }

                    metricCard(icon: "wind", titleKey: "detail.wind") {
                        let directionKey = WindDirectionFormatter.localizationKey(degrees: current.windDirectionDegrees)
                        let directionText = WeatherL10n.string(directionKey, locale: locale)
                        HStack(spacing: 6) {
                            Text(WeatherFormatters.speedKmh(current.windSpeedKmh, unit: tempUnit))
                            Image(systemName: WindDirectionFormatter.arrowSymbolName(degrees: current.windDirectionDegrees))
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(directionText)
                                .foregroundStyle(.secondary)
                        }
                    }

                    metricCard(icon: "gauge.with.dots.needle.67percent", titleKey: "detail.pressure") {
                        Text(
                            String(
                                format: WeatherL10n.string("detail.pressure.value", locale: locale),
                                locale: locale,
                                arguments: [Int(current.pressureHpa.rounded()) as CVarArg]
                            )
                        )
                    }
                }
            }
        }
    }

    // MARK: - Metric tile

    private func metricCard<V: View>(icon: String, titleKey: String, @ViewBuilder value: () -> V) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.secondary)

            Text(verbatim: WeatherL10n.string(titleKey, locale: locale))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            value()
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.85)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
    }

    @ViewBuilder
    private func dailySection(for forecast: CityWeatherForecast) -> some View {
        let weekMin = forecast.days.map(\.summary.tempMinCelsius).min() ?? 0
        let weekMax = forecast.days.map(\.summary.tempMaxCelsius).max() ?? 1
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: WeatherL10n.string("weather.section.daily", locale: locale))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            VStack(spacing: 0) {
                ForEach(forecast.days) { day in
                    NavigationLink(value: day) {
                        HStack(spacing: 12) {
                            Text(day.date.formatted(Date.FormatStyle().weekday(.abbreviated).day().locale(locale)))
                                .font(.body.weight(.medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .frame(width: 72, alignment: .leading)
                            VStack(spacing: 2) {
                                WeatherSymbol(systemName: day.summary.conditionSymbolName, size: 18, square: 24)
                                if day.summary.precipitationMm >= 0.2 {
                                    Text(
                                        String(
                                            format: WeatherL10n.string("weather.forecast.precipitation_mm", locale: locale),
                                            locale: locale,
                                            arguments: [day.summary.precipitationMm as CVarArg]
                                        )
                                    )
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.blue)
                                        .minimumScaleFactor(0.85)
                                        .lineLimit(1)
                                }
                            }
                            .frame(minWidth: 48, alignment: .top)
                            Text(WeatherFormatters.temperature(day.summary.tempMinCelsius, unit: tempUnit))
                                .font(.body)
                                .foregroundStyle(.secondary)
                            temperatureRangeBar(
                                dayMin: day.summary.tempMinCelsius,
                                dayMax: day.summary.tempMaxCelsius,
                                weekMin: weekMin,
                                weekMax: weekMax
                            )
                            .frame(maxWidth: .infinity)
                            Text(WeatherFormatters.temperature(day.summary.tempMaxCelsius, unit: tempUnit))
                                .font(.body.weight(.medium))
                                .foregroundStyle(.primary)
                                .frame(minWidth: 36, alignment: .trailing)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if day.id != forecast.days.last?.id {
                        Divider().padding(.leading, 84)
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
        }
    }

    // MARK: - Week temperature bar

    private func temperatureRangeBar(dayMin: Double, dayMax: Double, weekMin: Double, weekMax: Double) -> some View {
        let span = max(1, weekMax - weekMin)
        let start = (dayMin - weekMin) / span
        let end = (dayMax - weekMin) / span
        return GeometryReader { geo in
            let width = geo.size.width
            let left = max(0, min(width, width * start))
            let right = max(0, min(width, width * end))
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(Color.primary.opacity(0.10))
                    .frame(height: 6)
                Capsule(style: .continuous)
                    .fill(Color.cyan.opacity(0.9))
                    .frame(width: max(10, right - left), height: 6)
                    .offset(x: left)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Hourly strip (sun window & skeleton row)

private extension WeatherPageContentView {
    struct SunWindow {
        let sunrise: Date
        let sunset: Date
    }

    func todaySunWindow(for forecast: CityWeatherForecast) -> SunWindow? {
        guard let today = forecast.days.first else { return nil }
        guard let sunrise = today.detail.sunrise, let sunset = today.detail.sunset else { return nil }
        return SunWindow(sunrise: sunrise, sunset: sunset)
    }

    func symbolForHour(_ hour: HourlyWeatherPoint, sunWindow: SunWindow?) -> String {
        guard let sunWindow else { return hour.conditionSymbolName }
        let isNight = hour.date < sunWindow.sunrise || hour.date > sunWindow.sunset
        guard isNight else { return hour.conditionSymbolName }

        switch hour.conditionSymbolName {
        case "sun.max.fill":
            return "moon.stars.fill"
        case "cloud.sun.fill":
            return "cloud.moon.fill"
        case "cloud.sun.rain.fill":
            return "cloud.moon.rain.fill"
        default:
            return hour.conditionSymbolName
        }
    }

    enum HourlyItem: Identifiable, Sendable {
        case hour(HourlyWeatherPoint)
        case sunrise(Date)
        case sunset(Date)

        var id: String {
            switch self {
            case let .hour(p): return "h:\(p.id)"
            case let .sunrise(d): return "sr:\(d.timeIntervalSince1970)"
            case let .sunset(d): return "ss:\(d.timeIntervalSince1970)"
            }
        }
    }

    func buildHourlyItems(hours: [HourlyWeatherPoint], sunWindow: SunWindow?) -> [HourlyItem] {
        guard let sunWindow, hours.count >= 2 else { return hours.map { .hour($0) } }

        var items: [HourlyItem] = []
        items.reserveCapacity(hours.count + 2)

        for i in 0..<hours.count {
            items.append(.hour(hours[i]))
            guard i < hours.count - 1 else { continue }
            let a = hours[i].date
            let b = hours[i + 1].date
            if sunWindow.sunrise >= a && sunWindow.sunrise < b {
                items.append(.sunrise(sunWindow.sunrise))
            }
            if sunWindow.sunset >= a && sunWindow.sunset < b {
                items.append(.sunset(sunWindow.sunset))
            }
        }
        return items
    }

    @ViewBuilder
    func hourlyCell(item: HourlyItem, sunWindow: SunWindow?) -> some View {
        switch item {
        case let .hour(hour):
            let symbol = symbolForHour(hour, sunWindow: sunWindow)
            VStack(spacing: 8) {
                Text(hour.date, format: .dateTime.hour())
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                WeatherSymbol(systemName: symbol, size: 22, square: 28)
                Text(WeatherFormatters.temperature(hour.temperatureCelsius, unit: tempUnit))
                    .font(.subheadline.weight(.semibold))
            }
            .environment(\.locale, locale)

        case let .sunrise(date):
            VStack(spacing: 8) {
                Text(date, format: .dateTime.hour().minute())
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                WeatherSymbol(systemName: "sunrise.fill", size: 22, square: 28)
                Text(verbatim: WeatherL10n.string("weather.sunrise", locale: locale))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .environment(\.locale, locale)

        case let .sunset(date):
            VStack(spacing: 8) {
                Text(date, format: .dateTime.hour().minute())
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                WeatherSymbol(systemName: "sunset.fill", size: 22, square: 28)
                Text(verbatim: WeatherL10n.string("weather.sunset", locale: locale))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .environment(\.locale, locale)
        }
    }
}

// MARK: - Placeholder forecast

private extension WeatherPageContentView {
    static var placeholderForecast: CityWeatherForecast {
        let now = Date()
        let cal = Calendar.current

        let current = CurrentWeatherSnapshot(
            temperatureCelsius: 12,
            apparentTemperatureCelsius: 10,
            humidityPercent: 72,
            precipitationMm: 0.4,
            windSpeedKmh: 16,
            windDirectionDegrees: 45,
            pressureHpa: 1012,
            conditionSymbolName: "cloud.sun.fill",
            conditionDescriptionKey: "wmo.partly_cloudy"
        )

        let hourly: [HourlyWeatherPoint] = (0..<12).map { i in
            let d = cal.date(byAdding: .hour, value: i, to: now) ?? now
            return HourlyWeatherPoint(
                id: "\(i)",
                date: d,
                temperatureCelsius: 10 + Double(i % 3),
                conditionSymbolName: i % 4 == 0 ? "cloud.rain.fill" : "cloud.sun.fill"
            )
        }

        let days: [ForecastDay] = (0..<7).map { i in
            let date = cal.date(byAdding: .day, value: i, to: now) ?? now
            let min = 6 + Double(i % 3)
            let max = min + 7
            let summary = ForecastDaySummary(
                tempMinCelsius: min,
                tempMaxCelsius: max,
                pressureHectopascals: 1010,
                precipitationMm: i % 3 == 0 ? 4.0 : 0.0,
                conditionSymbolName: i % 3 == 0 ? "cloud.rain.fill" : "cloud.sun.fill"
            )
            let detail = ForecastDayDetail(
                conditionDescriptionKey: "wmo.partly_cloudy",
                feelsLikeMaxCelsius: max - 1,
                humidityPercent: 70,
                windSpeedKmh: 16,
                windDirectionDegrees: 90,
                pressureHectopascals: 1010,
                sunrise: now,
                sunset: now
            )
            return ForecastDay(id: "d\(i)", date: date, summary: summary, detail: detail)
        }

        return CityWeatherForecast(
            displayName: "████████████",
            coordinate: GeoCoordinate(latitude: 0, longitude: 0),
            current: current,
            hourly: hourly,
            days: days
        )
    }
}

//
//  OpenMeteoForecastMapper.swift
//  WeatherApp
//

import Foundation

enum OpenMeteoForecastMapper {
    private static let dayFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return f
    }()

    private static let sunriseSunsetFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let sunriseSunsetFormatterNoFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static let openMeteoLocalTime: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return f
    }()

    private static let openMeteoLocalTimeWithSeconds: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f
    }()

    private static let hourlyLocalTime: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return f
    }()

    private static let hourlyLocalTimeWithSeconds: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f
    }()

    static func mapWeatherForecast(
        displayName: String,
        coordinate: GeoCoordinate,
        dto: OpenMeteoForecastDTO
    ) throws -> CityWeatherForecast {
        let current = mapCurrent(dto.current)
        let hourly = mapHourly(dto.hourly)
        let days = try mapDaily(dto.daily)
        return CityWeatherForecast(
            displayName: displayName,
            coordinate: coordinate,
            current: current,
            hourly: hourly,
            days: days
        )
    }

    private static func mapCurrent(_ dto: OpenMeteoCurrentDTO?) -> CurrentWeatherSnapshot? {
        guard let c = dto else { return nil }
        let code = c.weatherCode
        let symbol = WMOWeatherPresentationMapper.symbolName(forWMOCode: code)
        let descKey = WMOWeatherPresentationMapper.descriptionKey(forWMOCode: code)
        let apparent = c.apparentTemperature ?? c.temperature2m
        let humidity = Double(c.relativeHumidity2m ?? 0)
        let precipitation = c.precipitation ?? 0
        let wind = c.windSpeed10m ?? 0
        let windDir = Double(c.windDirection10m ?? 0)
        let pressure = c.pressureMsl ?? 1013
        return CurrentWeatherSnapshot(
            temperatureCelsius: c.temperature2m,
            apparentTemperatureCelsius: apparent,
            humidityPercent: humidity,
            precipitationMm: precipitation,
            windSpeedKmh: wind,
            windDirectionDegrees: windDir,
            pressureHpa: pressure,
            conditionSymbolName: symbol,
            conditionDescriptionKey: descKey
        )
    }

    private static func mapHourly(_ dto: OpenMeteoHourlyDTO?) -> [HourlyWeatherPoint] {
        guard let h = dto else { return [] }
        let n = min(h.time.count, h.temperature2m.count, h.weatherCode.count, 24)
        guard n > 0 else { return [] }
        var out: [HourlyWeatherPoint] = []
        out.reserveCapacity(n)
        for index in 0 ..< n {
            let raw = h.time[index]
            let date = parseHourlyDate(raw) ?? Date()
            let code = h.weatherCode[index]
            let symbol = WMOWeatherPresentationMapper.symbolName(forWMOCode: code)
            let point = HourlyWeatherPoint(
                id: raw,
                date: date,
                temperatureCelsius: h.temperature2m[index],
                conditionSymbolName: symbol
            )
            out.append(point)
        }
        return out
    }

    private static func parseHourlyDate(_ raw: String) -> Date? {
        if let d = hourlyLocalTime.date(from: raw) { return d }
        return hourlyLocalTimeWithSeconds.date(from: raw)
    }

    private static func mapDaily(_ d: OpenMeteoDailyDTO) throws -> [ForecastDay] {
        let count = d.time.count
        guard count >= 7 else { throw WeatherAppError.noForecastData }
        guard
            d.weathercode.count == count,
            d.temperature2mMax.count == count,
            d.temperature2mMin.count == count,
            d.precipitationSum.count == count,
            d.apparentTemperatureMax.count == count,
            d.relativeHumidity2mMax.count == count,
            d.windspeed10mMax.count == count,
            d.winddirection10mDominant.count == count,
            d.pressureMslMax.count == count,
            d.sunrise.count == count,
            d.sunset.count == count
        else {
            throw WeatherAppError.decodingFailed
        }

        var days: [ForecastDay] = []
        days.reserveCapacity(7)
        for index in 0 ..< 7 {
            let dateString = d.time[index]
            guard let date = dayFormatter.date(from: dateString) else {
                throw WeatherAppError.decodingFailed
            }
            let code = d.weathercode[index]
            let symbol = WMOWeatherPresentationMapper.symbolName(forWMOCode: code)
            let descKey = WMOWeatherPresentationMapper.descriptionKey(forWMOCode: code)
            let summary = ForecastDaySummary(
                tempMinCelsius: d.temperature2mMin[index],
                tempMaxCelsius: d.temperature2mMax[index],
                pressureHectopascals: d.pressureMslMax[index],
                precipitationMm: d.precipitationSum[index],
                conditionSymbolName: symbol
            )
            let sunrise = parseSunEvent(d.sunrise[index])
            let sunset = parseSunEvent(d.sunset[index])
            let detail = ForecastDayDetail(
                conditionDescriptionKey: descKey,
                feelsLikeMaxCelsius: d.apparentTemperatureMax[index],
                humidityPercent: d.relativeHumidity2mMax[index],
                windSpeedKmh: d.windspeed10mMax[index],
                windDirectionDegrees: Double(d.winddirection10mDominant[index]),
                pressureHectopascals: d.pressureMslMax[index],
                sunrise: sunrise,
                sunset: sunset
            )
            let day = ForecastDay(
                id: dateString,
                date: date,
                summary: summary,
                detail: detail
            )
            days.append(day)
        }
        return days
    }

    private static func parseSunEvent(_ raw: String) -> Date? {
        if let date = openMeteoLocalTime.date(from: raw) { return date }
        if let date = openMeteoLocalTimeWithSeconds.date(from: raw) { return date }
        if let date = sunriseSunsetFormatter.date(from: raw) { return date }
        return sunriseSunsetFormatterNoFraction.date(from: raw)
    }
}

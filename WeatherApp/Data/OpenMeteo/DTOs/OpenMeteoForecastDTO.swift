//
//  OpenMeteoForecastDTO.swift
//  WeatherApp
//

import Foundation

struct OpenMeteoForecastDTO: Decodable {
    let current: OpenMeteoCurrentDTO?
    let hourly: OpenMeteoHourlyDTO?
    let daily: OpenMeteoDailyDTO
}

struct OpenMeteoCurrentDTO: Decodable {
    let time: String
    let temperature2m: Double
    let apparentTemperature: Double?
    let relativeHumidity2m: Int?
    let precipitation: Double?
    let weatherCode: Int
    let windSpeed10m: Double?
    let windDirection10m: Int?
    let pressureMsl: Double?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case relativeHumidity2m = "relative_humidity_2m"
        case precipitation
        case weatherCode = "weather_code"
        case weathercode = "weathercode"
        case windSpeed10m = "wind_speed_10m"
        case windDirection10m = "wind_direction_10m"
        case pressureMsl = "pressure_msl"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        time = try c.decode(String.self, forKey: .time)
        temperature2m = try c.decode(Double.self, forKey: .temperature2m)
        apparentTemperature = try c.decodeIfPresent(Double.self, forKey: .apparentTemperature)
        relativeHumidity2m = try c.decodeIfPresent(Int.self, forKey: .relativeHumidity2m)
        precipitation = try c.decodeIfPresent(Double.self, forKey: .precipitation)
        if let code = try c.decodeIfPresent(Int.self, forKey: .weatherCode) {
            weatherCode = code
        } else {
            weatherCode = try c.decode(Int.self, forKey: .weathercode)
        }
        windSpeed10m = try c.decodeIfPresent(Double.self, forKey: .windSpeed10m)
        windDirection10m = try c.decodeIfPresent(Int.self, forKey: .windDirection10m)
        pressureMsl = try c.decodeIfPresent(Double.self, forKey: .pressureMsl)
    }
}

struct OpenMeteoHourlyDTO: Decodable {
    let time: [String]
    let temperature2m: [Double]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
        case weathercode = "weathercode"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        time = try c.decode([String].self, forKey: .time)
        temperature2m = try c.decode([Double].self, forKey: .temperature2m)
        if let codes = try c.decodeIfPresent([Int].self, forKey: .weatherCode) {
            weatherCode = codes
        } else {
            weatherCode = try c.decode([Int].self, forKey: .weathercode)
        }
    }
}

struct OpenMeteoDailyDTO: Decodable {
    let time: [String]
    let weathercode: [Int]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let precipitationSum: [Double]
    let apparentTemperatureMax: [Double]
    let relativeHumidity2mMax: [Double]
    let windspeed10mMax: [Double]
    let winddirection10mDominant: [Int]
    let pressureMslMax: [Double]
    let sunrise: [String]
    let sunset: [String]

    enum CodingKeys: String, CodingKey {
        case time
        case weathercode
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationSum = "precipitation_sum"
        case apparentTemperatureMax = "apparent_temperature_max"
        case relativeHumidity2mMax = "relative_humidity_2m_max"
        case windspeed10mMax = "windspeed_10m_max"
        case winddirection10mDominant = "winddirection_10m_dominant"
        case pressureMslMax = "pressure_msl_max"
        case sunrise
        case sunset
    }
}

//
//  API.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import Foundation


struct WeatherData: Codable, Identifiable {
    let id = UUID()
    let lat: Double
    let lon: Double
    let timezone: String
    let timezone_offset: Int
    let current: Current
    let minutely: [Minutely]
    let hourly: [Hourly]
    let daily: [Daily]
    let alerts: [Alert]?

    private enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case timezone
        case timezone_offset
        case current
        case minutely
        case hourly
        case daily
        case alerts
    }
}

struct Current: Codable {
    let dt: TimeInterval
    let sunrise: TimeInterval
    let sunset: TimeInterval
    let temp: Double
    let feels_like: Double
    let pressure: Double
    let humidity: Double
    let dew_point: Double
    let clouds: Double
    let uvi: Double
    let visibility: Double?
    let wind_speed: Double
    let wind_gust: Double?
    let wind_deg: Double
    let rain: Rain?
    let snow: Snow?
    let weather: [Weather]
}

struct Minutely: Codable {
    let dt: TimeInterval
    let precipitation: Double // only uses mm/h
    enum CodingKeys: CodingKey {
        case dt
        case precipitation
    }
}

struct Hourly: Codable, Identifiable{
    let id = UUID()
    let dt: TimeInterval
    let temp: Double
    let feels_like: Double
    let pressure: Double
    let humidity: Double
    let dew_point: Double
    let uvi: Double
    let clouds: Double
    let visibility: Double?
    let wind_speed: Double
    let wind_gust: Double?
    let wind_deg: Double
    let pop: Double
    let rain: Rain?
    let snow: Snow?
    let weather: [Weather]
    
    private enum CodingKeys: String, CodingKey {
        case dt
        case temp
        case feels_like
        case pressure
        case humidity
        case dew_point
        case uvi
        case clouds
        case visibility
        case wind_speed
        case wind_gust
        case wind_deg
        case pop
        case rain
        case snow
        case weather
    }
}

struct Daily: Codable, Identifiable {
    let id = UUID()
    let dt: TimeInterval
    let sunrise: TimeInterval
    let sunset: TimeInterval
    let moonrise: TimeInterval
    let moonset: TimeInterval
    let moon_phase: Double
    let summary: String
    let temp: Temp
    let feels_like: FeelsLike
    let pressure: Double
    let humidity: Double
    let dew_point: Double
    let wind_speed: Double
    let wind_gust: Double?
    let wind_deg: Double
    let clouds: Double
    let uvi: Double
    let pop: Double
    let rain: Double?
    let snow: Double?
    let weather: [Weather]
    
    private enum CodingKeys: CodingKey {
        case dt
        case sunrise
        case sunset
        case moonrise
        case moonset
        case moon_phase
        case summary
        case temp
        case feels_like
        case pressure
        case humidity
        case dew_point
        case wind_speed
        case wind_gust
        case wind_deg
        case clouds
        case uvi
        case pop
        case rain
        case snow
        case weather
    }
    

}

struct Alert: Codable, Identifiable {
    let id = UUID()
    let sender_name: String
    let event: String
    let start: TimeInterval
    let end: TimeInterval
    let description: String
    let tags: [String]
    
    private enum CodingKeys: CodingKey {
        case sender_name
        case event
        case start
        case end
        case description
        case tags
    }
}

struct Temp: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct FeelsLike: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct Rain: Codable {
    
    
    let oneHour: Double? // only uses mm/h
    
    private enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}

struct Snow: Codable {
    let oneHour: Double? // only uses mm/h
    
    private enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}

struct Weather: Codable {
    let weatherID: Int
    let weatherMain: String
    let weatherDescription: String
    let weatherIcon: String
    
    private enum CodingKeys: String, CodingKey {
        case weatherID = "id"
        case weatherMain = "main"
        case weatherDescription = "description"
        case weatherIcon = "icon"
    }
}


// for formatting dates to strings
extension TimeInterval {
    func formatted(_ format: String, timeZone: String? = nil) -> String {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        if let timeZone {
            dateFormatter.timeZone = TimeZone(identifier: timeZone)
        }
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}

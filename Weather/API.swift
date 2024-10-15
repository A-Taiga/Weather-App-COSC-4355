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
    
//    init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.dt = try container.decode(TimeInterval.self, forKey: .dt)
//        self.temp = try container.decode(Double.self, forKey: .temp)
//        self.feels_like = try container.decode(Double.self, forKey: .feels_like)
//        self.pressure = try container.decode(Double.self, forKey: .pressure)
//        self.humidity = try container.decode(Double.self, forKey: .humidity)
//        self.dew_point = try container.decode(Double.self, forKey: .dew_point)
//        self.uvi = try container.decode(Double.self, forKey: .uvi)
//        self.clouds = try container.decode(Double.self, forKey: .clouds)
//        self.visibility = try? container.decodeIfPresent(Double.self, forKey: .visibility)
//        self.wind_speed = try container.decode(Double.self, forKey: .wind_speed)
//        self.wind_gust = try? container.decodeIfPresent(Double.self, forKey: .wind_gust)
//        self.wind_deg = try container.decode(Double.self, forKey: .wind_deg)
//        self.pop = try container.decode(Double.self, forKey: .pop)
//        self.rain = try? container.decodeIfPresent(Rain.self, forKey: .rain)
//        self.snow = try? container.decodeIfPresent(Snow.self, forKey: .snow)
//        self.weather = try container.decode([Weather].self, forKey: .weather)
//    }
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

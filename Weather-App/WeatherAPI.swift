//
//  WeatherAPI.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import Foundation
import SwiftUI



struct WeatherData: Codable, Identifiable, Equatable{
    static func == (lhs: WeatherData, rhs: WeatherData) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    let latitude: Double
    let longitude: Double
    let timezone: String
    let offset: Int32
    let elevation: Int32
    let currently: Currently
    let minutely: Minutely
    let hourly: Hourly
    let daily: Daily
    let alerts: [Alert]?
    
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case timezone
        case offset
        case elevation
        case currently
        case minutely
        case hourly
        case daily
        case alerts
    }
}

struct Currently: Codable, Hashable{
    let time: Int32
    let icon: String
    let summary: String
    let nearestStormDistance: Double
    let nearestStormBearing: Double
    let precipIntensity: Double
    let precipProbability: Double
    let precipIntensityError: Double
    let precipType: String
    let temperature: Double
    let apparentTemperature: Double
    let dewPoint: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windGust: Double
    let windBearing: Double
    let cloudCover: Double
    let uvIndex: Double
    let visibility: Double
    let ozone: Double
    let smoke: Double
    let fireIndex: Double
    let feelsLike: Double
}

struct Minutely: Codable {
    
    struct Item: Codable, Hashable{
        let time: Int32
        let precipIntensity: Double
        let precipProbability: Double
        let precipIntensityError: Double
        let precipType: String
    }
    
    let summary: String
    let icon: String
    let data: [Item]
}

struct Hourly: Codable {
    let summary: String
    let icon: String
    let data: [Currently]
}

struct Daily: Codable {
    
    struct Item: Codable, Hashable {
        let time: Int32
        let icon: String
        let summary: String
        let sunriseTime: Int32
        let sunsetTime: Int32
        let moonPhase: Double
        let precipIntensity: Double
        let precipIntensityMax: Double
        let precipIntensityMaxTime: Int32
        let precipProbability: Double
        let precipAccumulation: Double
        let precipType: String
        let temperatureHigh: Double
        let temperatureHighTime: Int32
        let temperatureLow: Double
        let temperatureLowTime: Int32
        let apparentTemperatureHigh: Double
        let apparentTemperatureHighTime: Int32
        let apparentTemperatureLow: Double
        let apparentTemperatureLowTime: Int32
        let dewPoint: Double
        let humidity: Double
        let pressure: Double
        let windSpeed: Double
        let windGust: Double
        let windGustTime: Int32
        let windBearing: Double
        let cloudCover: Double
        let uvIndex: Double
        let uvIndexTime: Double
        let visibility: Double
        let temperatureMin: Double
        let temperatureMinTime: Int32
        let temperatureMax: Double
        let temperatureMaxTime: Double
        let apparentTemperatureMin: Double
        let apparentTemperatureMinTime: Int32
        let apparentTemperatureMax: Double
        let apparentTemperatureMaxTime: Double
        let smokeMax: Double
        let smokeMaxTime: Int32
        let liquidAccumulation: Double
        let snowAccumulation: Double
        let iceAccumulation: Double
        let fireIndexMax: Double
        let fireIndexMaxTime: Int32
    }
    
    let summary: String
    let icon: String
    let data: [Item]
}

struct Alert: Codable {
    let title: String
    let regions: [String]
    let severity: String
    let time: Int32
    let expires: Int32
    let description: String
    let uri: String
}

func getSymbol (icon: String) -> some View {
    switch (icon) {
    case "clear-day":           Image(systemName: "sun.max.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.yellow, .yellow)
    case "clear-night":         Image(systemName: "moon.stars.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .white)
    case "rain":                Image(systemName: "cloud.rain.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, Color(red: 0.4627, green: 0.8392, blue: 255.0))
    case "snow":                Image(systemName: "cloud.snow.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .white)
    case "sleet":               Image(systemName: "cloud.sleet.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .white)
    case "wind":                Image(systemName: "wind")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .white)
    case "fog":                 Image(systemName: "cloud.fog.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .white)
    case "cloudy":              Image(systemName: "cloud.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .white)
    case "partly-cloudy-day":   Image(systemName: "cloud.sun.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .yellow)
    case "partly-cloudy-night": Image(systemName: "cloud.moon.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .white)
    default:                    Image(systemName: "")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.gray, .yellow)
    }
}


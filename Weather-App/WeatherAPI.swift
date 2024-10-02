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

struct Alert: Codable, Identifiable {
    let id = UUID()
    let title: String
    let regions: [String]
    let severity: String
    let time: Int32
    let expires: Int32
    let description: String
    let uri: String
    
    private enum CodingKeys: String, CodingKey {
        case title
        case regions
        case severity
        case time
        case expires
        case description
        case uri
    }
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

func getWindBearing(val: Double) -> String {
    switch (val) {
    case 0: "N"
    case 90: "E"
    case 180: "S"
    case 270: "W"
    case 0...22.5:  "N"
    case 22.5...67.5:   "NE"
    case 67.5...112.5:  "E"
    case 112.5...157.5: "SE"
    case 157.5...202.5: "S"
    case 202.5...247.5: "SW"
    case 247.5...292.5: "W"
    case 292.5...337.5: "NW"
    default: ""
    }
}

func getAlertTitle (title: String) -> String {
    
    switch title {
    case _ where title.contains("Air Quality Alert"):            return "Air Quality Alert"
    case _ where title.contains("Winter Storm Watch"):           return "Winter Storm Watch"
    case _ where title.contains("Blizzard Warning"):             return "Blizzard Warning"
    case _ where title.contains("Winter Storm Warning"):         return "Winter Storm Warning"
    case _ where title.contains("Ice Storm Warning"):            return "Ice Storm Warning"
    case _ where title.contains("Winter Weather Advisory"):      return "Winter Weather Advisory"
    case _ where title.contains("Freeze Warning"):               return "Freeze Warning"
    case _ where title.contains("Wind Chill Watch"):             return "Wind Chill Watch"
    case _ where title.contains("Wind Chill Advisory"):          return "Wind Chill Advisory"
    case _ where title.contains("Wind Chill Warning"):           return "Wind Chill Warning"
    case _ where title.contains("Dense Fog Advisory"):           return "Dense Fog Advisory"
    case _ where title.contains("High Wind Watch"):              return "High Wind Watch"
    case _ where title.contains("High Wind Warning"):            return "High Wind Warning"
    case _ where title.contains("Wind Advisory"):                return "Wind Advisory"
    case _ where title.contains("Special Weather Statement"):    return "Special Weather Statement"
    case _ where title.contains("Severe Thunderstorm Watch"):    return "Severe Thunderstorm Watch"
    case _ where title.contains("Severe Thunderstorm Warning"):  return "Severe Thunderstorm Warning"
    case _ where title.contains("Severe Weather Statement"):     return "Severe Weather Statement"
    case _ where title.contains("Tornado Watch"):                return "Tornado Watch"
    case _ where title.contains("Tornado Warning"):              return "Tornado Warning"
    case _ where title.contains("Coastal Flood Advisory"):        return "Coastal Flood Advisory"
    case _ where title.contains("Flash Flood Watch"):            return "Flash Flood Watch"
    case _ where title.contains("Flash Flood Warning"):          return "Flash Flood Warning"
    case _ where title.contains("Flood Watch"):                  return "Flood Watch"
    case _ where title.contains("Flood Warning"):                return "Flood Warning"
    case _ where title.contains("Areal Flood Watch"):            return "Areal Flood Watch"
    case _ where title.contains("Areal Flood Warning"):          return "Areal Flood Warning"
    case _ where title.contains("Heat Advisory"):                return "Heat Advisory"
    case _ where title.contains("Excessive Heat Watch"):         return "Excessive Heat Watch"
    case _ where title.contains("Excessive Heat Advisory"):      return "Excessive Heat Advisory"
    case _ where title.contains("Public Information Statement"): return "Public Information Statement"
    case _ where title.contains("Local Storm Report"):           return "Local Storm Report"
    case _ where title.contains("Short Term Forecast"):          return "Short Term Forecast"
    case _ where title.contains("Dense Smoke Advisory"):         return "Dense Smoke Advisory"
    case _ where title.contains("Air Stagnation Advisory"):      return "Air Stagnation Advisory"
    case _ where title.contains("Air Quality Alert"):            return "Air Quality Alert"
    case _ where title.contains("Dust Advisory"):                return "Dust Advisory"
    case _ where title.contains("Blowing Dust Advisory"):        return "Blowing Dust Advisory"
    case _ where title.contains("Dust Storm Warning"):           return "Dust Storm Warning"
    case _ where title.contains("Blowing Dust Storm Warning"):   return "Blowing Dust Storm Warning"
    case _ where title.contains("Ash Fall Advisory"):            return "Ash Fall Advisory"
    case _ where title.contains("Fire Weather Watch"):           return "Fire Weather Watch"
    case _ where title.contains("Red Flag Warning"):             return "Red Flag Warning"
    default: return ""
    }
}

func getAlertSymbol (title: String) -> some View {
    
    switch title {
    case _ where title.contains("Air Quality Alert"):            return Image(systemName: "aqi.medium").resizable().foregroundStyle(.blue)
    case _ where title.contains("Winter Storm Watch"):           return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Blizzard Warning"):             return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Winter Storm Warning"):         return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Ice Storm Warning"):            return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Winter Weather Advisory"):      return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Freeze Warning"):               return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Wind Chill Watch"):             return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Wind Chill Advisory"):          return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Wind Chill Warning"):           return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Dense Fog Advisory"):           return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("High Wind Watch"):              return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("High Wind Warning"):            return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Wind Advisory"):                return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Special Weather Statement"):    return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Severe Thunderstorm Watch"):    return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Severe Thunderstorm Warning"):  return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Severe Weather Statement"):     return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Tornado Watch"):                return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Tornado Warning"):              return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Flash Flood Watch"):            return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Flash Flood Warning"):          return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Flood Watch"):                  return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Flood Warning"):                return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Areal Flood Watch"):            return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Areal Flood Warning"):          return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Heat Advisory"):                return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Excessive Heat Watch"):         return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Excessive Heat Advisory"):      return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Public Information Statement"): return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Local Storm Report"):           return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Short Term Forecast"):          return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Dense Smoke Advisory"):         return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Air Stagnation Advisory"):      return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Air Quality Alert"):            return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Dust Advisory"):                return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Blowing Dust Advisory"):        return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Dust Storm Warning"):           return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Blowing Dust Storm Warning"):   return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Ash Fall Advisory"):            return Image(systemName: "").resizable().foregroundStyle(.white)
    case _ where title.contains("Fire Weather Watch"):           return Image(systemName: "flame.fill").resizable().foregroundStyle(.yellow)
    case _ where title.contains("Red Flag Warning"):             return Image(systemName: "exclamationmark.triangle.fill").resizable().foregroundStyle(.white, .red)
    default: return Image(systemName: "").resizable().foregroundStyle(.white)
    }
}


/*
        Only on daily. The fractional lunation number for the given day. 0.00 represents a new moon, 0.25 represents the
        first quarter, 0.50 represents a full moon and 0.75 represents the last quarter.

          New Moon           􁐉
          Waxing crescent    􁐊
          First quarter      􁐋
          Waxing gibbous     􁐌
          Full Moon          􁐍
          Waning gibbous     􁐎
          Last quarter       􁐏
          Waning crescent    􁐐
*/

func getMoonPhase(data: Double) -> Image {
    switch data {
    case 0.00:        Image(systemName: "moonphase.new.moon")
    case 0.00..<0.25: Image(systemName: "moonphase.waxing.crescent")
    case 0.25:        Image(systemName: "moonphase.first.quarter")
    case 0.25..<0.50: Image(systemName: "moonphase.waxing.gibbous")
    case 0.50:        Image(systemName: "moonphase.full.moon")
    case 0.50..<0.75: Image(systemName: "moonphase.waning.gibbous")
    case 0.75:        Image(systemName: "moonphase.last.quarter")
    case 0.75...0.96: Image(systemName: "moonphase.waning.crescent")
    case 0.97...1:    Image(systemName: "moonphase.new.moon")
    default:          Image(systemName: "")
    }
}


func getMoonPhaseName(data: Double) -> String {
    switch data {
    case 0.00:        "New Moon"
    case 0.00..<0.25: "Waxing crescent"
    case 0.25:        "First quarter"
    case 0.25..<0.50: "Waxing gibbous"
    case 0.50:        "Full Moon"
    case 0.50..<0.75: "Waning gibbous"
    case 0.75:        "Last quarter"
    case 0.75...0.96: "Waning crescent"
    case 0.97...1:    "New Moon"
    default: ""
    }
}



enum UnitsTemp {
    case fahrenheit
    case celsius
}

enum UnitsSpeed {
    case milesPerHour
    case kilometersPerHour
    case metersPerSecond
    case knots
}

enum UnitsPrecipitation {
    case inches
    case millimeters
    case centimeter
}

enum UnitsDistance {
    case miles
    case kilometers
}


@Observable
class Units {
    
    var temp: UnitsTemp = .fahrenheit
    var wind: UnitsSpeed = .milesPerHour
    var precipitation: UnitsPrecipitation = .inches
    var distance: UnitsDistance = .miles
    
    func handleUnit<T> (_ unitType: T.Type) -> String {
        
        if T.self == UnitsTemp.self {
            switch temp {
            case .fahrenheit: return "F"
            case .celsius:    return "C"
            }
        } else if T.self == UnitsSpeed.self {
            switch wind {
            case .milesPerHour:      return "mph"
            case .kilometersPerHour: return "km/h"
            case .metersPerSecond:   return "m/s"
            case .knots:             return "kn"
            }
        } else if T.self == UnitsPrecipitation.self {
            switch precipitation {
            case .inches:      return "in"
            case .millimeters: return "mm"
            case .centimeter:  return "cm"
            }
        } else if T.self == UnitsDistance.self {
            switch distance {
            case .miles:      return "mi"
            case .kilometers: return "km"
            }
        } else {
            return ""
        }
    }
    
    func handleTemp(val: Double) -> Int {
        switch temp {
        case .fahrenheit: return Int(val.rounded())
        case .celsius:    return Int(toCelsius(val).rounded())
        }
    }
    
    func handleWind(val: Double) -> Int {
        switch wind {
        case .milesPerHour:         return Int(val.rounded())
        case .kilometersPerHour:    return Int(toKilometers(val).rounded())
        case .metersPerSecond:      return Int(toMeterPerSecond(val).rounded())
        case .knots:                return Int(toKnots(val).rounded())
        }
    }
    
    func handlePrecipitation(val: Double) -> Int {
        switch precipitation {
        case .inches:      return Int(val.rounded())
        case .millimeters: return Int(toMillimeters(val).rounded())
        case .centimeter:  return Int(toCentimeter(val).rounded())
        }
    }
    
    func handleDistance(val: Double) -> Int {
        switch distance {
        case .miles: return Int(val.rounded())
        case .kilometers: return Int(toKilometers(val).rounded())
        }
    }
    
    // MARK: temp
    func toCelsius (_ val: Double) -> Double {
        return (val - 32) * 5 / 9
    }
    
    func toKelvin (_ val: Double) -> Double {
        return (val - 32) * 5/9 + 273.15
    }
    // MARK: speed
    func toKph (_ val: Double) -> Double {
        return val * 1.609
    }
    
    func toMeterPerSecond (_ val: Double) -> Double {
        return val / 2.237
    }
    
    func toKnots (_ val: Double) -> Double {
        return val / 1.151
    }
    // MARK: precipitation
    func toMillimeters (_ val: Double) -> Double {
        return val * 25.4
    }
    
    func toCentimeter (_ val: Double) -> Double {
        return val * 2.54
    }
    // MARK: distance
    func toKilometers (_ val: Double) -> Double {
        return val * 1.609
    }
    
}


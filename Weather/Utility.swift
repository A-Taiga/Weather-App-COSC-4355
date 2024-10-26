//
//  Utility.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import Foundation
import SwiftUI

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
            case .fahrenheit: return "°F"
            case .celsius:    return "°C"
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
        case .inches:      return Int(val * 100)
        case .millimeters: return Int(toMillimeters(val * 100))
        case .centimeter:  return Int(toCentimeter(val * 100))
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



/*
 01d.png     01n.png     clear sky
 02d.png     02n.png     few clouds
 03d.png     03n.png     scattered clouds
 04d.png     04n.png     broken clouds
 09d.png     09n.png     shower rain
 10d.png     10n.png     rain
 11d.png     11n.png     thunderstorm
 13d.png     13n.png     snow
 50d.png     50n.png     mist
 
 
 
 
 Group 2xx: Thunderstorm
 200     Thunderstorm     thunderstorm with light rain     11d
 201     Thunderstorm     thunderstorm with rain     11d
 202     Thunderstorm     thunderstorm with heavy rain     11d
 210     Thunderstorm     light thunderstorm     11d
 211     Thunderstorm     thunderstorm     11d
 212     Thunderstorm     heavy thunderstorm     11d
 221     Thunderstorm     ragged thunderstorm     11d
 230     Thunderstorm     thunderstorm with light drizzle     11d
 231     Thunderstorm     thunderstorm with drizzle     11d
 232     Thunderstorm     thunderstorm with heavy drizzle     11d
 
 */

let thunderstorm = [
    200: "cloud.bolt.rain.fill",
    201: "cloud.bolt.rain.fill",
    202: "cloud.bolt.rain.fill",
    210: "cloud.bolt.rain.fill",
    211: "cloud.bolt.fill",
    212: "cloud.bolt.fill",
    221: "cloud.bolt.fill",
    230: "cloud.bolt.rain.fill",
    231: "cloud.bolt.rain.fill",
    232: "cloud.bolt.rain.fill"
]


/*
 Group 3xx: Drizzle
 300     Drizzle     light intensity drizzle     09d
 301     Drizzle     drizzle     09d
 302     Drizzle     heavy intensity drizzle     09d
 310     Drizzle     light intensity drizzle rain     09d
 311     Drizzle     drizzle rain     09d
 312     Drizzle     heavy intensity drizzle rain     09d
 313     Drizzle     shower rain and drizzle     09d
 314     Drizzle     heavy shower rain and drizzle     09d
 321     Drizzle     shower drizzle     09d
 
 */

let drizzleDay = [
    300: "cloud.sun.rain.fill",
    301: "cloud.drizzle.fill",
    302: "cloud.drizzle.fill",
    310: "cloud.sun.rain.fill",
    311: "cloud.drizzle.fill",
    312: "cloud.drizzle.fill",
    313: "cloud.drizzle.fill",
    314: "cloud.drizzle.fill",
    321: "cloud.drizzle.fill"
]

let drizzleNight = [
    300: "cloud.moon.rain.fill",
    301: "cloud.drizzle.fill",
    302: "cloud.drizzle.fill",
    310: "cloud.sun.rain.fill",
    311: "cloud.drizzle.fill",
    312: "cloud.drizzle.fill",
    313: "cloud.drizzle.fill",
    314: "cloud.drizzle.fill",
    321: "cloud.drizzle.fill"
]

/*
 
 Group 5xx: Rain
 500     Rain     light rain     10d
 501     Rain     moderate rain     10d
 502     Rain     heavy intensity rain     10d
 503     Rain     very heavy rain     10d
 504     Rain     extreme rain     10d
 511     Rain     freezing rain     13d
 520     Rain     light intensity shower rain     09d
 521     Rain     shower rain     09d
 522     Rain     heavy intensity shower rain     09d
 531     Rain     ragged shower rain     09d
 
 */


let rainDay = [
    500: "cloud.sun.rain.fill",
    501: "cloud.rain.fill",
    502: "cloud.heavyrain.fill",
    503: "cloud.heavyrain.fill",
    504: "cloud.heavyrain.fill",
    511: "cloud.sleet.fill",
    520: "cloud.sun.rain.fill",
    521: "cloud.rain.fill",
    522: "cloud.heavyrain.fill",
    531: "cloud.heavyrain.fill"
]

let rainNight = [
    500: "cloud.moon.rain.fill",
    501: "cloud.rain.fill",
    502: "cloud.heavyrain.fill",
    503: "cloud.heavyrain.fill",
    504: "cloud.heavyrain.fill",
    511: "cloud.sleet.fill",
    520: "cloud.moon.rain.fill",
    521: "cloud.rain.fill",
    522: "cloud.heavyrain.fill",
    531: "cloud.heavyrain.fill"
]


/*
 
 Group 6xx: Snow
 600     Snow     light snow     13d
 601     Snow     snow     13d
 602     Snow     heavy snow     13d
 611     Snow     sleet     13d
 612     Snow     light shower sleet     13d
 613     Snow     shower sleet     13d
 615     Snow     light rain and snow     13d
 616     Snow     rain and snow     13d
 620     Snow     light shower snow     13d
 621     Snow     shower snow     13d
 622     Snow     heavy shower snow     13d
 
 */

let snowDay = [
    600: "sun.snow.fill",
    601: "cloud.snow.fill",
    602: "cloud.snow.fill",
    611: "cloud.sleet.fill",
    612: "cloud.sleet.fill",
    613: "cloud.sleet.fill",
    615: "cloud.snow.fill",
    616: "cloud.snow.fill",
    620: "cloud.snow.fill",
    621: "cloud.snow.fill",
    622: "cloud.snow.fill"
]

let snowNight = [
    600: "cloud.snow.fill",
    601: "cloud.snow.fill",
    602: "cloud.snow.fill",
    611: "cloud.sleet.fill",
    612: "cloud.sleet.fill",
    613: "cloud.sleet.fill",
    615: "cloud.snow.fill",
    616: "cloud.snow.fill",
    620: "cloud.snow.fill",
    621: "cloud.snow.fill",
    622: "cloud.snow.fill"
]

/*
 
 Group 7xx: Atmosphere
 701     Mist     mist     50d
 711     Smoke     smoke     50d
 721     Haze     haze     50d
 731     Dust     sand/dust whirls     50d
 741     Fog     fog     50d
 751     Sand     sand     50d
 761     Dust     dust     50d
 762     Ash     volcanic ash     50d
 771     Squall     squalls     50d
 781     Tornado     tornado     50d
 
 
 */


let atmosphereDay = [
    701: "",
    711: "smoke.fill",
    721: "sun.haze",
    731: "sun.dust.fill",
    741: "cloud.fog.fill",
    751: "sun.dust.fill",
    761: "sun.dust.fill",
    762: "smoke.fill",
    771: "wind",
    781: "tornado"
]

let atmosphereNight = [
    701: "",
    711: "smoke.fill",
    721: "sun.haze",
    731: "moon.dust.fill",
    741: "cloud.fog.fill",
    751: "moon.dust.fill",
    761: "moon.dust.fill",
    762: "smoke.fill",
    771: "wind",
    781: "tornado",
]
 
 /*
 
 
 
 Group 800: Clear
 800     Clear     clear sky     01d 01n
  
*/


/*
 
 Group 80x: Clouds
 801     Clouds     few clouds: 11-25%     02d 02n
 802     Clouds     scattered clouds: 25-50%     03d 03n
 803     Clouds     broken clouds: 51-84%     04d 04n
 804     Clouds     overcast clouds: 85-100%     04d 04n

*/

let cloudsDay = [
    801: "cloud.sun.fill",
    802: "cloud.sun.fill",
    803: "cloud.sun.fill",
    804: "cloud.fill"
]

let cloudsNight = [
    801: "cloud.moon.fill",
    802: "cloud.moon.fill",
    803: "cloud.moon.fill",
    804: "cloud.fill"
]

func getIcon(id: Int, main: String, icon: String) -> Image {
    
    var result: String?
    if icon.last == "d" {
        switch main {
        case "Thunderstorm": result = thunderstorm[id]
        case "Drizzle":      result = drizzleDay[id]
        case "Rain":         result = rainDay[id]
        case "Snow":         result = snowDay[id]
        case "Atmosphere":   result = atmosphereDay[id]
        case "Clouds":       result = cloudsDay[id]
        case "Clear":        result = "sun.max.fill"
        default:             result = ""
        }
        
    } else if icon.last == "n" {
        switch main {
        case "Thunderstorm": result = thunderstorm[id]
        case "Drizzle":      result = drizzleNight[id]
        case "Rain":         result = rainNight[id]
        case "Snow":         result = snowNight[id]
        case "Atmosphere":   result = atmosphereNight[id]
        case "Clouds":       result = cloudsNight[id]
        case "Clear":        result = "moon.stars.fill"
        default:             result = ""
        }
    }
    guard let result else {return Image("")}
    return Image(systemName: result)
}


func unixToTime(_ time: Int32, format: String, timeZone: String? = nil) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(time))
    let dateFormatter = DateFormatter()
    if let zone = timeZone {
        dateFormatter.timeZone = TimeZone(identifier: zone)
    }
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
}

func toTime(utc: TimeInterval, timeZone: String? = nil) -> String {
    let date = Date(timeIntervalSince1970: utc)
    let dateFormatter = DateFormatter()
    if let timeZone {
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
    }
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter.string(from: date)
}



func adjustedTimeInterval(from timeInterval: TimeInterval, toTimeZoneIdentifier timeZoneIdentifier: String) -> TimeInterval {
    let date = Date(timeIntervalSinceReferenceDate: timeInterval)
    guard let timeZone = TimeZone(identifier: timeZoneIdentifier) else {
        print("Invalid timezone identifier")
        return timeInterval
    }
    let currentOffset = TimeZone.current.secondsFromGMT(for: date)
    let targetOffset = timeZone.secondsFromGMT(for: date)
    let offsetDifference = targetOffset - currentOffset
    let adjustedTimeInterval = timeInterval + TimeInterval(offsetDifference)
    
    return adjustedTimeInterval
}


func fetchData (lat: Double, lon: Double, completion: @escaping(_ data: WeatherData?)  -> () ) async {
    do {
        let env = ProcessInfo.processInfo.environment
        let url = URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=imperial&appid=\(env["API_KEY"] ?? "")")
        let (data, _) = try await URLSession.shared.data (from: url!)
        completion(try JSONDecoder().decode(WeatherData.self, from: data))
    } catch {
        print (error)
    }
}

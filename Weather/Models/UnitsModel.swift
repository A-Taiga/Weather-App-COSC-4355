//
//  UnitsModel.swift
//  Weather
//
//  Created by Anthony Polka on 11/19/24.
//

import Foundation



class Convsersions {
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

protocol UnitEnumType {}
    
enum TemperatureUnit: String, UnitEnumType {
    case celsius = "°C"
    case fahrenheit = "°F"
    case kelvin = "K"
}

enum SpeedUnit: String, UnitEnumType {
    case milesPerHour = "mph"
    case kilometersPerHour = "kp/h"
    case metersPerSecond = "m/s"
    case knots = "kn"
}

enum PrecipitationUnit: String, UnitEnumType {
    case inches = "in"
    case millimeters = "mm"
    case centimeter = "cm"
}

enum DistanceUnit: String, UnitEnumType {
    case miles = "mi"
    case kilometers = "km"
}


protocol WeatherUnit {
    associatedtype Unit: UnitEnumType
    var realVal: Double {get}
    var unit: Unit {get set}
    var val: Double {get}
    func conversion(to targetUnit: Unit) -> Double
}


class Temperature: Convsersions, WeatherUnit, CustomStringConvertible {
    
    let realVal: Double
    
    var unit: TemperatureUnit
    
    var val: Double {
        return conversion(to: self.unit)
    }
    
    var description: String {
        String(format: "%.0f %@", val, unit.rawValue)
    }
    
    init(_ val: Double, _ unit: TemperatureUnit) {
        self.realVal = val
        self.unit = unit
    }
    
    init (_ val: Double) {
        self.realVal = val
        self.unit = .fahrenheit
    }
    
    func conversion(to targetUnit: TemperatureUnit) -> Double {
        switch targetUnit {
        case .celsius: return toCelsius(realVal)
        case .fahrenheit: return realVal
        case .kelvin: return toKelvin(realVal)
        }
    }
}

class Speed: Convsersions, WeatherUnit, CustomStringConvertible {

    let realVal: Double
    var unit: SpeedUnit
    var val: Double {
        return conversion(to: self.unit)
    }
    
    var description: String {
        String(format: "%.0f %@", val, unit.rawValue)
    }

    init(_ val: Double, _ unit: SpeedUnit) {
        self.realVal = val
        self.unit = unit
    }
    
    init (_ val: Double) {
        self.realVal = val
        self.unit = .milesPerHour
    }
    
    func conversion(to targetUnit: SpeedUnit) -> Double {
        switch targetUnit {
        case .milesPerHour: return realVal
        case .kilometersPerHour: return toKph(realVal)
        case .metersPerSecond: return toMeterPerSecond(realVal)
        case .knots: return toKnots(realVal)
        }
    }
}


class Precipitation: Convsersions, WeatherUnit, CustomStringConvertible {
    
    let realVal: Double
    var unit: PrecipitationUnit
    var val: Double {
        return conversion(to: self.unit)
    }
    
    var description: String {
        String(format: "%.1f %@", val, unit.rawValue)
    }
    
    init(_ val: Double, _ unit: PrecipitationUnit) {
        self.realVal = val
        self.unit = unit
    }
    
    init (_ val: Double) {
        self.realVal = val
        self.unit = .inches
    }
    
    func conversion(to targetUnit: PrecipitationUnit) -> Double {
        switch targetUnit {
        case .centimeter: return toCentimeter(realVal)
        case .inches: return realVal
        case .millimeters: return toMillimeters(realVal)
        }
    }
}

class Distance: Convsersions, WeatherUnit, CustomStringConvertible {
    
    let realVal: Double
    var unit: DistanceUnit
    var val: Double {
        return conversion(to: self.unit)
    }
    
    var description: String {
        String(format: "%.1f %@", val, unit.rawValue)
    }
    
    init(_ val: Double, _ unit: DistanceUnit) {
        self.realVal = val
        self.unit = unit
    }
    
    init (_ val: Double) {
        self.realVal = val
        self.unit = .miles
    }
    
    func conversion(to targetUnit: DistanceUnit) -> Double {
        switch targetUnit {
        case .kilometers: return toKilometers(realVal)
        case .miles: return realVal
        }
    }
}


@Observable
class SelectedUnits {
    var temperature: TemperatureUnit = .fahrenheit
    var speed: SpeedUnit = .milesPerHour
    var distance: DistanceUnit = .miles
    var precipitation: PrecipitationUnit = .inches
}

//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Anthony Polka on 11/19/24.
//

import Foundation
import SwiftUI

@Observable
class WeatherViewModel {
    
    var id: UUID = UUID()
    var data: DataModel? = nil
    var time: TimeInterval = Date.now.timeIntervalSince1970
    var locationStyle = LocationStyle()
    var selectedUnits: SelectedUnits = SelectedUnits()
    
    
    var currentTemp: Temperature {
        guard let temp = data?.weatherData.current.temp else {return Temperature(0.0, selectedUnits.temperature)}
        return Temperature(temp, selectedUnits.temperature)
    }
    
    var currentMax: Temperature {
        guard let max = data?.weatherData.daily?.first?.temp.max else {return Temperature(0.0, selectedUnits.temperature)}
        return Temperature(max, selectedUnits.temperature)
    }
    
    var currentMin: Temperature {
        guard let min = data?.weatherData.daily?.first?.temp.min else {return Temperature(0.0, selectedUnits.temperature)}
        return Temperature(min, selectedUnits.temperature)
    }
    
    var weatherData: WeatherData? {
        return data?.weatherData
    }
    
    var hourly: [Hourly] {
        guard let hourly = weatherData?.hourly else {return []}
        return hourly
    }
    
    var daily: [Daily] {
        guard let daily = weatherData?.daily else {return []}
        return daily
    }

    var isUserLocation: Bool {
        guard let val = data?.isUserLocation else {return false}
        return val
    }
    
    var name: String {
        guard let name = data?.location.locality else {return "--"}
        return name
    }
    
    var currentConditions: String {
        guard let condition = data?.weatherData.current.weather.first?.weatherDescription else {return ""}
        return condition.capitalized
    }
    
    var alerts: [Alert] {
        guard let alerts = data?.weatherData.alerts else {return []}
        return alerts
    }
    
    var icon: Image {
        guard let weather = self.getCurrent()?.weather.first else {return Image(systemName: "")}
        return getIcon(id: weather.weatherID, icon: weather.weatherIcon)
    }
    
    func getCurrent() -> Current? {
        return data?.weatherData.current
    }
    
    func getLocation() -> LocationModel? {
        return data?.location
    }
}

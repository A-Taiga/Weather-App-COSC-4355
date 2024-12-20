//
//  DataModel.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import Foundation
import SwiftData
import CoreLocation
import SwiftUI


@Model
final class DataModel: Identifiable {
    
    var id = UUID()
    var isUserLocation: Bool
    var location: LocationModel
    var listIndex: Int
    var weatherData: WeatherData
    var dateFetched: TimeInterval = Date.now.timeIntervalSince1970
    
    
    init(location: LocationModel, weatherData: WeatherData, listIndex: Int) {
        self.isUserLocation = false
        self.location = location
        self.weatherData = weatherData
        self.listIndex = listIndex
    }
    
    func fetch () async {
        do {
            let env = ProcessInfo.processInfo.environment
            guard let url = URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(location.lat)&lon=\(location.lon)&units=imperial&appid=\(env["API_KEY"] ?? "")") else {return}
            let (data, _) = try await URLSession.shared.data (from: url)
            self.weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            
            print(location.locality," updated at ", unixToTime(Int32(weatherData.current.dt), format: "hh:mm:ss a"))
            
        } catch {
            print(error)
        }
    }
}

@Model
final class LocationModel: Equatable {

    var locality: String
    var administrativeArea: String
    var subAdministrativeArea: String
    var lat: Double
    var lon: Double
    
    init(locality: String, administrativeArea: String, subAdministrativeArea: String, coordinates: CLLocationCoordinate2D) {
        self.locality = locality
        self.administrativeArea = administrativeArea
        self.subAdministrativeArea = subAdministrativeArea
        self.lat = coordinates.latitude
        self.lon = coordinates.longitude
    }
    
    static func ==(lhs: LocationModel, rhs: LocationModel) -> Bool {
        return lhs.locality == rhs.locality &&
        lhs.administrativeArea == rhs.administrativeArea &&
        lhs.subAdministrativeArea == rhs.subAdministrativeArea
    }
}

@Observable
class Style {
    
    var fontColor: Color = .white
    var backgroundImage = String()

    func setBackgroundImageDay(from icon: String) {
        switch (icon) {
        case "Clear":       backgroundImage = "clearDay"
        case "Rain":        backgroundImage = "stormDay"
        case "Drizze":      backgroundImage = "stormDay"
        case "Clouds":      backgroundImage = "partlyCloudyDay"
        case "Snow":        backgroundImage = "partlyCloudyDay"
        default:            backgroundImage = "clearDay"
        }
    }
    
    func setBackgroundImageNight(from icon: String) {
        switch (icon) {
        case "Clear":       backgroundImage = "clearNight"
        case "Rain":        backgroundImage = "stormNight"
        case "Drizze":      backgroundImage = "stormNight"
        case "Clouds":      backgroundImage = "cloudyNight"
        case "Snow":        backgroundImage = "cloudyNight"
        default:            backgroundImage = "clearNight"
        }
    }
}

//
//  DataModel.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import Foundation
import SwiftData
import CoreLocation



@Model
final class DataModel: Identifiable {
    
    var id = UUID()
    var location: LocationModel
    var listIndex: Int
    var weatherData: WeatherData
    init(location: LocationModel, weatherData: WeatherData, listIndex: Int) {
        self.location = location
        self.weatherData = weatherData
        self.listIndex = listIndex
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
        return lhs.locality == rhs.locality && lhs.administrativeArea == rhs.administrativeArea
    }
}

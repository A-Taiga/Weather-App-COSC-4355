//
//  Data.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import Foundation
import SwiftData


@Model
final class Location {
    var title: String
    var subtitle: String
    var lat: Double
    var lon: Double
    var weatherData: WeatherData?
    init(title: String, subtitle: String, lat: Double, lon: Double, weatherData: WeatherData?) {
        self.title = title
        self.subtitle = subtitle
        self.lat = lat
        self.lon = lon
        self.weatherData = weatherData
    }
}

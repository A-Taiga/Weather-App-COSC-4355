//
//  DataModel.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import Foundation
import SwiftData

@Model
final class DataModel: Identifiable {
    var id = UUID()
    var name: String
    var weatherData: WeatherData
    init(name: String, weatherData: WeatherData) {
        self.name = name
        self.weatherData = weatherData
    }
}

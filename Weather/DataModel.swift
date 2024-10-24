//
//  DataModel.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import Foundation
import SwiftData

@Model
final class DataModel: Identifiable, Hashable {
    var id = UUID()
    @Attribute(.unique) var name: String
    var weatherData: WeatherData
    init(name: String, weatherData: WeatherData) {
        self.name = name
        self.weatherData = weatherData
    }
}

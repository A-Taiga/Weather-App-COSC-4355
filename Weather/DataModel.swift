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
    var listIndex: Int
    var weatherData: WeatherData
    init(name: String, weatherData: WeatherData, listIndex: Int) {
        self.name = name
        self.weatherData = weatherData
        self.listIndex = listIndex
    }
}

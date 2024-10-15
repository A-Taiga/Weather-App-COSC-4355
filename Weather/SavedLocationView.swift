//
//  SavedLocationView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import SwiftUI

struct SavedLocationView: View {
    @Environment(Units.self) private var units
    @State private var model: Model

    
    init(name: String, weatherData: WeatherData, time: TimeInterval) {
        self.model = Model(name: name, weatherData: weatherData, time: time)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.name)
                    .font(.title)
                    .minimumScaleFactor(0.1)
                Text("\(toTime(utc: model.time))")
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            VStack {
                HStack {
                    getIcon(id: model.weather.weatherID, main: model.weather.weatherMain, icon: model.weather.weatherIcon)
                        .padding()
                    VStack {
                        Text("\(units.handleTemp(val: model.weatherData.current.temp))\(units.handleUnit(UnitsTemp.self))")
                            .font(.title)
                        Text("H: \(units.handleTemp(val: model.low)) L: \(units.handleTemp(val: model.high))")
                    }
                }
            }.frame(maxWidth: .infinity)
            
        }
        .frame(maxWidth: .infinity)
        .background(.blue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.red, lineWidth: 1))
    }
}

extension SavedLocationView {
    @Observable
    class Model {
        let name: String
        let weatherData: WeatherData
        let time: TimeInterval
        
        let weather: Weather
        let low: Double
        let high: Double
        
        
        init(name: String, weatherData: WeatherData, time: TimeInterval) {
            self.name = name
            self.weatherData = weatherData
            self.time = time
            self.weather = weatherData.current.weather[0]
            self.low = weatherData.daily[0].temp.min
            self.high = weatherData.daily[0].temp.max
        }
    }
}

#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        var body: some View {
            VStack {
                if let data = weatherData {
                    SavedLocationView(name: "Houston", weatherData: data, time: Date.now.timeIntervalSince1970)
                        .frame(height: 100)
                        .environment(Units())
                }
            }.task {
                do {
                    weatherData = try readUserFromBundle(fileName: "Houston")
                } catch {
                    print(error)
                }
            }
        }
    }
    return Preview()
}

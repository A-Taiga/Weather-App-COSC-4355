//
//  WeatherView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import SwiftUI

struct WeatherView: View {
    
    @Environment(Style.self) private var style
    @Environment(Units.self) private var units
    @State private var model: Model
    
    init(name: String, weatherData: WeatherData) {
        self.model = Model(name: name, weatherData: weatherData)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text(model.name)
                    .font(.largeTitle)
                Text("\(units.handleTemp(val: model.currentTemp)) \(units.handleUnit(UnitsTemp.self))")
                    .font(.largeTitle)
                Text("\(model.currentWeather)")
                    .font(.headline)
                HStack {
                    Text("L: \(units.handleTemp(val: model.currentLow)) H: \(units.handleTemp(val: model.currentHigh))")
                        .font(.headline)
                }
            }
    
            HourlyTileView(weatherData: model.weatherData)
                .foregroundStyle(.white)
                .padding()
                .frame(height: 220)
                .environment(units)
            DailyTileView(weatherData: model.weatherData)
                .foregroundStyle(.white)
                .padding()
                .environment(units)
            MoonPhaseTileView()
                .foregroundStyle(.white)
                .padding()
            
        }
        .background(LinearGradient(gradient: style.bgColor, startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}


extension WeatherView {
    @Observable
    class Model {
        
        let name: String
        let weatherData: WeatherData
        let currentTemp: Double
        let currentWeather: String
        let currentLow: Double
        let currentHigh: Double
        
        init(name: String, weatherData: WeatherData) {
            self.name = name
            self.weatherData = weatherData
            self.currentTemp = weatherData.current.temp
            self.currentWeather = weatherData.current.weather[0].weatherDescription
            self.currentLow = weatherData.daily[0].temp.min
            self.currentHigh = weatherData.daily[0].temp.max
        }
    }
}

#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        @State var style = Style()
        var body: some View {
            VStack {
                if let weatherData {
                    WeatherView(name: "Some Place", weatherData: weatherData)
                        .environment(style)
                        .environment(Units())
                }
            }.task {
//                await fetchData(lat: 42.713, lon: -73.204) { data in
//                    self.weatherData = data
//                }
                do {
                    weatherData = try readUserFromBundle(fileName: "SomePlace")
                } catch {
                    print(error)
                }
            }
        }
    }
    return Preview()
}

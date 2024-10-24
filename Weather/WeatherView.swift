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
    @State private var model = Model()
    
    let name: String
    let weatherData: WeatherData
    let currentTemp: Double
    let currentWeather: String
    let currentLow: Double
    let currentHigh: Double
    let alerts: [Alert]?

    init(name: String, weatherData: WeatherData) {
        self.name = name
        self.weatherData = weatherData
        self.currentTemp = weatherData.current.temp
        self.currentWeather = weatherData.current.weather[0].weatherDescription
        self.currentLow = weatherData.daily[0].temp.min
        self.currentHigh = weatherData.daily[0].temp.max
        self.alerts = weatherData.alerts
    }
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Image(style.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .ignoresSafeArea()
            .overlay(.ultraThinMaterial)
            
            ScrollView {
                VStack {
                    Text(name)
                        .font(.largeTitle)
                    Text("\(units.handleTemp(val: currentTemp)) \(units.handleUnit(UnitsTemp.self))")
                        .font(.largeTitle)
                    Text("\(currentWeather.capitalized)")
                        .font(.headline)
                    HStack {
                        Text("L: \(units.handleTemp(val: currentLow)) H: \(units.handleTemp(val: currentHigh))")
                            .font(.headline)
                    }
                }
                
                if let _ = alerts {alertTile}
                
                HourlyTileView(weatherData: weatherData)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(height: 230)
                    .environment(units)
                
                DailyTileView(weatherData: weatherData)
                    .foregroundStyle(.white)
                    .padding()
                    .environment(units)
                WindTileView(weatherData: weatherData)
                    .foregroundStyle(.white)
                    .padding()
                
                MoonPhaseTileView()
                    .foregroundStyle(.white)
                    .padding()
            }
        }
        .onAppear(perform: setStyle)
        .sheet(isPresented: $model.alertTap) {
            AlertView(alerts: alerts!,
                      timeZone: weatherData.timezone,
                      didExit: $model.alertTap)
            .preferredColorScheme(.dark)
        }
    }
}

extension WeatherView {
    var alertTile: some View {
        HStack(alignment: .center) {
            Image(systemName: "exclamationmark.triangle.fill")
                .symbolRenderingMode(.multicolor)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text(weatherData.alerts!.first!.event)
            if (weatherData.alerts!.count > 1) {
                Text("and \(weatherData.alerts!.count-1) more")
            }
        }
        .padding()
        .background(.black.opacity(0.2))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {model.alertTap = true}
    }
}

extension WeatherView {
    
    func setStyle() {
        if (weatherData.current.weather[0].weatherIcon.last == "d") {
            style.setBackgroundImageDay(from: weatherData.current.weather[0].weatherMain)
        }
        else {style.setBackgroundImageNight(from: weatherData.current.weather[0].weatherMain)}
    }
}


extension WeatherView {
    @Observable
    class Model {
        var alertTap = false
    }
}

#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        @State var style = Style()
        var body: some View {
            VStack {
                if let weatherData {
                    WeatherView(name: "Gold Hill", weatherData: weatherData)
                        .environment(style)
                        .environment(Units())
                }
            }.task {
//                await fetchData(lat: 42.713, lon: -73.204) { data in
//                    self.weatherData = data
//                }
                do {
                    weatherData = try readUserFromBundle(fileName: "GoldHillOR")
                } catch {
                    print(error)
                }
            }
        }
    }
    return Preview()
}

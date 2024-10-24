//
//  SavedLocationView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import SwiftUI


struct SavedLocationView: View {
    
    @Environment(Units.self) private var units
    @State private var style = Style()
    private let weatherData: WeatherData
    private let time: TimeInterval
    private let name: String
    private let weather: Weather
    private let low: Double
    private let high: Double
    private let currentTemp: Double
    private let sunset: TimeInterval
    private let sunrise: TimeInterval
    
    
    init(name: String, weatherData: WeatherData, time: TimeInterval) {
        self.weatherData = weatherData
        self.time = adjustedTimeInterval(from: time, toTimeZoneIdentifier: weatherData.timezone)
        self.name = name
        self.weather = weatherData.current.weather[0]
        self.low = weatherData.daily[0].temp.min
        self.high = weatherData.daily[0].temp.max
        self.currentTemp = weatherData.current.temp
        self.sunset = adjustedTimeInterval(from: weatherData.current.sunset, toTimeZoneIdentifier: weatherData.timezone)
        self.sunrise = adjustedTimeInterval(from: weatherData.current.sunrise, toTimeZoneIdentifier: weatherData.timezone)
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
            
            HStack {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.title)
                        .minimumScaleFactor(0.1)
                    Text("\(toTime(utc: time))")
                    if let _ = weatherData.alerts {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                VStack {
                    HStack {
                        getIcon(id: weather.weatherID, main: weather.weatherMain, icon: weather.weatherIcon)
                            
                        VStack {
                            Text("\(units.handleTemp(val: currentTemp))\(units.handleUnit(UnitsTemp.self))")
                                .font(.title)
                            HStack {
                                Text("H: \(units.handleTemp(val: low))")
                                Text("L: \(units.handleTemp(val: high))")
                            }.fixedSize(horizontal: true, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .overlay {
                NavigationLink(destination: WeatherView(name: name, weatherData: weatherData)
                    .environment(units)
                    .environment(style)) {
                        Rectangle().fill(.clear)
                    }.opacity(0)
            }
        }
        .foregroundStyle(style.fontColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear(perform: setStyle)
    }
}

extension SavedLocationView {
    
    func setStyle() {
        
        if (weather.weatherIcon.last == "d") {
            style.setBackgroundImageDay(from: weather.weatherMain)
        }
        else {style.setBackgroundImageNight(from: weather.weatherMain)}
    }
}

@Observable
class Style {
    
    var fontColor: Color = .white
    var backgroundImage: String = ""
    
//    func setFont(icon: String) {
//        switch (icon) {
//        case "Clear":               fontColor = .white
//        case "clear-night":         fontColor = .white
//        case "rain":                fontColor = .black
//        case "cloudy":              fontColor = .black
//        case "partly-cloudy-day":   fontColor = .black
//        case "partly-cloudy-night": fontColor = .white
//        case "snow":                fontColor = .black
//        case "sleet":               fontColor = .black
//        case "wind":                fontColor = .black
//        case "fog":                 fontColor = .black
//        default:                    fontColor = .white
//        }
//    }
    
    func setBackgroundImageDay(from icon: String) {
        switch (icon) {
        case "Clear":       backgroundImage = "clearDay"
        case "Rain":        backgroundImage = "stormDay"
        case "Drizze":      backgroundImage = "stormDay"
        case "Clouds":      backgroundImage = "partlyCloudyDay"
        case "Snow":        backgroundImage = ""
        default:            backgroundImage = ""
        }
    }
    
    func setBackgroundImageNight(from icon: String) {
        switch (icon) {
        case "Clear":       backgroundImage = "clearNight"
        case "Rain":        backgroundImage = "stormNight"
        case "Drizze":      backgroundImage = "stormNight"
        case "Clouds":      backgroundImage = "cloudyNight"
        case "Snow":        backgroundImage = ""
        default:            backgroundImage = ""
        }
    }
}


#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        var body: some View {
            NavigationStack {
                if let data = weatherData {
                    List {
                        Section {
                            SavedLocationView(name: "Gold Hill", weatherData: data, time: Date.now.timeIntervalSince1970)
                                .frame(height: 100)
                                .padding()
                                .environment(Units())
                        }
                    }
                    .listStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }.task {
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

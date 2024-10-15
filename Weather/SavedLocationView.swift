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
        ZStack {
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
            NavigationLink(destination: WeatherView(name: model.name, weatherData: model.weatherData)
                .environment(units)
                .environment(model.style)) {
                    Rectangle().fill(.clear)
                }
        }
        .frame(maxWidth: .infinity)
        .background(LinearGradient(gradient: model.style.bgColor, startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.red, lineWidth: 1))
        .onAppear() {model.style.setBackground(icon: model.weather.weatherMain)}
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
        
        var style = Style()
        
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

@Observable
class Style {
    var fontColor: Color = .white
    var bgColor: Gradient = Gradient(colors: [Color("clear2"), Color("storm2")])
    
    func setFont(icon: String) {
        switch (icon) {
        case "clear-day":           fontColor = .black
        case "clear-night":         fontColor = .white
        case "rain":                fontColor = .black
        case "cloudy":              fontColor = .black
        case "partly-cloudy-day":   fontColor = .black
        case "partly-cloudy-night": fontColor = .white
        case "snow":                fontColor = .black
        case "sleet":               fontColor = .black
        case "wind":                fontColor = .black
        case "fog":                 fontColor = .black
        default:                    fontColor = .white
        }
    }
    
    func setBackground(icon: String) {
        switch (icon) {
//        case "clear sky":           bgColor = Gradient(colors: [Color("clear1"), Color("clear2"), Color("clear3"), Color("clear4")])
//        case "clear-night":         bgColor = Gradient(colors: [Color("night1"), Color("night2"), Color("night3"), Color("night4")])
        case "Rain":                bgColor = Gradient(colors: [Color("storm3"), Color("storm2"), Color("storm2"), Color("storm3")])
        case "Drizze":                bgColor = Gradient(colors: [Color("storm3"), Color("storm2"), Color("storm2"), Color("storm3")])
        case "Clouds":              bgColor = Gradient(colors: [Color("cloudy1"), Color("cloudy2"), Color("cloudy3"), Color("cloudy4")])
//        case "partly-cloudy-day":   bgColor = Gradient(colors: [Color("cloudy1"), Color("cloudy3"), Color("storm2"), Color("storm1")])
//        case "partly-cloudy-night": bgColor = Gradient(colors: [Color("night1"), Color("night2"), Color("night3"), Color("night4")])
        case "Snow":                bgColor = Gradient(colors: [Color("snow2"), Color("snow3"), Color("snow4"), Color("snow4")])
//        case "sleet":               bgColor = Gradient(colors: [Color("sleet4"), Color("sleet4"), Color("sleet3"), Color("sleet3")])
//        case "wind":                bgColor = Gradient(colors: [Color("clear1"), Color("clear3"), Color("clear4"), Color("clear4")])
//        case "fog":                 bgColor = Gradient(colors: [Color("storm1"), Color("storm2"), Color("storm2"), Color("storm3")])
        default:                    bgColor = Gradient(colors:[.black])
        }
    }
}



/*
 
 case "Thunderstorm": result = thunderstorm[id]
 case "Drizzle":      result = drizzleDay[id]
 case "Rain":         result = rainDay[id]
 case "Snow":         result = snowDay[id]
 case "Atmosphere":   result = atmosphereDay[id]
 case "Clouds":       result = cloudsDay[id]
 case "Clear":        result = "sun.max.fill"
 
 
 
 
 */





#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        var body: some View {
            NavigationStack {
                if let data = weatherData {
                    SavedLocationView(name: "Some Place", weatherData: data, time: Date.now.timeIntervalSince1970)
                        .frame(height: 100)
                        .environment(Units())
                }
            }.task {
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

//
//  SavedLocationView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import SwiftUI


@Observable
class WeatherModel {
    var weatherData: WeatherData
    init(weatherData: WeatherData) {
        self.weatherData = weatherData
    }
}

struct SavedLocationView: View {
    @Environment(Units.self) private var units
    @State private var style = Style()
    private let weatherData: WeatherData
    private let time: TimeInterval
    private let name: String
    
    init(name: String, weatherData: WeatherData, time: TimeInterval) {
        self.weatherData = weatherData
        self.time = adjustedTimeInterval(from: time, toTimeZoneIdentifier: weatherData.timezone)
        self.name = name
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
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
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
                        Spacer()
                        getIcon(id: weatherData.current.weather[0].weatherID, icon: weatherData.current.weather[0].weatherIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolRenderingMode(.multicolor)
                        VStack {
                            Text("\(units.handleTemp(val: weatherData.current.temp))\(units.handleUnit(UnitsTemp.self))")
                                .font(.title)
                            HStack {
                                Text("H: \(units.handleTemp(val: weatherData.daily[0].temp.min))")
                                Text("L: \(units.handleTemp(val: weatherData.daily[0].temp.max))")
                            }.fixedSize(horizontal: true, vertical: true)
                        }
                        .minimumScaleFactor(0.01)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .overlay {
                NavigationLink(destination: WeatherView(name: name, weatherData: weatherData, isSheet: false)
                    .environment(units)
                    .environment(style)) {
                        Rectangle().fill(.clear)
                        //                            .matchedTransitionSource(id: "icon", in: namespace)
                    }
                    .navigationBarBackButtonHidden(true)
                    .opacity(0)
                }
            }
            .foregroundStyle(style.fontColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onAppear(perform: setStyle)
        }
}

extension SavedLocationView {
    
    func setStyle() {
        if (weatherData.current.weather[0].weatherIcon.last == "d") {
            style.setBackgroundImageDay(from: weatherData.current.weather[0].weatherMain)
        }
        else {style.setBackgroundImageNight(from: weatherData.current.weather[0].weatherMain)}
    }
}

@Observable
class Style {
    
    var fontColor: Color = .white
    var backgroundImage = String()

    func setBackgroundImageDay(from icon: String) {
        switch (icon) {
        case "Clear":       backgroundImage = "clearDay"
        case "Rain":        backgroundImage = "stormDay"
        case "Drizze":      backgroundImage = "stormDay"
        case "Clouds":      backgroundImage = "partlyCloudyDay"
        case "Snow":        backgroundImage = "partlyCloudyDay"
        default:            backgroundImage = "clearDay"
        }
    }
    
    func setBackgroundImageNight(from icon: String) {
        switch (icon) {
        case "Clear":       backgroundImage = "clearNight"
        case "Rain":        backgroundImage = "stormNight"
        case "Drizze":      backgroundImage = "stormNight"
        case "Clouds":      backgroundImage = "cloudyNight"
        case "Snow":        backgroundImage = "cloudyNight"
        default:            backgroundImage = "clearNight"
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

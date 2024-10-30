//
//  WeatherView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import SwiftUI

struct WeatherView: View {
    
    @Environment(\.presentationMode) var presentation
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
    let isSheet: Bool
    
    
    


    init(name: String, weatherData: WeatherData, isSheet: Bool) {
        self.name = name
        self.weatherData = weatherData
        self.currentTemp = weatherData.current.temp
        self.currentWeather = weatherData.current.weather[0].weatherDescription
        self.currentLow = weatherData.daily[0].temp.min
        self.currentHigh = weatherData.daily[0].temp.max
        self.alerts = weatherData.alerts
        self.isSheet = isSheet
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
            VStack(spacing: 0) {
                ScrollView(.vertical) {
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

                        if let _ = alerts {alertTile}
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "clock")
                                    .symbolRenderingMode(.monochrome)
                                Text("Hourly Forecast")
                                    .font(.title3)
                                Spacer()
                            }
                            .padding()
                            Divider().overlay(.white)
                            HourlyTileView(weatherData: weatherData.hourly)
                                .foregroundStyle(.white)
                                .padding()
                                .environment(units)
                        }
                        .frame(height: 250)
                        .background(.black.opacity(0.3))
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                        
                        DailyTileView(daily: weatherData.daily)
                            .foregroundStyle(.white)
                            .padding()
                            .environment(units)
                        WindTileView(windSpeed: weatherData.current.wind_speed,
                                     windDirection: weatherData.current.wind_deg,
                                     windGust: weatherData.current.wind_gust ?? 0.0)
                            .foregroundStyle(.white)
                            .padding()
                        MoonPhaseTileView()
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
                if !isSheet {
                    ZStack {
                        Rectangle().fill(.ultraThinMaterial).frame(height: 80)
                        HStack {
                            Button {
                                model.showSettings = true
                            } label: {
                                Image(systemName: "gearshape")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                            }
                            .padding(.leading, 50)
                            Spacer()
                            Button {
                                presentation.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "list.bullet")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                            }.padding(.trailing, 50)
                        }
                    }
                }
                if isSheet {Spacer()}
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $model.alertTap) {
            AlertView(alerts: alerts!,
                      timeZone: weatherData.timezone,
                      didExit: $model.alertTap)
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $model.showSettings) {
            @Bindable var u = units
            UnitsView(units: Binding(get: {u}, set: {u = $0}))
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
    @Observable
    class Model {
        var alertTap = false
        var showSettings = false
    }
}

#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        @State var style = Style()
        var body: some View {
            VStack {
                if let weatherData {
                    WeatherView(name: "New York", weatherData: weatherData, isSheet: false)
                        .environment(style)
                        .environment(Units())
                }
            }.task {
                do {
                    weatherData = try readUserFromBundle(fileName: "NewYork1")
                } catch {
                    print(error)
                }
            }
        }
    }
    return Preview()
}

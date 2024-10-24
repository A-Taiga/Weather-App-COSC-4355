//
//  WindTileView.swift
//  Weather
//
//  Created by Anthony Polka on 10/20/24.
//

import SwiftUI

struct WindTileView: View {
    @Environment(Units.self) var units
    @State private var model: Model
    
    init(weatherData: WeatherData) {
        self.model = Model(weatherData: weatherData)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "wind")
                    .symbolRenderingMode(.multicolor)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text("Wind")
            }
            .frame(height: 20)
            .padding([.leading, .top])
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Speed")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(units.handleWind(val: model.windSpeed)) \(units.handleUnit(UnitsSpeed.self))")
                    }
                    Divider()
                    HStack {
                        Text("Gust")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(units.handleWind(val: model.windGust)) \(units.handleUnit(UnitsSpeed.self))")
                    }
                    Divider()
                    HStack {
                        Text("Direction")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(Int(model.windDirection))° \(model.getWindBearing())")
                    }
                }.padding()
                
                ZStack {
                    ForEach(1...120, id: \.self) { index in
                        Rectangle()
                            .frame(width: 1, height: 10)
                            .padding(.bottom, 100)
                            .opacity(((index % 30) != 0) ? 0.5 : 1)
                            .rotationEffect(Angle(degrees: Double(index) * 3))
                    }
                    Text("N")
                        .padding(.bottom, 130)
                    Text("S")
                        .padding(.top, 130)
                    Text("E")
                        .padding(.leading, 130)
                    Text("W")
                        .padding(.trailing, 130)
                    Rectangle()
                        .frame(width: 3, height: 100)
                        .overlay(alignment: .top) {
                            Image(systemName: "location.north.fill")
                                .frame(width: 10, height: 10)
                                .foregroundStyle(.white)
                        }
                        .rotationEffect(Angle(degrees: model.windDirection - 90))
                }
                .frame(minWidth: 180, maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(.black.opacity(0.2))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension WindTileView {
    @Observable
    class Model {
        
        let windSpeed: Double
        let windDirection: Double
        let windGust: Double

        
        init(weatherData: WeatherData) {
            self.windSpeed = weatherData.current.wind_speed
            self.windDirection = weatherData.current.wind_deg
            self.windGust = weatherData.current.wind_gust ?? 0
        }
        
        func getWindBearing() -> String {
            switch windDirection - 90 {
            case 0: "N"
            case 90: "E"
            case 180: "S"
            case 270: "W"
            case 0...22.5:  "N"
            case 22.5...67.5:   "NE"
            case 67.5...112.5:  "E"
            case 112.5...157.5: "SE"
            case 157.5...202.5: "S"
            case 202.5...247.5: "SW"
            case 247.5...292.5: "W"
            case 292.5...337.5: "NW"
            default: ""
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        var body: some View {
            VStack {
                if let data = weatherData {
                    WindTileView(weatherData: data)
                        .padding()
                        .environment(Units())
                }
            }.task {
                do {
                   try weatherData = readUserFromBundle(fileName: "SomePlace")
                } catch {
                    print(error)
                }
            }
        }
    }
    return Preview()
}

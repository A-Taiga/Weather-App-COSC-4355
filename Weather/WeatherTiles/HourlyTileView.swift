//
//  HourlyTileView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import SwiftUI
import Charts
struct HourlyTileView: View {
    @Environment(Units.self) private var units
    @State private var model: Model
    let weatherData: WeatherData
    init(weatherData: WeatherData) {
        self.model = Model(weatherData: weatherData)
        self.weatherData = weatherData
    }
    
    var body: some View {
        Chart(weatherData.hourly[0..<12]) { hour in
            PointMark(x: .value("", hour.dt.formatted("dha")),
                      y: .value("", units.handleTemp(val: hour.temp)))
            .annotation {
                Text("\(units.handleTemp(val: hour.temp))")
            }
            LineMark(x: .value("", hour.dt.formatted("dha")),
                     y: .value("", units.handleTemp(val: hour.temp)))
        }
        .chartYAxis(.hidden)
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 5)
        .chartXAxis {
            AxisMarks(position: .top) { value in
                AxisTick(stroke: .init()).foregroundStyle(.white)
                AxisGridLine(stroke: .init()).foregroundStyle(.white)
                AxisValueLabel() {
                    Text(weatherData.hourly[value.index].dt.formatted("h a"))
                        .foregroundStyle(.white)
                        .font(.title3)
                }
            }
            AxisMarks(position: .bottom) { value in
                AxisTick(stroke: .init()).foregroundStyle(.white)
                AxisValueLabel() {
                    gridIcons(value.index)
                }
            }
        }
    }
    
    func getRange() -> ClosedRange<Int> {
        let min = units.handleTemp(val: model.minHourlyTemp)
        let max = units.handleTemp(val: model.maxHourlyTemp)
        return min-50...max+50
    }

    @ViewBuilder
    func gridIcons(_ index: Int) -> some View {
        VStack {
            getIcon(id: model.hourly[index].weather[0].weatherID,
                    main: model.hourly[index].weather[0].weatherMain,
                    icon: model.hourly[index].weather[0].weatherIcon)
                    .resizable().aspectRatio(contentMode: .fit).symbolRenderingMode(.multicolor)
            .frame(width: 40, height: 40)
            .shadow(radius: 10)
            let set = ["Rain", "Thunderstorms"]
            if set.contains(model.hourly[index].weather[0].weatherMain) {
                Text("\(units.handlePrecipitation(val: model.hourly[index].pop))")
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
            } else {
                Text(" ")
            }
        }
    }
}

extension HourlyTileView {
    @Observable
    class Model {
        
        let hourly: [Hourly]
        let maxHourlyTemp: Double
        let minHourlyTemp: Double
        
        init (weatherData: WeatherData) {
            self.hourly = weatherData.hourly
            self.maxHourlyTemp = hourly.map{$0.temp}.max()!
            self.minHourlyTemp = hourly.map{$0.temp}.min()!
        }
        
        func toHourDay(utc: TimeInterval, timeZone: String? = nil) -> String {
            let date = Date(timeIntervalSince1970: utc)
            let dateFormatter = DateFormatter()
            if let timeZone {
                dateFormatter.timeZone = TimeZone(identifier: timeZone)
            }
            dateFormatter.dateFormat = "dha"
            return dateFormatter.string(from: date)
        }
        
        func toHour(utc: TimeInterval, timeZone: String? = nil) -> String {
            let date = Date(timeIntervalSince1970: utc)
            let dateFormatter = DateFormatter()
            if let timeZone {
                dateFormatter.timeZone = TimeZone(identifier: timeZone)
            }
            dateFormatter.dateFormat = "ha"
            return dateFormatter.string(from: date)
        }
    }
}

#Preview {
    
    struct Preview: View {
        @State var units = Units()
        @State var weatherData: WeatherData?
        var body: some View {
            VStack {
                if let weatherData {
                    HourlyTileView(weatherData: weatherData)
                        .foregroundStyle(.white)
                        .frame(height: 150)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .environment(units)
                }
            }
            .onAppear() {
                units.temp = .celsius
            }
            .task {
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

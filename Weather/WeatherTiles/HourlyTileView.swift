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
    
    init(weatherData: WeatherData) {
        self.model = Model(weatherData: weatherData)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(.black)
                .background(.ultraThinMaterial)
                .opacity(0.3)
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "clock")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Text("Hourly Forecast")
                }
                .frame(height: 20)
                .padding([.top, .leading])
                Divider().overlay(.primary)
                Chart {
                    ForEach(model.hourly) { hour in
                        PointMark(x: .value("", model.toHourDay(utc: hour.dt)),
                                  y: .value("", units.handleTemp(val: hour.temp)))
                        .annotation(position: .top, alignment: .center) {
                            Text("\(units.handleTemp(val: hour.temp))")
                        }
                        LineMark(x: .value("", model.toHourDay(utc: hour.dt)),
                                 y: .value("", units.handleTemp(val: hour.temp)))
                    }
                }
                .chartYAxis(.hidden)
                .chartYScale(domain: model.minHourlyTemp - 50...model.maxHourlyTemp + 50)
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 6)
                .chartXAxis {
                    AxisMarks(preset: .inset, position: .top, values: .automatic) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2]))
                        AxisValueLabel(anchor: .top) {
                            Text(model.toHour(utc: model.hourly[value.index].dt))
                                .foregroundStyle(.black)
                                .font(.headline)
                                .fontWeight(.heavy)
                        }
                    }
                    AxisMarks(preset: .inset, position: .bottom, values: .automatic) { value in
                        AxisValueLabel() {gridIcons(value.index)}
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func gridIcons(_ index: Int) -> some View{
        VStack {
            getIcon(id: model.hourly[index].weather[0].weatherID,
                    main: model.hourly[index].weather[0].weatherMain,
                    icon: model.hourly[index].weather[0].weatherIcon)
            .frame(width: 30, height: 30)
            .shadow(radius: 10)
            let set = ["Rain", "Thunderstorms"]
            if set.contains(model.hourly[index].weather[0].weatherMain) {
                Text("\(units.handlePrecipitation(val: model.hourly[index].pop))")
                    .fontWeight(.heavy)
                    .foregroundStyle(.black)
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
        @State var weatherData: WeatherData?
        var body: some View {
            VStack {
                if let weatherData {
                    HourlyTileView(weatherData: weatherData)
                        .foregroundStyle(.black)
                        .frame(height: 200)
                        .padding()
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

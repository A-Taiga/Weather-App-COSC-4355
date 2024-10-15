//
//  DailyTileView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import SwiftUI

struct DailyTileView: View {
    @Environment(Units.self) private var units
    @State private var model: Model
    init(weatherData: WeatherData) {
        self.model = Model(weatherData: weatherData)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(.black)
                .opacity(0.3)
                .blur(radius: 1)
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolRenderingMode(.multicolor)
                    Text("Daily Forecast")
                }
                .frame(height: 20)
                .padding([.top, .leading])
                Divider()
                VStack(alignment: .leading) {
                    row(model.daily[0], dayName: "Today")
                        .padding([.top, .bottom], -10)
                    ForEach(model.daily[1..<model.daily.count]) { day in
                        Divider().overlay(.white)
                        row(day)
                            .padding([.top, .bottom], -10)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func row (_ day: Daily, dayName: String? = nil) -> some View {
        HStack {
            if let dayName {
                Text(dayName)
                    .font(.title3)
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            } else {
                Text("\(model.toWeekDay(utc: day.dt))")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            getIcon(id: day.weather[0].weatherID,
                    main: day.weather[0].weatherMain,
                    icon: day.weather[0].weatherIcon)
            .frame(width: 30, height: 30)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity)
            (Text("\(units.handleTemp(val: day.temp.min))\(units.handleUnit(UnitsTemp.self))") +
            Text(" -> \(units.handleTemp(val: day.temp.max))\(units.handleUnit(UnitsTemp.self))"))
                .frame(maxWidth: .infinity)
        }
    }
}

extension DailyTileView {
    @Observable
    class Model {
        let daily: [Daily]
        
        init(weatherData: WeatherData) {
            self.daily = weatherData.daily
        }
        
        func toWeekDay(utc: TimeInterval, timeZone: String? = nil) -> String {
            let date = Date(timeIntervalSince1970: utc)
            let dateFormatter = DateFormatter()
            if let timeZone {
                dateFormatter.timeZone = TimeZone(identifier: timeZone)
            }
            dateFormatter.dateFormat = "EEE"
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
                    DailyTileView(weatherData: weatherData)
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

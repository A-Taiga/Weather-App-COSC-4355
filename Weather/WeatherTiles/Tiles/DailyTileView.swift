//
//  DailyTileView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import SwiftUI

struct DailyTileView: View {
    @Environment(SelectedUnits.self) private var selectedUnits
    private let daily: [Daily]

    init(daily: [Daily]) {
        self.daily = daily
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo  in
                RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
            }
            
            VStack(alignment: .leading) {
                
                HStack {
                    Image(systemName: "calendar")
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Text("Daily Forecast")
                }
                .frame(height: 20)
                .padding([.leading, .top])
                
                Divider().overlay(.white)
                
                row(daily[0], dayName: "Today")
                    .padding([.top, .bottom], -10)
                ForEach(daily[1..<daily.count]) { day in
                    Divider().overlay(.white)
                    row(day)
                        .padding([.top, .bottom], -10)
                }
            }
        }
        .padding()
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
                Text("\(toWeekDay(utc: day.dt))")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            getIcon(id: day.weather[0].weatherID, icon: day.weather[0].weatherIcon)
                    .resizable().aspectRatio(contentMode: .fit).symbolRenderingMode(.multicolor)

            .frame(width: 30, height: 30)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity)
            (Text("\(Temperature(day.temp.min, selectedUnits.temperature)) ") +
             Text(Image(systemName: "arrow.right")) +
             Text(" \(Temperature(day.temp.max, selectedUnits.temperature))"))
                .frame(maxWidth: .infinity)
        }
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

extension DailyTileView {
    @Observable
    class Model {
      
        
        
    }
}

#Preview {
    
    struct Preview: View {
        @State var weatherData: WeatherData?
        var body: some View {
            VStack {
                if let daily = weatherData?.daily {
                    DailyTileView(daily: daily)
                        .padding()
                        .environment(SelectedUnits())
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

//
//  WeeklyView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import SwiftUI

struct WeeklyView: View {
    
    @Binding var weatherData: WeatherData?
    @Environment(Units.self) var units
    var body: some View {
        VStack(alignment: .leading) {
            if let weatherData = weatherData {
                ForEach(weatherData.daily.data[0...6], id: \.self) { day in
                    row(day: day)
                    Divider()
                        .overlay(.black)
                }
                row (day: weatherData.daily.data[7])
            }
        }
        .padding()
    }
    
    @ViewBuilder
    func row (day: Daily.Item) -> some View {
        HStack(alignment: .center) {
            Text(unixToTime(day.time, format: "EEE"))
                .frame(maxWidth: .infinity, alignment: .leading)
            getSymbol(icon: day.icon)
                .frame(width: 25, height: 25, alignment: .trailing)
            (Text("L: \(units.handleTemp(val: day.temperatureHigh))") +
            Text(" H: \(units.handleTemp(val: day.temperatureLow))"))
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        var body: some View {
            WeeklyView(weatherData: $weatherData)
                .font(.system(size: 15))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .padding()
                .task {
                    weatherData = readUserFromBundle(fileName: "NewYorkCity")
                }
                .environment(Units())
        }
    }
    return Preview()
}

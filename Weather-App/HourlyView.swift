//
//  HourlyView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import SwiftUI
import Charts


struct HourlyView: View{

    @Binding var weatherData: WeatherData?

    var body: some View {
        ZStack {
            if let weatherData = weatherData {
                Chart {
                    ForEach(weatherData.hourly.data[0...23], id: \.self) { hour in
                        PointMark (
                            x: .value("", unixToTime(hour.time, format: "ha")),
                            y: .value("", hour.temperature)
                        )
                        .foregroundStyle(.black)
                        .annotation(position: .top, alignment: .center) {
                            Text("\(Int(hour.temperature))")
                            
                        }
                        LineMark (
                            x: .value("", unixToTime(hour.time, format: "ha")),
                            y: .value("", hour.temperature)
                        ).foregroundStyle(.black)
                    }
                }
                .chartScrollableAxes(.horizontal)
                .chartYAxis(.hidden)
                .chartYScale(domain: yDomain())
                .chartXVisibleDomain(length: 6)
                .chartXAxis {
                    AxisMarks(preset: .inset, position: .top, values: .automatic) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2]))
                        AxisValueLabel(anchor: .top)
                    }
                    AxisMarks(preset: .inset, position: .bottom, values: .automatic) { value in
                        AxisValueLabel() {chartXLabels(index: value.index)}
                    }
                }
            }
        }
        .padding()
    }

    func yDomain () -> ClosedRange<Int> {
        guard let weatherData = weatherData else {return 0...0}
        return Int(weatherData.daily.data[0].temperatureLow)-50...Int(weatherData.daily.data[0].temperatureHigh)+50
    }
    
    @ViewBuilder
    func chartXLabels (index: Int) -> some View {
        VStack {
            let symbol = weatherData!.hourly.data[index].icon
            getSymbol(icon: symbol)
                .frame(width: 30, height: 30)
            if symbol == "rain" {
                Text("\(Int(weatherData!.hourly.data[index].precipProbability * 100))%")
                    .foregroundStyle(Color(red: 0.4627, green: 0.8392, blue: 255.0))
            } else if symbol == "wind" {
                Text("\(Int(weatherData!.hourly.data[index].windGust))MPH")
                    .foregroundStyle(Color(red: 0.4627, green: 0.8392, blue: 255.0))
            } else {
                Text(" ")
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        var body: some View {
            HourlyView(weatherData: $weatherData)
                .frame(height: 250)
                .padding()
                .task {
                    weatherData = readUserFromBundle(fileName: "JeffersonCity")
                }
        }
    }
    return Preview()
}

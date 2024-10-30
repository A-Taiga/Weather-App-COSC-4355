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
    @State private var model = Model()
    private let weatherData: [Hourly]
    
    init(weatherData: [Hourly]) {
        self.weatherData = weatherData
    }
    
    var body: some View {
        Chart(weatherData[0...24]) { hour in
            PointMark(x: .value("", hour.dt.formatted("dha")),
                      y: .value("", units.handleTemp(val: hour.temp)))
            .annotation {
                Text("\(units.handleTemp(val: hour.temp))")
            }
            LineMark(x: .value("", hour.dt.formatted("dha")),
                     y: .value("", units.handleTemp(val: hour.temp)))
        }
        .chartScrollableAxes(.horizontal)
        .chartYAxis(.hidden)
        .chartXVisibleDomain(length: 5)
        .chartXAxis {
            AxisMarks(position: .top) { value in
                AxisTick(stroke: .init()).foregroundStyle(.white)
                AxisGridLine(stroke: .init()).foregroundStyle(.white)
                AxisValueLabel() {
                    Text(weatherData[value.index].dt.formatted("h a"))
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

    @ViewBuilder
    func gridIcons(_ index: Int) -> some View {
        VStack {
            getIcon(id: weatherData[index].weather[0].weatherID, icon: weatherData[index].weather[0].weatherIcon)
                    .resizable().aspectRatio(contentMode: .fit).symbolRenderingMode(.multicolor)
            .frame(width: 40, height: 40)
            .shadow(radius: 10)
            let set = ["Rain", "Thunderstorms"]
            if set.contains(weatherData[index].weather[0].weatherMain) {
                Text("\(units.handlePrecipitation(val: weatherData[index].pop))")
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
        
    }
}

#Preview {
    
    struct Preview: View {
        @State var units = Units()
        @State var weatherData: WeatherData?
        var body: some View {
            VStack {
                if let weatherData {
                    HourlyTileView(weatherData: weatherData.hourly)
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
                    weatherData = try readUserFromBundle(fileName: "Houston1")
                } catch {
                    print(error)
                }
            }
        }
    }
    return Preview()
}

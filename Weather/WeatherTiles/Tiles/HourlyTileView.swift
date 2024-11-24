//
//  HourlyTileView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import SwiftUI
import Charts
struct HourlyTileView: View {
    
    @Environment(SelectedUnits.self) private var selectedUnits
    @State private var showSheet = false
    private let weatherData: [Hourly]

    
    init(weatherData: [Hourly]) {
        self.weatherData = weatherData
    }
    
    var body: some View {
        
        ZStack {
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
            }
            
            VStack(alignment: .leading) {
                
                HStack {
                    Image(systemName: "clock.fill")
                    Text("Hourly Forecast")
                }
                .padding([.leading, .top])
                
                Divider().overlay(.white)
                
                Chart(weatherData[0...12]) { hour in
                    PointMark(x: .value("", hour.dt.formatted("dha")),
                              y: .value("", Temperature(hour.temp, selectedUnits.temperature).val))
                    .annotation {
                        Text("\(Temperature(hour.temp, selectedUnits.temperature))")
                    }
                    LineMark(x: .value("", hour.dt.formatted("dha")),
                             y: .value("", Temperature(hour.temp, selectedUnits.temperature).val))
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
                .padding()
            }
        }
        .onTapGesture(perform: {showSheet = true})
        .sheet(isPresented: $showSheet) {
            HourlyTempView(weatherData: Array(weatherData[0...24]), selectedUnits: selectedUnits)
//            HourlyConditionsView(weatherData: weatherData, isShowing: $showSheet)
//                .environment(selectedUnits)
//                .padding(.top)
        }
    }

    @ViewBuilder
    func gridIcons(_ index: Int) -> some View {
        VStack {
            getIcon(id: weatherData[index].weather[0].weatherID,
                    icon: weatherData[index].weather[0].weatherIcon)
            .symbolRenderingMode(.multicolor)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            let set = ["Rain", "Thunderstorms"]
            if set.contains(weatherData[index].weather[0].weatherMain) {
                Text("\(Precipitation(weatherData[index].pop))")
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
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
            VStack {
                if let hourly = weatherData?.hourly {
                    HourlyTileView(weatherData: hourly)
                        .foregroundStyle(.white)
                        .frame(height: 250)
                        .padding()
                        .environment(SelectedUnits())
                }
            }.task {
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

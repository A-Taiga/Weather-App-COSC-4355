//
//  HourlyChartView.swift
//  Weather
//
//  Created by Anthony Polka on 11/15/24.
//

import SwiftUI
import Charts

struct HourlyConditionsView: View {

    
//    @Environment(Units.self) var units
    @Environment(SelectedUnits.self) var selectedUnits
    private let weatherData: [Hourly]
    @State private var viewModel: ChartModel
    
    @Binding private var isShowing: Bool
    
    init(weatherData: [Hourly], isShowing: Binding<Bool>) {
        self.weatherData = weatherData
        self.viewModel = ChartModel(data: weatherData)
        self._isShowing = isShowing
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button("", systemImage: "x.circle.fill") {
                    isShowing = false
                }
                .font(.title)
                .foregroundStyle(.gray)
                .padding(.trailing)
            }
            HStack {
                VStack(alignment: .leading) {
                    
                    if let selectedDate = viewModel.selectedDate,
                       let weather = viewModel.data.first(where: {
                           $0.dt == selectedDate.nearestHour()?.timeIntervalSince1970
                       }) {
                        Text(selectedDate.timeIntervalSince1970.formatted("h:mm a"))
                        HStack {
                            Text("\(Temperature(weather.temp, selectedUnits.temperature))")
                            getIcon(id: weather.weather[0].weatherID, icon: weather.weather[0].weatherIcon)
                                .symbolRenderingMode(.multicolor)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, height: 35)
                            
                        }
                    } else {
                        
                        Text(viewModel.time.formatted(("h:mm a")))
                            .onReceive(viewModel.clockTimer) { time in
                                self.viewModel.time = Date.now.timeIntervalSince1970
                            }
                        if let weather = viewModel.data.first(where: {
                            $0.dt == Date(timeIntervalSince1970: viewModel.time).nearestHour()?.timeIntervalSince1970
                        }) {
                            HStack {
                                Text("\(Temperature(weather.temp, selectedUnits.temperature))")
                                getIcon(id: weather.weather[0].weatherID, icon: weather.weather[0].weatherIcon)
                                    .symbolRenderingMode(.multicolor)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                            }
                        }
                    }
                }
                .padding(.leading)
                .font(.title)
                
                Spacer()

                Menu {
                    Button() {viewModel.selectedChartDataType = .temp} label: {Text("Temperature")}
                    Button() {viewModel.selectedChartDataType = .feelsLike} label: {Text("Feels Like")}
                    Button() {viewModel.selectedChartDataType = .humidity} label: {Text("Hummidity")}
                    Button() {viewModel.selectedChartDataType = .pressure} label: {Text("Pressure")}
                } label: {
                    getSelectedChartImage()
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                }
                .buttonStyle(.borderedProminent)
                .foregroundStyle(.white)
            }
            .padding(.trailing)

            ZStack {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                }
                
                Chart(viewModel.data[0...24]) {
                    switch viewModel.selectedChartDataType {
                        case .temp: tempChartContent($0)
                        case .feelsLike: feelsLikeChartContent($0)
                        case .humidity: hummidtyChartContent($0)
                    case .pressure: pressureChartContent($0)
                    }
                    chartContent()
                }
                .chartYScale(domain: viewModel.yScaleDomain)
                .chartXScale(domain: Date(timeIntervalSince1970: viewModel.minTime)...Date(timeIntervalSince1970: viewModel.minTime).advanced(by: 3600*24))
                .chartYAxis {
                    chartYAxisMarks()
                }
                .chartXAxis {
                    
                    AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                        
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                            .font(.subheadline)
                     
                    }
                    
                    AxisMarks(position: .top, values: .stride(by: .hour, count: 2)) { value in
                        
                        if let v = value.as(Date.self),
                           let weather = viewModel.data.first(where: {$0.dt == v.nearestHour()?.timeIntervalSince1970})?.weather {
                            AxisValueLabel(centered: false) {
                                getIcon(id: weather[0].weatherID, icon: weather[0].weatherIcon)
                                .symbolRenderingMode(.multicolor)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            }
                        }
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if let frame = proxy.plotFrame {
                                            let x = value.location.x - geo[frame].origin.x
                                            if let date: Date =  proxy.value(atX: x),
                                               let roundedHour = date.nearestHour() {
                                                if roundedHour <= Date(timeIntervalSince1970: viewModel.data[24].dt) {
                                                    self.viewModel.selectedDate = roundedHour
                                                }
                                            }
                                        }
                                    }
                                    .onEnded { _ in self.viewModel.selectedDate = nil }
                            )
                    }
                }
                .padding()
            }
            .padding()
            .frame(height: 350)
            Spacer()
        }.onAppear() {
            viewModel.selectedUnits = selectedUnits
        }
    }
    
    @ViewBuilder
    func selectedChartDisplayInfo() -> some View {
        
    }
    
    @ChartContentBuilder
    func chartContent() -> some ChartContent {
        
        switch viewModel.selectedChartDataType {
        case .temp: tempChartPointContent()
        case .feelsLike: feelsLikeChartPointContent()
        case .humidity: humidityChartPointContent()
        case .pressure: pressureChartPointContent()
        }
        
    }
    
    @ChartContentBuilder
    func tempChartPointContent() -> some ChartContent {
        if let selectedDate = viewModel.selectedDate,
           let point = viewModel.data.first(where: {$0.dt == selectedDate.timeIntervalSince1970})?.temp {
            RuleMark(x: .value("", selectedDate)).foregroundStyle(.white)
            PointMark (
                x: .value("", selectedDate),
                y: .value("", Temperature(point, selectedUnits.temperature).val)
            ).foregroundStyle(.white)
        } else {
            if let date = Date(timeIntervalSince1970: viewModel.time).nearestHour(),
               let point = viewModel.data.first(where: {$0.dt == date.timeIntervalSince1970})?.temp {
                PointMark (
                    x: .value("", date),
                    y: .value("", Temperature(point, selectedUnits.temperature).val)
                ).foregroundStyle(.white)
            }
        }
    }
    
    @ChartContentBuilder
    func feelsLikeChartPointContent() -> some ChartContent {
        if let selectedDate = viewModel.selectedDate,
           let point = viewModel.data.first(where: {$0.dt == selectedDate.timeIntervalSince1970})?.feels_like {
            RuleMark (x: .value("", selectedDate)).foregroundStyle(.white)
            PointMark (
                x: .value("", selectedDate),
                y: .value("", Temperature(point, selectedUnits.temperature).val)
            ).foregroundStyle(.white)
        } else {
            if let date = Date(timeIntervalSince1970: viewModel.time).nearestHour(),
               let point = viewModel.data.first(where: {$0.dt == date.timeIntervalSince1970})?.feels_like {
                PointMark (
                    x: .value("", date),
                    y: .value("", Temperature(point, selectedUnits.temperature).val)
                ).foregroundStyle(.white)
            }
        }
    }
    
    @ChartContentBuilder
    func humidityChartPointContent() -> some ChartContent {
        if let selectedDate = viewModel.selectedDate,
           let point = viewModel.data.first(where: {$0.dt == selectedDate.timeIntervalSince1970})?.humidity {
            RuleMark(x: .value("", selectedDate)).foregroundStyle(.white)
            PointMark (
                x: .value("", selectedDate),
                y: .value("", point)
            ).foregroundStyle(.white)
        } else {
            if let date = Date(timeIntervalSince1970: viewModel.time).nearestHour(),
               let point = viewModel.data.first(where: {$0.dt == date.timeIntervalSince1970})?.humidity {
                PointMark (
                    x: .value("", date),
                    y: .value("", point)
                ).foregroundStyle(.white)
            }
        }
    }
    
    @ChartContentBuilder
    func pressureChartPointContent() -> some ChartContent {
        if let selectedDate = viewModel.selectedDate,
           let point = viewModel.data.first(where: {$0.dt == selectedDate.timeIntervalSince1970})?.pressure {
            RuleMark(x: .value("", selectedDate)).foregroundStyle(.white)
            PointMark (
                x: .value("", selectedDate),
                y: .value("", point)
            ).foregroundStyle(.white)
        } else {
            if let date = Date(timeIntervalSince1970: viewModel.time).nearestHour(),
               let point = viewModel.data.first(where: {$0.dt == date.timeIntervalSince1970})?.pressure {
                PointMark (
                    x: .value("", date),
                    y: .value("", point)
                ).foregroundStyle(.white)
            }
        }
    }
    
    func tempChartContent(_ data: Hourly) -> some ChartContent {
        LineMark (
            x: .value("", Date(timeIntervalSince1970: data.dt)),
            y: .value("", Temperature(data.temp, selectedUnits.temperature).val)
        )
    }
    
    func hummidtyChartContent(_ data: Hourly) -> some ChartContent {
        LineMark (
            x: .value("", Date(timeIntervalSince1970: data.dt)),
            y: .value("", data.humidity)
        )
    }
    
    func feelsLikeChartContent(_ data: Hourly) -> some ChartContent {
        LineMark (
            x: .value("", Date(timeIntervalSince1970: data.dt)),
            y: .value("", Temperature(data.feels_like, selectedUnits.temperature).val)
        )
    }
    
    func pressureChartContent(_ data: Hourly) -> some ChartContent {
        LineMark (
            x: .value("", Date(timeIntervalSince1970: data.dt)),
            y: .value("", data.pressure)
        )
    }
      
    func chartYAxisMarks() -> some AxisContent {
        AxisMarks(values: viewModel.yAxisMarks) { value in
            AxisGridLine()
            switch viewModel.selectedChartDataType {
            case .temp: tempAxisValueLabel(value)
            case .feelsLike: tempAxisValueLabel(value)
            case .humidity: AxisValueLabel(format: Decimal.FormatStyle.Percent.percent.scale(1))
            case .pressure: AxisValueLabel()
            }
        }
    }
    
    func tempAxisValueLabel(_ value: AxisValue) -> AxisValueLabel<Text>? {
    
        if let temperature = value.as(Int.self) {
            return AxisValueLabel {
                Text("\(temperature)°")
            }
        } else {
            return nil
        }
    }
    
    func getSelectedChartImage() -> Image {
        switch viewModel.selectedChartDataType {
        case .temp: Image(systemName: "thermometer.high")
        case .feelsLike: Image(systemName: "thermometer.sun.fill")
        case .humidity: Image(systemName: "humidity.fill")
        case .pressure: Image(systemName: "gauge.with.dots.needle.bottom.100percent")
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
                
                Text("\(Precipitation(weatherData[index].pop, selectedUnits.precipitation))")
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
            } else {
                Text(" ")
            }
        }
    }
}


extension Date {
    func nearestHour() -> Date? {
        var components = NSCalendar.current.dateComponents([.minute, .second, .nanosecond], from: self)
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        let nanosecond = components.nanosecond ?? 0
        components.minute = minute >= 30 ? 60 - minute : -minute
        components.second = -second
        components.nanosecond = -nanosecond
        return Calendar.current.date(byAdding: components, to: self)
    }
}

enum ChartDataType {
    case temp
    case feelsLike
    case humidity
    case pressure
}

@Observable
class ChartModel {
    
    var data: [Hourly]
    var time: TimeInterval = Date.now.timeIntervalSince1970
    var clockTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    var selectedChartDataType: ChartDataType = .temp
    var selectedDate: Date?
    var selectedUnits = SelectedUnits()
    
    
    init(data: [Hourly]) {
        self.data = data
    }
    
    var maxTemp: Temperature {
        let max = data.map{$0.temp}.max() ?? 0.0
        return Temperature(max, selectedUnits.temperature)
    }
    
    var minTemp: Temperature {
        let min = data.map{$0.temp}.min() ?? 0.0
        return Temperature(min, selectedUnits.temperature)
    }
    
    var maxFeel: Temperature {
        let maxFeel = data.map{$0.feels_like}.max() ?? 0.0
        return Temperature(maxFeel, selectedUnits.temperature)
    }
    
    var minFeel: Temperature {
        let minFeel = data.map{$0.feels_like}.min() ?? 0.0
        return Temperature(minFeel, selectedUnits.temperature)
    }
    
    var maxPressure: Double {
        data.map{$0.pressure}.max() ?? 0.0
    }
    
    var minPressure: Double {
        data.map{$0.pressure}.min() ?? 0.0
    }
    
    var maxHummidty: Double {
        data.map{$0.humidity}.max() ?? 0.0
    }
    
    var minHummidty: Double {
        data.map{$0.humidity}.min() ?? 0.0
    }
    
    var maxTime: TimeInterval {
        data.last?.dt ?? Date.now.timeIntervalSince1970
    }
    
    var minTime: TimeInterval {
        data.first?.dt ?? Date.now.timeIntervalSince1970
    }

    var yScaleDomain: ClosedRange<Double> {
        switch selectedChartDataType {
        case .temp:      return  (minTemp.val-11)...(maxTemp.val+30)
        case .feelsLike: return (minFeel.val-11)...(maxFeel.val+30)
        case .humidity:  return 0...101
        case .pressure:  return minPressure-25...maxPressure+25
        }
    }
    
    var yAxisMarks: [Double] {
        switch selectedChartDataType {
        case .temp:      return stride(from: (minTemp.val-11), to: (maxTemp.val+30), by: 8).map{$0}
        case .feelsLike: return stride(from: (minFeel.val-11), to: (maxFeel.val+30), by: 8).map{$0}
        case .humidity:  return stride(from: 0, to: 101, by: 20).map{$0}
        case .pressure:  return stride(from: minPressure-25, to: maxPressure+25, by: 15).map{$0}
            
        }
    }

}

#Preview {
    HourlyChartViewPreview(fileName: "SomePlaceDenverTime", cityName: "Some Place", adminArea: "SP")
        .environment(SelectedUnits())
}

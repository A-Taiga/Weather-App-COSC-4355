//
//  HourlyChartView.swift
//  Weather
//
//  Created by Anthony Polka on 11/15/24.
//

import SwiftUI
import Charts

struct HourlyChartView: View {

    
    @Environment(Units.self) var units
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
                            Text("\(units.handleTemp(val: weather.temp))\(units.handleUnit(UnitsTemp.self))")
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
                                Text("\(units.handleTemp(val: weather.temp))\(units.handleUnit(UnitsTemp.self))")
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
                } label: {
                    getSelectedChartImage()
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                }
                .foregroundStyle(.white)
                .padding()
                .background(.gray)
                .clipShape(Circle())
            }
            .padding(.trailing)

            ZStack {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                }
                
                Chart(viewModel.data) {
                    
                    switch viewModel.selectedChartDataType {
                        case .temp: tempChartContent($0)
                        case .feelsLike: feelsLikeChartContent($0)
                        case .humidity: hummidtyChartContent($0)
                    }
                    chartContent()
                }
                .chartYScale(domain: viewModel.yScaleDomain(self.units))
                .chartYAxis {
                    chartYAxisMarks()
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 12)) { value in
                        
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                            .font(.subheadline)
                     
                    }
                    
                    AxisMarks(position: .top, values: .stride(by: .hour, count: 1)) { value in
                        if value.index % 4 == 0 {
                            AxisValueLabel(anchor: UnitPoint.bottomLeading) {
                                getIcon(id: viewModel.data[value.index].weather.first!.weatherID,
                                        icon: viewModel.data[value.index].weather.first!.weatherIcon)
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
                                                self.viewModel.selectedDate = roundedHour
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
        }
    }
    
//    if let selectedDate = viewModel.selectedDate,
//       let weather = viewModel.data.first(where: {
//           $0.dt == selectedDate.nearestHour()?.timeIntervalSince1970
//       }) {
//        Text(selectedDate.timeIntervalSince1970.formatted("h:mm a"))
//        HStack {
//            Text("\(units.handleTemp(val: weather.temp))\(units.handleUnit(UnitsTemp.self))")
//            getIcon(id: weather.weather[0].weatherID, icon: weather.weather[0].weatherIcon)
//                .symbolRenderingMode(.multicolor)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 35, height: 35)
//            
//        }
//    } else {
//        
//        Text(viewModel.time.formatted(("h:mm a")))
//            .onReceive(viewModel.clockTimer) { time in
//                self.viewModel.time = Date.now.timeIntervalSince1970
//            }
//        if let weather = viewModel.data.first(where: {
//            $0.dt == Date(timeIntervalSince1970: viewModel.time).nearestHour()?.timeIntervalSince1970
//        }) {
//            HStack {
//                Text("\(units.handleTemp(val: weather.temp))\(units.handleUnit(UnitsTemp.self))")
//                getIcon(id: weather.weather[0].weatherID, icon: weather.weather[0].weatherIcon)
//                    .symbolRenderingMode(.multicolor)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 35, height: 35)
//            }
//        }
//    }
    
    @ViewBuilder
    func selectedChartDisplayInfo() -> some View {
        
    }
    
    @ChartContentBuilder
    func chartContent() -> some ChartContent {
        
        switch viewModel.selectedChartDataType {
        case .temp: tempChartPointContent()
        case .feelsLike: feelsLikeChartPointContent()
        case .humidity: humidityChartPointContent()
        }
        
    }
    
    @ChartContentBuilder
    func tempChartPointContent() -> some ChartContent {
        if let selectedDate = viewModel.selectedDate,
           let point = viewModel.data.first(where: {$0.dt == selectedDate.timeIntervalSince1970})?.temp {
            RuleMark(x: .value("", selectedDate)).foregroundStyle(.white)
            PointMark (
                x: .value("", selectedDate),
                y: .value("", units.handleTemp(val: point))
            ).foregroundStyle(.white)
        } else {
            if let date = Date(timeIntervalSince1970: viewModel.time).nearestHour(),
               let point = viewModel.data.first(where: {$0.dt == date.timeIntervalSince1970})?.temp {
                PointMark (
                    x: .value("", date),
                    y: .value("", units.handleTemp(val: point))
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
                y: .value("", units.handleTemp(val: point))
            ).foregroundStyle(.white)
        } else {
            if let date = Date(timeIntervalSince1970: viewModel.time).nearestHour(),
               let point = viewModel.data.first(where: {$0.dt == date.timeIntervalSince1970})?.feels_like {
                PointMark (
                    x: .value("", date),
                    y: .value("", units.handleTemp(val: point))
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
    
    func tempChartContent(_ data: Hourly) -> some ChartContent {
        LineMark (
            x: .value("", Date(timeIntervalSince1970: data.dt)),
            y: .value("", units.handleTemp(val: data.temp))
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
            y: .value("", units.handleTemp(val: data.feels_like))
        )
    }
      
    func chartYAxisMarks() -> some AxisContent {
        AxisMarks(values: viewModel.yAxisMarks(self.units)) { value in
            AxisGridLine()
            switch viewModel.selectedChartDataType {
            case .temp: tempAxisValueLabel(value)
            case .feelsLike: tempAxisValueLabel(value)
            case .humidity: AxisValueLabel(format: Decimal.FormatStyle.Percent.percent.scale(1))
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
                Text("\(units.handlePrecipitation(val: weatherData[index].pop))")
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
}

@Observable
class ChartModel {
    
    var data: [Hourly]
    var time: TimeInterval = Date.now.timeIntervalSince1970
    var clockTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    var selectedChartDataType: ChartDataType = .temp
    var selectedDate: Date?
    
    
    init(data: [Hourly]) {
        self.data = data
    }
    
    var maxTemp: Double {
        data.map{$0.temp}.max() ?? 0.0
    }
    
    var minTemp: Double {
        data.map{$0.temp}.min() ?? 0.0
    }
    
    var maxFeel: Double {
        data.map{$0.feels_like}.max() ?? 0.0
    }
    
    var minFeel: Double {
        data.map{$0.feels_like}.min() ?? 0.0
    }
    
    var maxHummidty: Double {
        data.map{$0.humidity}.max() ?? 0.0
    }
    
    var minHummidty: Double {
        data.map{$0.humidity}.min() ?? 0.0
    }
    
    var maxTime: TimeInterval {
        data.first?.dt ?? Date.now.timeIntervalSince1970
    }
    
    var minTime: TimeInterval {
        data.last?.dt ?? Date.now.timeIntervalSince1970
    }
    
    
    var xAxisMarks: [TimeInterval] {
        stride(from: minTime, to: maxTime, by: 3600).map{$0}
    }
    
    func yScaleDomain (_ units: Units) -> ClosedRange<Int> {
        switch selectedChartDataType {
        case .temp:
            return  units.handleTemp(val: minTemp-11)...units.handleTemp(val: maxTemp+30)
        case .feelsLike:
            return  units.handleTemp(val: minFeel-11)...units.handleTemp(val: maxFeel+30)
        case .humidity: return 0...101
        }
       
    }
    
    func yAxisMarks (_ units: Units) -> [Int] {
        
        switch selectedChartDataType {
            
        case .temp:
            return stride(from: units.handleTemp(val: minTemp-11),
                                  to: units.handleTemp(val: maxTemp+30), by: 8).map{$0}
        case .feelsLike:
            return stride(from: units.handleTemp(val: minFeel-11),
                          to: units.handleTemp(val: maxFeel+30), by: 8).map{$0}
            
        case .humidity:
            return stride(from: 0, to: 101, by: 20).map{$0}
            
        }
    }
}

#Preview {
    HourlyChartViewPreview(fileName: "SomePlaceDenverTime", cityName: "Some Place", adminArea: "SP")
        .environment(Units())
}

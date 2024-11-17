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
    @State private var selectedDate: Date?
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
            
            VStack(alignment: .leading) {
                
                if let selectedDate,
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

            ZStack(alignment: .top) {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                }
                
                Chart(viewModel.data) {
                    
                    LineMark (
                        x: .value("", Date(timeIntervalSince1970: $0.dt)),
                        y: .value("", units.handleTemp(val: $0.temp))
                    )
                    
                    if let selectedDate,
                        let point = viewModel.data.first(where: { $0.dt == selectedDate.timeIntervalSince1970})?.temp {
                        RuleMark(x: .value("", selectedDate))
                        let _ = print(units.handleTemp(val: point))
                        PointMark(
                            x: .value("", selectedDate),
                            y: .value("", units.handleTemp(val: point))
                        ).foregroundStyle(.red)
                    } else {
                        
                        if let date = Date(timeIntervalSince1970: viewModel.time).nearestHour(),
                           let point = viewModel.data.first(where: { $0.dt == date.timeIntervalSince1970})?.temp {
                            PointMark (
                                x: .value("", date),
                                y: .value("", units.handleTemp(val: point))
                            ).foregroundStyle(.red)
                        }
                    }
                }
                .chartYScale(domain: viewModel.yScaleDomain(self.units))
                .chartYAxis {
                    AxisMarks(values: viewModel.yAxisMarks(self.units)) { value in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .chartXAxis {
                    
                    AxisMarks(values: .stride(by: .hour, count: 12)) { value in
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                            .font(.subheadline)
                        AxisGridLine()
                        AxisTick()
                    }
                    
                    AxisMarks(position: .top, values: .stride(by: .hour, count: 4)) { value in
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
                                                self.selectedDate = roundedHour
                                            }
                                        }
                                    }
                                    .onEnded { _ in self.selectedDate = nil }
                            )
                    }
                }
                .padding()
            }
            .padding()
            .frame(height: 350)
            Spacer()
        }
        .onAppear() {
            self.viewModel.units = self.units
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

@Observable
class ChartModel {
    
    var data: [Hourly]
    var units: Units?
    var time: TimeInterval = Date.now.timeIntervalSince1970
    var clockTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    init(data: [Hourly]) {
        self.data = data
        self.units = units
    }
    
    var maxTemp: Double {
        data.map{$0.temp}.max() ?? 0.0
    }
    
    var minTemp: Double {
        data.map{$0.temp}.min() ?? 0.0
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
    
    func yAxisMarks (_ units: Units) -> [Int] {
        stride(from: units.handleTemp(val: minTemp-11),
               to: units.handleTemp(val: maxTemp+30), by: 8).map{$0}
    }
    
    func yScaleDomain (_ units: Units) -> ClosedRange<Int> {
        units.handleTemp(val: minTemp-11)...units.handleTemp(val: maxTemp+30)
    }
    
}

#Preview {
    HourlyChartViewPreview(fileName: "SomePlaceDenverTime", cityName: "Some Place", adminArea: "SP")
        .environment(Units())
}

//
//  HourlyTempView.swift
//  Weather
//
//  Created by Anthony Polka on 11/21/24.
//


import SwiftUI
import Charts


struct HourlyTempView: View {
    
    private var tempModel: TemperaturePlotModel
    private var feelsModel: FeelsLikePlotModel
    private var humidityModel: HumidityPlotModel
    private var pressureModel: PressurePlotModel
        
    @State private(set) var selectedDate: Date?
    @State private var viewModel: ChartViewModel
    
    init(weatherData: [Hourly], selectedUnits: SelectedUnits) {
        self.tempModel = TemperaturePlotModel(data: weatherData, selectedUnits: selectedUnits)
        self.feelsModel = FeelsLikePlotModel(data: weatherData, selectedUnits: selectedUnits)
        self.humidityModel = HumidityPlotModel(data: weatherData, selectedUnits: selectedUnits)
        self.pressureModel = PressurePlotModel(data: weatherData, selectedUnits: selectedUnits)
        self.viewModel = tempModel
    }
    
    var body: some View {
        
        VStack {
            HStack {
                VStack {
                    if let selectedDate {
                        Text(toTime(utc: selectedDate.timeIntervalSince1970))
                        Text(viewModel.getFormattedPoint(selectedDate))
                            .font(.title)
                    } else {
                        if let hour = Date.now.nearestHour()?.timeIntervalSince1970 {
                            Text(toTime(utc: hour))
                        }
                        Text(viewModel.getFormattedPoint(Date.now.nearestHour()))
                            .font(.title)
                    }
                }
                Spacer()
                
                Menu {
                    Button {viewModel = tempModel}label:{Text("Temperature")}
                    Button {viewModel = feelsModel}label:{Text("Feels Like")}
                    Button {viewModel = humidityModel}label:{Text("Humidity")}
                    Button {viewModel = pressureModel}label:{Text("Pressure")}
                } label: {
                    getSelectedChartImage()
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                }
                .buttonStyle(.borderedProminent)
                .tint(.gray)
                
            }
        }
        
        ZStack {
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial).stroke(.gray)
            }
            Chart(viewModel.data) {
                
                
                PointMark(
                    x: .value("", viewModel.highDate),
                    y: .value("", viewModel.maxData)
                ).symbol {
                    Image(systemName: "smallcircle.filled.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.red)
                        .frame(width: 15, height: 15)
                }
                .annotation(content: {
                    Text("H").foregroundStyle(.red)
                })
                
                PointMark(
                    x: .value("", viewModel.lowDate),
                    y: .value("", viewModel.minData)
                ).symbol {
                    Image(systemName: "smallcircle.filled.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.white)
                        .frame(width: 15, height: 15)
                }
                .annotation(content: {
                    Text("L")
                })
                
               
                
                LineMark (
                    x: .value("", Date(timeIntervalSince1970: $0.dt)),
                    y: .value("", viewModel.getDataPoint($0))
                )
                if let selectedDate,
                   let selectedPoint = viewModel.getDataPoint(selectedDate) {
                    if (selectedDate.timeIntervalSince1970 >= viewModel.minDate.timeIntervalSince1970) {
                        
                        RuleMark(x: .value("", selectedDate)).foregroundStyle(.white)
                        PointMark (
                            x: .value("", selectedDate),
                            y: .value("", selectedPoint)
                        ).foregroundStyle(.white)
                    }
                } else {
                    if let date = Date.now.nearestHour(),
                       let value = viewModel.getDataPoint(date) {
                        PointMark(
                            x: .value("", date),
                            y: .value("", value)
                        ).foregroundStyle(.white)
                    }
                }
            }
            .chartYScale(domain: viewModel.yScaleDomain)
            .chartXScale(domain: viewModel.xAxisMarks)
            .chartYAxis {
                AxisMarks(values: viewModel.yAxisMarks) { value in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel() {
                        viewModel.yAxisLabel(value)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                }
                
                AxisMarks(position: .top, values: .stride(by: .hour, count: 2)) { value in
                    AxisValueLabel {
                        viewModel.getDataIcons(value)?
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
                                            if roundedHour <= Date(timeIntervalSince1970: viewModel.data[24].dt) {
                                                self.selectedDate = roundedHour
                                            }
                                        }
                                    }
                                }.onEnded { _ in self.selectedDate = nil })
                }
            }
            .padding(5)
        }
        .frame(height: 300)
    }
    
    func getSelectedChartImage() -> Image {
        switch viewModel.self {
        case is TemperaturePlotModel: Image(systemName: "thermometer.high")
        case is FeelsLikePlotModel: Image(systemName: "thermometer.sun.fill")
        case is HumidityPlotModel: Image(systemName: "humidity.fill")
        case is PressurePlotModel: Image(systemName: "gauge.with.dots.needle.bottom.100percent")
        default: Image(systemName: "thermometer.fill")
        }
    }
}

protocol HourlyChartViewModel {
    
    associatedtype PlotType: Plottable & Comparable
    
    var data: [Hourly] {get}
    var selectedUnits: SelectedUnits {get set}
    var lowDate: Date {get}
    var highDate: Date {get}
    var minDate: Date {get}
    var maxDate: Date {get}
    var xAxisMarks: ClosedRange<Date> {get}
    var minData: PlotType {get}
    var maxData: PlotType {get}
    var yAxisMarks: [PlotType] {get}
    var yScaleDomain: ClosedRange<PlotType> {get}

    func getDataPoint(_ hour: Hourly) -> PlotType
    func getDataPoint(_ date: Date?) -> PlotType?
    func getFormattedPoint(_ date: Date?) -> String
    func yAxisLabel(_ value: AxisValue) -> Text?
    func getDataIcons(_ value: AxisValue) -> Image?
    
}

class ChartViewModel: HourlyChartViewModel {

    
    
    var data: [Hourly]
    var selectedUnits: SelectedUnits
    var lowDate: Date
    var highDate: Date
    lazy var maxDate: Date = {Date(timeIntervalSince1970: data.last?.dt ?? Date.now.timeIntervalSince1970)}()
    lazy var minDate: Date = {Date(timeIntervalSince1970: data.first?.dt ?? Date.now.timeIntervalSince1970)}()
    lazy var xAxisMarks: ClosedRange<Date> = {minDate...minDate.advanced(by: 3600*24)}()
    
    init(data: [Hourly],
        selectedUnits: SelectedUnits,
        lowDate: Date,
        highDate: Date) {
        
        self.data = data
        self.selectedUnits = selectedUnits
        self.lowDate = lowDate
        self.highDate = highDate
    }
    
    var maxData: Double {
        fatalError("")
    }

    var minData: Double {
        let min = data.map{$0.temp}.min() ?? 0.0
        return Temperature(min, selectedUnits.temperature).val
    }
    
    var yScaleDomain: ClosedRange<Double> {
        minData-11...maxData+30
    }

    var yAxisMarks: [Double] {
        stride(from: minData-11, to: maxData+30, by: 8).map{$0}
    }
    
    func yAxisLabel(_ value: AxisValue) -> Text? {
        if let v = value.as(Int.self) {
            return Text("\(v)°")
        }
        return nil
    }
    
    func getDataPoint(_ hour: Hourly) -> Double {
        return Temperature(hour.temp, selectedUnits.temperature).val
    }
    
    func getDataPoint(_ date: Date?) -> Double? {
        guard let date,
              let point = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.temp
        else {return nil}
        return Temperature(point, selectedUnits.temperature).val
    }
    
    func getFormattedPoint(_ date: Date?) -> String {
        guard let date,
              let point = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.temp
        else {return ""}
        return "\(Temperature(point, selectedUnits.temperature))"
    }
    
    func getDataIcons(_ value: AxisValue) -> Image? {
        if let date = value.as(Date.self),
           let weather = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.weather.first {
            return getIcon(id: weather.weatherID, icon: weather.weatherIcon)
        }
        return nil
    }
}

class TemperaturePlotModel: ChartViewModel {

    
    init(data: [Hourly], selectedUnits: SelectedUnits) {
        
        var lowDate = Date()
        var highDate = Date()
        
        if let result = data.first(where: {$0.temp == data.map{$0.temp}.min()})?.dt {
            lowDate = Date(timeIntervalSince1970: result)
        }
        
        if let result = data.first(where: {$0.temp == data.map{$0.temp}.max()})?.dt {
            highDate = Date(timeIntervalSince1970: result)
        }
        
        super.init(data: data,
                   selectedUnits: selectedUnits,
                   lowDate:lowDate,
                   highDate: highDate)
        self.data = data
        self.selectedUnits = selectedUnits
    }
    
    lazy var _maxData: Double = {
        let max = data.map{$0.temp}.max() ?? 0.0
        return Temperature(max, selectedUnits.temperature).val
    }()
    
    lazy var _minData: Double = {
        let min = data.map{$0.temp}.min() ?? 0.0
        return Temperature(min, selectedUnits.temperature).val
    }()
    
    lazy var _yScaleDomain: ClosedRange<Double> = {
        minData-11...maxData+30
    }()

    lazy var _yAxisMarks: [Double] = {
        stride(from: minData-11, to: maxData+30, by: 8).map{$0}
    }()
    
    
    override var maxData: Double {
        get {_maxData}
    }
    
    override var minData: Double {
        get {_minData}
    }
    
    override var yScaleDomain: ClosedRange<Double> {
        get {_yScaleDomain}
    }

    override var yAxisMarks: [Double] {
        get {_yAxisMarks}
    }
    
    
    override func getDataPoint(_ hour: Hourly) -> Double {
        return Temperature(hour.temp, selectedUnits.temperature).val
    }
    
    override func getDataPoint(_ date: Date?) -> Double? {
        guard let date,
              let point = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.temp
        else {return nil}
        return Temperature(point, selectedUnits.temperature).val
    }
    
    override func getDataIcons(_ value: AxisValue) -> Image? {
        if let date = value.as(Date.self),
           let weather = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.weather.first {
            return getIcon(id: weather.weatherID, icon: weather.weatherIcon)
        }
        return nil
    }
    
}


class FeelsLikePlotModel: ChartViewModel {
    
    init(data: [Hourly], selectedUnits: SelectedUnits) {
        var lowDate = Date()
        var highDate = Date()
        
        if let result = data.first(where: {$0.feels_like == data.map{$0.feels_like}.min()})?.dt {
            lowDate = Date(timeIntervalSince1970: result)
        }
        
        if let result = data.first(where: {$0.feels_like == data.map{$0.feels_like}.max()})?.dt {
            highDate = Date(timeIntervalSince1970: result)
        }
        
        super.init(data: data,
                   selectedUnits: selectedUnits,
                   lowDate:lowDate,
                   highDate: highDate)
        self.data = data
        self.selectedUnits = selectedUnits
    }

    lazy var _maxData: Double = {
        let max = data.map{$0.feels_like}.max() ?? 0.0
        return Temperature(max, selectedUnits.temperature).val
    }()
    
    lazy var _minData: Double = {
        let min = data.map{$0.feels_like}.min() ?? 0.0
        return Temperature(min, selectedUnits.temperature).val
    }()
    
    lazy var _yScaleDomain: ClosedRange<Double> = {
        minData-11...maxData+30
    }()

    lazy var _yAxisMarks: [Double] = {
        stride(from: minData-11, to: maxData+30, by: 8).map{$0}
    }()
    
    override var maxData: Double {
        get {_maxData}
    }
    
    override var minData: Double {
        get {_minData}
    }
    
    override var yScaleDomain: ClosedRange<Double> {
        get {_yScaleDomain}
    }

    override var yAxisMarks: [Double] {
        get {_yAxisMarks}
    }
    
    
    
    override func yAxisLabel(_ value: AxisValue) -> Text? {
        if let v = value.as(Int.self) {
            return Text("\(v)°")
        }
        return nil
    }
    
    override func getDataPoint(_ hour: Hourly) -> Double {
        return Temperature(hour.feels_like, selectedUnits.temperature).val
    }
    
    override func getDataPoint(_ date: Date?) -> Double? {
        guard let date,
              let point = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.feels_like
        else {return nil}
        return Temperature(point, selectedUnits.temperature).val
    }
    
    override func getFormattedPoint(_ date: Date?) -> String {
        guard let date,
              let point = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.feels_like
        else {return ""}
        return "\(Temperature(point, selectedUnits.temperature))"
    }
    
    override func getDataIcons(_ value: AxisValue) -> Image? {
        if let date = value.as(Date.self),
           let weather = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.weather.first {
            return getIcon(id: weather.weatherID, icon: weather.weatherIcon)
        }
        return nil
    }
}



class HumidityPlotModel: ChartViewModel {
    
    init(data: [Hourly], selectedUnits: SelectedUnits) {
        var lowDate = Date()
        var highDate = Date()
        
        if let result = data.first(where: {$0.humidity == data.map{$0.humidity}.min()})?.dt {
            lowDate = Date(timeIntervalSince1970: result)
        }
        
        if let result = data.first(where: {$0.humidity == data.map{$0.humidity}.max()})?.dt {
            highDate = Date(timeIntervalSince1970: result)
        }
        
        super.init(data: data,
                   selectedUnits: selectedUnits,
                   lowDate:lowDate,
                   highDate: highDate)
        self.data = data
        self.selectedUnits = selectedUnits
    }

    lazy var _maxData: Double = {
        let max = data.map{$0.humidity}.max() ?? 0.0
        return max
    }()
    
    lazy var _minData: Double = {
        let min = data.map{$0.humidity}.min() ?? 0.0
        return min
    }()
    
    lazy var _yScaleDomain: ClosedRange<Double> = {
        minData-11...maxData+30
    }()

    lazy var _yAxisMarks: [Double] = {
        stride(from: minData-11, to: maxData+30, by: 8).map{$0}
    }()
    
    override var maxData: Double {
        get {_maxData}
    }
    
    override var minData: Double {
        get {_minData}
    }
    
    override var yScaleDomain: ClosedRange<Double> {
        get {_yScaleDomain}
    }

    override var yAxisMarks: [Double] {
        get {_yAxisMarks}
    }
    
    override func yAxisLabel(_ value: AxisValue) -> Text? {
        if let v = value.as(Int.self) {
            return Text("\(v)%")
        }
        return nil
    }
    
    override func getDataPoint(_ hour: Hourly) -> Double {
        return hour.humidity
    }
    
    override func getDataPoint(_ date: Date?) -> Double? {
        guard let date,
              let point = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.humidity
        else {return nil}
        return point
    }
    
    override func getFormattedPoint(_ date: Date?) -> String {
        guard let date,
              let point = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.humidity
        else {return ""}
        return "\(Int(point))%"
    }
    
    override func getDataIcons(_ value: AxisValue) -> Image? {
        if let date = value.as(Date.self),
           let weather = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.weather.first {
            return getIcon(id: weather.weatherID, icon: weather.weatherIcon)
        }
        return nil
    }
}


class PressurePlotModel: ChartViewModel {
    
    init(data: [Hourly], selectedUnits: SelectedUnits) {
        var lowDate = Date()
        var highDate = Date()
        
        if let result = data.first(where: {$0.pressure == data.map{$0.pressure}.min()})?.dt {
            lowDate = Date(timeIntervalSince1970: result)
        }
        
        if let result = data.first(where: {$0.pressure == data.map{$0.pressure}.max()})?.dt {
            highDate = Date(timeIntervalSince1970: result)
        }
        
        super.init(data: data,
                   selectedUnits: selectedUnits,
                   lowDate: lowDate,
                   highDate: highDate)
        self.data = data
        self.selectedUnits = selectedUnits
    }

    lazy var _maxData: Double = {
        let max = data.map{$0.pressure}.max() ?? 0.0
        return max
    }()
    
    lazy var _minData: Double = {
        let min = data.map{$0.pressure}.min() ?? 0.0
        return min
    }()
    
    lazy var _yScaleDomain: ClosedRange<Double> = {
        minData-11...maxData+30
    }()

    lazy var _yAxisMarks: [Double] = {
        stride(from: minData-11, to: maxData+30, by: 8).map{$0}
    }()
    
    override var maxData: Double {
        get {_maxData}
    }
    
    override var minData: Double {
        get {_minData}
    }
    
    override var yScaleDomain: ClosedRange<Double> {
        get {_yScaleDomain}
    }

    override var yAxisMarks: [Double] {
        get {_yAxisMarks}
    }
    
    override func yAxisLabel(_ value: AxisValue) -> Text? {
        if let v = value.as(Int.self) {
            return Text("\(v)")
        }
        return nil
    }
    
    override func getDataPoint(_ hour: Hourly) -> Double {
        return hour.pressure
    }
    
    override func getDataPoint(_ date: Date?) -> Double? {
        guard let date,
              let point = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.pressure
        else {return nil}
        return point
    }
    
    override func getFormattedPoint(_ date: Date?) -> String {
        guard let date,
              let point = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.pressure
        else {return ""}
        return "\(Int(point))"
    }
    
    override func getDataIcons(_ value: AxisValue) -> Image? {
        if let date = value.as(Date.self),
           let weather = self.data.first(where: {$0.dt == date.timeIntervalSince1970})?.weather.first {
            return getIcon(id: weather.weatherID, icon: weather.weatherIcon)
        }
        return nil
    }
    
}

#Preview {
    HoulryTempViewPreview(fileName: "SomePlaceDenverTime", cityName: "New York", adminArea: "NY")
}



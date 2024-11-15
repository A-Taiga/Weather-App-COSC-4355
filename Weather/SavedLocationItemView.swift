//
//  SavedLocationItemView.swift
//  Weather
//
//  Created by Anthony Polka on 11/12/24.
//

import SwiftUI
import SwiftData
import CoreLocation

struct SavedLocationItemView: View {
    
    @Environment(Units.self) private var units
    @Environment(\.modelContext) var modelContext
    @Query(sort: \DataModel.listIndex) var savedData: [DataModel]
    @State private var viewModel = WeatherViewModel()
    
    init(for uuid: UUID) {
        self.viewModel.id = uuid
    }
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Image(viewModel.locationStyle.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .ignoresSafeArea()
            .overlay(.ultraThinMaterial)
            
            HStack {
                VStack(alignment: .leading) {
                    if let locality = viewModel.getLocation() {
                        HStack {
                            Text(locality.locality).font(.title)
                            
                            if viewModel.isUserLocation {
                                Image(systemName: "location.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                            }
                        }
                    }
                    Text(viewModel.computeTime())
                    
                    if !viewModel.alerts.isEmpty {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                
                viewModel.icon
                    .symbolRenderingMode(.multicolor)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 50)
                
                VStack {
                    Text(viewModel.getTemp(units))
                        .font(.title)
                    HStack {
                        Text("L: " + viewModel.getLow(units))
                        Text("H: "+viewModel.getHigh(units))
                    }.font(.subheadline)
                }.padding(.trailing)
            }
            .minimumScaleFactor(0.1)
        }
        .onAppear {
            viewModel.data = savedData.first(where: {$0.id == self.viewModel.id})
            if let weather = viewModel.data?.weatherData.current.weather.first {
                viewModel.locationStyle.setStyle(from: weather)
            }
        }
        .overlay {
            NavigationLink(destination: WeatherView(for: viewModel).environment(units)) {
                    Rectangle().fill(.clear)
                }
                .navigationBarBackButtonHidden(true)
                .opacity(0)
            }
    }
    
    
}
//
//    .overlay {
//        NavigationLink(destination: WeatherView(name: dataModel.location.locality,
//                                                weatherData: dataModel.weatherData,
//                                                isUserLocation: dataModel.isUserLocation)
//            .environment(units)
//            .environment(style)) {
//                Rectangle().fill(.clear)
//            }
//            .navigationBarBackButtonHidden(true)
//            .opacity(0)
//        }

@Observable
class WeatherViewModel {
    
    var id: UUID = UUID()
    var data: DataModel? = nil
    var time: TimeInterval = Date.now.timeIntervalSince1970
    var locationStyle = LocationStyle()
    
    
    var weatherData: WeatherData? {
        return data?.weatherData
    }
    
    var hourly: [Hourly] {
        guard let hourly = weatherData?.hourly else {return []}
        return hourly
    }
    
    var daily: [Daily] {
        guard let daily = weatherData?.daily else {return []}
        return daily
    }

    var isUserLocation: Bool {
        guard let val = data?.isUserLocation else {return false}
        return val
    }
    
    var name: String {
        guard let name = data?.location.locality else {return "--"}
        return name
    }
    
    var currentConditions: String {
        guard let condition = data?.weatherData.current.weather.first?.weatherDescription else {return ""}
        return condition.capitalized
    }
    
    var alerts: [Alert] {
        guard let alerts = data?.weatherData.alerts else {return []}
        return alerts
    }
    
    var icon: Image {
        guard let weather = self.getCurrent()?.weather.first else {return Image(systemName: "")}
        return getIcon(id: weather.weatherID, icon: weather.weatherIcon)
    }
    
    func getCurrent() -> Current? {
        return data?.weatherData.current
    }
    
    func getLocation() -> LocationModel? {
        return data?.location
    }
    
    func getTemp(_ units: Units) -> String {
        guard let temp = data?.weatherData.current.temp else {return "--"}
        return "\(units.handleTemp(val: temp)) \(units.handleUnit(UnitsTemp.self))"
    }
    
    func getHigh(_ units: Units) -> String {
        guard let temp = data?.weatherData.daily.first?.temp.max else {return "--"}
        return "\(units.handleTemp(val: temp))"
    }
    
    func getLow(_ units: Units) -> String {
        guard let temp = data?.weatherData.daily.first?.temp.min else {return "--"}
        return "\(units.handleTemp(val: temp))"
    }
    
    func computeTime() -> String {
        guard let timeZone = data?.weatherData.timezone else {return "--:--"}
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
}

@Observable
class LocationStyle {
    
    var fontColor: Color = .white
    var backgroundImage = String()
    
    func setStyle(from weather: Weather) {
        if (weather.weatherIcon.last == "d") {
            self.setBackgroundImageDay(from: weather.weatherMain)
        } else {
            self.setBackgroundImageNight(from: weather.weatherMain)
        }
    }
    

    private func setBackgroundImageDay(from icon: String) {
        switch (icon) {
        case "Clear":       backgroundImage = "clearDay"
        case "Rain":        backgroundImage = "stormDay"
        case "Drizze":      backgroundImage = "stormDay"
        case "Clouds":      backgroundImage = "partlyCloudyDay"
        case "Snow":        backgroundImage = "partlyCloudyDay"
        default:            backgroundImage = "clearDay"
        }
    }
    
    private func setBackgroundImageNight(from icon: String) {
        switch (icon) {
        case "Clear":       backgroundImage = "clearDay"
        case "Rain":        backgroundImage = "stormNight"
        case "Drizze":      backgroundImage = "stormNight"
        case "Clouds":      backgroundImage = "cloudyNight"
        case "Snow":        backgroundImage = "cloudyNight"
        default:            backgroundImage = "clearNight"
        }
    }
}

#Preview {
    SavedLocationViewPreview(fileName: "NewYorkCity", cityName: "New York City", adminArea: "NY")
        .modelContainer(for: DataModel.self, inMemory: true)
}

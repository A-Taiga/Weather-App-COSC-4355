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
    @Environment(TimeModel.self) private var timeModel
    @Environment(SelectedUnits.self) private var selectedUnits
    @Environment(\.modelContext) var modelContext
    @Query(sort: \DataModel.listIndex) var savedData: [DataModel]
    @State private var viewModel = WeatherViewModel()
    @State private var isActive = false
    
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
                    if let timeZone = viewModel.weatherData?.timezone {
                        Text(timeModel.computeTime(from: timeZone))
                    }
                    
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
                    Text("\(viewModel.currentTemp)")
                        .font(.title)
                    HStack {
                        Text("H: " + "\(Int(viewModel.currentMax.val))")
                        Text("L: " + "\(Int(viewModel.currentMin.val))")
                    }.font(.subheadline)
                }.padding(.trailing)
            }
            .minimumScaleFactor(0.1)
        }
        .onAppear {
            viewModel.selectedUnits = self.selectedUnits
            viewModel.data = savedData.first(where: {$0.id == self.viewModel.id})
            if let current = viewModel.data?.weatherData.current,
               let weather = current.weather.first {
                viewModel.locationStyle.setStyle(sunset: current.sunset, sunrise: current.sunrise, weather: weather)
            }
        }
        .onTapGesture {isActive = true}
        .navigationDestination(isPresented: $isActive) {
            WeatherView(for: viewModel).environment(selectedUnits)
                .navigationBarBackButtonHidden(true)
        }
    }
}


@Observable
class LocationStyle {
    
    var fontColor: Color = .white
    var backgroundImage = String()
    
    func setStyle(sunset: TimeInterval, sunrise: TimeInterval, weather: Weather) {
        let currentTime = Date.now.timeIntervalSince1970
        if(currentTime > sunset || currentTime < sunrise) {
            self.setBackgroundImageNight(from: weather.weatherMain)
        } else {
            self.setBackgroundImageDay(from: weather.weatherMain)
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

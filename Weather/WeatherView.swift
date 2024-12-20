//
//  WeatherView2.swift
//  Weather
//
//  Created by Anthony Polka on 11/12/24.
//

import SwiftUI
import CoreLocation

struct WeatherView: View {
    
    @Environment(SelectedUnits.self) private var selectedUnits
    var viewModel = WeatherViewModel()
    @State private var didExit = false
    private var isSheet = false
    
    init(for viewModel: WeatherViewModel) {
        self.viewModel = viewModel
    }
    
    init(for dataModel: DataModel) {
        self.viewModel = WeatherViewModel()
        self.viewModel.data = dataModel
        self.isSheet = true
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
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    Header()
                    if !viewModel.alerts.isEmpty {
                        AlertTileView(alerts: viewModel.alerts)
                            .padding()
                    }

                    if !viewModel.hourly.isEmpty {
                        HourlyTileView(weatherData: viewModel.hourly)
                            .environment(selectedUnits)
                            .frame(height: 250)
                            .padding()
                    }
                    
                    if !viewModel.daily.isEmpty {
                        DailyTileView(daily: viewModel.daily)
                    }
                    
                    WindTileView(windSpeed: viewModel.getCurrent()?.wind_speed ?? 0.0,
                                 windDirection: viewModel.getCurrent()?.wind_deg ?? 0.0,
                                 windGust: viewModel.getCurrent()?.wind_gust ?? 0.0)
                    .padding()
                    
                    MoonPhaseTileView()
                        .padding()
                    if isSheet {Spacer(minLength: 100)}
                }
            }.offset(y: isSheet ? 100 : 0)
        }
    }
    
    @ViewBuilder
    func Header() -> some View {
        VStack {
            
            Text(viewModel.name)
                .font(.system(size: 40))
            
            Text("\(viewModel.currentTemp)")
                .font(.system(size: 40))
            
            HStack {
                Text("H: " + "\(Int(viewModel.currentMax.val))")
                Text("L: " + "\(Int(viewModel.currentMin.val))")
            }.font(.title)
            
            Text(viewModel.currentConditions)
                .font(.title)
            
            if viewModel.isUserLocation {
                HStack {
                    Image(systemName: "location.circle.fill")
                        .symbolRenderingMode(.multicolor)
                        .aspectRatio(contentMode: .fit)
                    Text("My location")
                }
            }
        }
    }
}

#Preview {
    WeatherViewPreview(fileName: "NewYorkCity", cityName: "New York", adminArea: "NY")
}

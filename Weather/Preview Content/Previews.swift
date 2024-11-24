//
//  Previews.swift
//  Weather
//
//  Created by Anthony Polka on 11/15/24.
//

import Foundation
import SwiftUI
import SwiftData



protocol Previewable {
    var fileName: String {get}
    var cityName: String {get}
    var adminArea: String {get}
    init(fileName: String, cityName: String, adminArea: String)
}


struct WeatherViewPreview: View, Previewable {
    
    @State var weatherViewModel = WeatherViewModel()
    
    var fileName: String
    var cityName: String
    var adminArea: String
    
    init(fileName: String, cityName: String, adminArea: String) {
        self.fileName = fileName
        self.cityName = cityName
        self.adminArea = adminArea
    }
    
    var body: some View {
        VStack {
            WeatherView(for: weatherViewModel)
                .environment(SelectedUnits())
                .onAppear {
                    if let data = createDumyModel(fileName: self.fileName,
                                                  locationName: self.cityName,
                                                  adminArea: "OR") {
                        self.weatherViewModel.data = data
                        if let current = self.weatherViewModel.data?.weatherData.current,
                           let weather = current.weather.first {
                            self.weatherViewModel.locationStyle.setStyle(sunset: current.sunset, sunrise: current.sunrise, weather: weather)
                        }
                    }
                }
        }
    }
}

struct LocationListViewPreview: View, Previewable {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \DataModel.listIndex) var savedData: [DataModel]
    
    var fileName: String
    var cityName: String
    var adminArea: String
    
    init(fileName: String, cityName: String, adminArea: String) {
        self.fileName = fileName
        self.cityName = cityName
        self.adminArea = adminArea
    }
    
    
    var body: some View {
        LocationListView().modelContext(modelContext)
            .environment(SelectedUnits())
            .environment(TimeModel())
            .onAppear {
                if let data = createDumyModel(fileName: self.fileName, locationName: self.cityName, adminArea: self.adminArea) {
                    modelContext.insert(data)
                }
            }
    }
}


struct SavedLocationViewPreview: View, Previewable {
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \DataModel.listIndex) var savedData: [DataModel]
    
    var fileName: String
    var cityName: String
    var adminArea: String
    
    init(fileName: String, cityName: String, adminArea: String) {
        self.fileName = fileName
        self.cityName = cityName
        self.adminArea = adminArea
    }
    
    var body: some View {
        NavigationStack {
            if let id = savedData.first?.id {
                SavedLocationItemView(for: id)
                    .environment(SelectedUnits())
                    .environment(TimeModel())
                    .modelContext(modelContext)
                    .frame(height: 100)
                    .padding()
            }
        } .onAppear {
            if let data = createDumyModel(fileName: self.fileName, locationName: self.cityName, adminArea: self.adminArea) {
                self.modelContext.insert(data)
            }
        }
    }
}

struct HourlyChartViewPreview: View, Previewable {
    
    @State var hourlyData: [Hourly]?
    
    var fileName: String
    var cityName: String
    var adminArea: String
    
    init(fileName: String, cityName: String, adminArea: String) {
        self.fileName = fileName
        self.cityName = cityName
        self.adminArea = adminArea
    }
    
    var body: some View {
        VStack {
            if let hourlyData {
                HourlyConditionsView(weatherData: hourlyData, isShowing: .constant(true))
            }
        }.onAppear {
            if let data = createDumyModel(fileName: self.fileName, locationName: self.cityName, adminArea: self.adminArea) {
                self.hourlyData = data.weatherData.hourly
            }
        }
    }
}



struct HoulryTempViewPreview: View, Previewable {
    
    @State var hourlyData: [Hourly]?
    
    var fileName: String
    var cityName: String
    var adminArea: String
    
    init(fileName: String, cityName: String, adminArea: String) {
        self.fileName = fileName
        self.cityName = cityName
        self.adminArea = adminArea
    }
    
    var body: some View {
        VStack {
            if let hourlyData {
                HourlyTempView(weatherData: Array(hourlyData[0...24]), selectedUnits: SelectedUnits())
//                HourlyTempView(viewModel: TemperaturePlotModel(data: Array(hourlyData[0...24]), selectedUnits: SelectedUnits()))
//                HourlyTempView(viewModel: HummidityPlotModel(data: hourlyData, selectedUnits: SelectedUnits()))
//                HourlyTempView(viewModel: PressurePlotModel(data: hourlyData, selectedUnits: SelectedUnits()))
            }
        }.onAppear {
            if let data = createDumyModel(fileName: self.fileName, locationName: self.cityName, adminArea: self.adminArea) {
                self.hourlyData = data.weatherData.hourly
            }
        }
    }
}


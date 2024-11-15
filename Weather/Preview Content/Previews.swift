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
    
    @State var units = Units()
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
                .environment(units)
                .onAppear {
                    if let data = createDumyModel(fileName: self.fileName,
                                                  locationName: self.cityName,
                                                  adminArea: "OR") {
                        self.weatherViewModel.data = data
                        if let weatherStyle = self.weatherViewModel.data?.weatherData.current.weather.first {
                            self.weatherViewModel.locationStyle.setStyle(from: weatherStyle)
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
            .environment(Units())
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
                SavedLocationItemView(for: id).environment(Units())
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


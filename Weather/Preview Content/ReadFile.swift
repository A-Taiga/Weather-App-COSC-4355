//
//  ReadFile.swift
//  Weather
//
//  Created by Anthony Polka on 11/15/24.
//

import Foundation
import struct CoreLocation.CLLocationCoordinate2D

func readJson(from fileName: String) -> WeatherData? {
    do {
        return try readUserFromBundle(fileName: fileName)
    } catch {
        print(error)
        return nil
    }
}

//
//    .onAppear {
//        if let weather = try? readUserFromBundle(fileName: "GoldHillOR") {
//            let coords = CLLocationCoordinate2D(latitude: weather.lat, longitude: weather.lon)
//            let local = LocationModel(locality: "Gold Hill",
//                                     administrativeArea: "OR",
//                                     subAdministrativeArea: "",
//                                     coordinates: coords)
//            self.model.data = DataModel(location: local, weatherData: weather, listIndex: 0)
//            self.model.data?.isUserLocation = true
//            if let weatherStyle = self.model.data?.weatherData.current.weather.first {
//                self.model.locationStyle.setStyle(from: weatherStyle)
//            }
//        }
//    }


func createDumyModel(fileName: String, locationName: String, adminArea: String, subAdmin: String? = nil) -> DataModel? {
    guard let weather = readJson(from: fileName) else {return nil}
    let coords = CLLocationCoordinate2D(latitude: weather.lat, longitude: weather.lon)
    let local = LocationModel(locality: locationName,
                              administrativeArea: adminArea,
                              subAdministrativeArea: subAdmin ?? "",
                              coordinates: coords)
    let model = DataModel(location: local, weatherData: weather, listIndex: 0)
    model.isUserLocation = true
    return model
}

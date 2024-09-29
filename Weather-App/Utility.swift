//
//  Utility.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import Foundation
import CoreLocation

func readJSONFile<T: Decodable>(with url: URL) throws -> T {
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(T.self, from: data)
}

func readUserFromBundle(fileName: String)  -> WeatherData? {
    guard let url = Bundle.main.url(forResource:  fileName, withExtension: "json") else {
        print("ERROR")
        return nil
    }
    return try? readJSONFile(with: url)
}

func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
    CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
}

func fetchData (lat: Double, lon: Double, completion: @escaping(_ data: WeatherData?)  -> () ) async {
    do {
//        let env = ProcessInfo.processInfo.environment
        let url = URL(string: "https://api.pirateweather.net/forecast/KR77TVkdd6jUJnglzGQTeT84WOP07CsN/\(lat),\(lon)?version=2")
        let (data, _) = try await URLSession.shared.data (from: url!)
        completion(try JSONDecoder().decode(WeatherData.self, from: data))
    } catch {
        print (error)
    }
}

func unixToTime(_ time: Int32, format: String, timeZone: String? = nil) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(time))
    let dateFormatter = DateFormatter()
    if let zone = timeZone {
        dateFormatter.timeZone = TimeZone(identifier: zone)
    }
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
}


func setFont(icon: String, style: inout Style) {
    switch (icon) {
    case "clear-day":           style.fontColor = .black
    case "clear-night":         style.fontColor = .white
    case "rain":                style.fontColor = .white
    case "cloudy":              style.fontColor = .black
    case "partly-cloudy-day":   style.fontColor = .black
//            case "partly-cloudy-night":
//            case "snow":
//            case "sleet":
//            case "wind":
//            case "fog":
    default:                  style.fontColor = .red
    }
}

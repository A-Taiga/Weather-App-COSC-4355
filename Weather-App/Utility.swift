//
//  Utility.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import Foundation


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

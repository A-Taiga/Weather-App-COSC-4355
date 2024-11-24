//
//  ReadDummyData.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import Foundation


func readJSONFile<T: Decodable>(with url: URL) throws -> T {
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(T.self, from: data)
}

func readUserFromBundle(fileName: String)  throws -> WeatherData? {
    guard let url = Bundle.main.url(forResource:  fileName, withExtension: "json") else {
        print("ERROR READING FILE")
        return nil
    }
    return try readJSONFile(with: url)
}

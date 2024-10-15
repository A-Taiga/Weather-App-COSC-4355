//
//  Item.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

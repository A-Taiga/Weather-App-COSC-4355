//
//  SearchUtility.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import Foundation
import MapKit
import SwiftUI
import CoreLocation

class Search: NSObject, ObservableObject {
    
    @Published private(set) var results: Array<AddressResult> = []
    @Published var text = "" {
        didSet {
            searchAddress(text)
            if text.isEmpty {
                results = []
            }
        }
    }
    
    private lazy var localSearchCompleter: MKLocalSearchCompleter = {
        let comp = MKLocalSearchCompleter()
        comp.delegate = self
        return comp
    }()
    
    func searchAddress(_ searchableText: String) {
        guard searchableText.isEmpty == false else { return }
        localSearchCompleter.queryFragment = searchableText
        localSearchCompleter.resultTypes = .address
    }
}

extension Search: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
    
            results = completer.results.map {
                AddressResult(title: $0.title, subtitle: $0.subtitle)
            }
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
}

struct AddressResult: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    var latitude: Double?
    var longitude: Double?
    
    init(title: String, subtitle: String, latitude: Double? = nil, longitude: Double? = nil)  {
        self.title = title
        self.subtitle = subtitle
    }
}


//
//extension Search: MKLocalSearchCompleterDelegate {
//
//    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//        Task { @MainActor in
//            results = completer.results.map {
//                AddressResult(title: $0.title, subtitle: $0.subtitle)
//            }
//        }
//    }
//
//    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
//        print(error)
//    }
//}
//
//
//
//class Search: NSObject, ObservableObject {
//    @Published private(set) var results: Array<AddressResult> = []
//    @Published var searchableText = "" {
//        didSet {
//            searchAddress(searchableText)
//            if searchableText.isEmpty {
//                results = []
//            }
//        }
//    }
//   
//    
//    private lazy var localSearchCompleter: MKLocalSearchCompleter = {
//        let completer = MKLocalSearchCompleter()
//        completer.delegate = self
//        return completer
//    }()
//    
//    func searchAddress(_ searchableText: String) {
//        guard searchableText.isEmpty == false else { return }
//        localSearchCompleter.queryFragment = searchableText
//        localSearchCompleter.resultTypes = .address
//
//    }
//}
//


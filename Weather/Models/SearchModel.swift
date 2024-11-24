//
//  SearchModel.swift
//  Weather
//
//  Created by Anthony Polka on 11/24/24.
//

import Foundation
import MapKit

// MARK: Location search function
class Search: NSObject, ObservableObject {
    
    @Published private(set) var results: Array<SearchResult> = []
    @Published var text = "" {
        didSet {
            searchAddress(text)
            if text.isEmpty {results = []}
        }
    }
    
    private lazy var localSearchCompleter: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        return completer
        
    }()
    
    private func searchAddress(_ text: String) {
        guard text.isEmpty == false else {return}
        localSearchCompleter.queryFragment = text
        localSearchCompleter.resultTypes = .address
    }
}

extension Search: MKLocalSearchCompleterDelegate {
    
    struct SearchResult: Identifiable {
        let id = UUID()
        let title: String
        let subTitle: String
        init(title: String, subTitle: String) {
            self.title = title
            self.subTitle = subTitle
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            results = completer.results.map {
                SearchResult(title: $0.title, subTitle: $0.subtitle)
            }
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        print(error)
    }
}

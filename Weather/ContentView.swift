//
//  ContentView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
    @State private var units = Units()
    @State var model = Model()
    @Environment(\.modelContext) private var modelContext
    @Query private var savedData: [DataModel]
    
    var body: some View {
        NavigationStack {
            Spacer()
            List {
                
            }
            .overlay {listOverlay}
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $model.search.text, isPresented: $model.searchFocused, placement: .navigationBarDrawer(displayMode: .always))
        }
        .preferredColorScheme(.dark)
        .onChange(of: model.searchFocused, {model.searchFocusedHandler()})
        .onChange(of: model.selectionTitle) {Task {await model.getLocationInfo()}}
        .sheet(isPresented: $model.showSelection, onDismiss: {model.dismissSheet()}) {weatherSheet}
    }
    
    var listOverlay: some View {
        VStack {
            Spacer()
            List(model.search.results, id: \.id) { result in
                Button{
                    model.selectionTitle = result.title
                    model.showSelection = true
                } label: {
                    VStack(alignment: .leading) {
                        Text(result.title)
                            .fontWeight(.heavy)
                        Text(result.subTitle)
                            .fontWeight(.light)
                    }
                    .foregroundStyle(.white)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(.ultraThinMaterial)
            .opacity(model.searchListOpacity)
        }
    }
    
    var weatherSheet: some View {
        VStack {
            if let location = model.selectedResult {
                ZStack {
                    GeometryReader { _ in
                        if let data = self.model.selectedWeatherData {
                            WeatherView(name: location.locality, weatherData: data)
                                .environment(Style())
                                .environment(units)
                        }
                        HStack {
                            Button("Cancel") {
                                model.showSelection = false
                            }
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button("Add") {
                                model.showSelection = false
                            }
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
                .task {
                    await model.getLocationInfo()
                    await fetchData(lat: location.location.latitude, lon: location.location.longitude) {
                        self.model.selectedWeatherData = $0
                    }
                }
            }
        }
    }
}

extension ContentView {
    @Observable
    class Model {
        var search = Search()
        var selectionTitle: String?
        var selectedResult: LocationInfo?
        var selectedWeatherData: WeatherData?
        var showSelection = false
        var searchFocused = false
        var searchListOpacity = 0.0
        
        func dismissSheet() {
            selectionTitle = nil
            selectedResult = nil
            selectedWeatherData = nil
        }
        
        func searchFocusedHandler() {
            withAnimation(.easeInOut(duration: 0.3)) {
                searchListOpacity = searchListOpacity == 0.0 ? 1.0 : 0.0
            }
        }
        
        func getLocationInfo() async {
            guard let selectionTitle else {return}
            getCoords(from: selectionTitle) {
                self.selectedResult = LocationInfo(locality: $0, administrativeArea: $1, subAdministrativeArea: $2, location: $3)
            }
        }
    }
}

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

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    init(title: String, subTitle: String) {
        self.title = title
        self.subTitle = subTitle
    }
}

struct LocationInfo {
    let locality: String
    let administrativeArea: String
    let subAdministrativeArea: String
    let location: CLLocationCoordinate2D
    
    init(locality: String, administrativeArea: String, subAdministrativeArea: String, location: CLLocationCoordinate2D) {
        self.locality = locality
        self.administrativeArea = administrativeArea
        self.subAdministrativeArea = subAdministrativeArea
        self.location = location
    }
    
}


func getCoords(from address: String, completion: @escaping (_ locality: String,
                                                                    _ administrativeArea: String,
                                                                    _ subAdministrativeArea: String,
                                                                    _ location: CLLocationCoordinate2D) -> ()) {
    CLGeocoder().geocodeAddressString(address) {
        guard let info = $0?.first else {print($1!); return}
        guard let locality = info.locality else {print("locality error"); return}
        guard let location = info.location?.coordinate else {print("location  error"); return}
        completion(locality, info.administrativeArea ?? "", info.subAdministrativeArea ?? "", location)
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

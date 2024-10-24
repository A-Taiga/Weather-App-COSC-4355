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
    @Environment(\.modelContext) var modelContext
    @State var model = Model()
    @Query var savedData: [DataModel]
   
    var body: some View {
        NavigationStack {
            Spacer()
            List {
                ForEach(savedData, id: \.id) { data in
                    Section {
                        SavedLocationView(name: data.name, weatherData: data.weatherData, time: model.currentTime)
                            .environment(model.units)
                    }
                }
                .onDelete {set in _ = set.map{modelContext.delete(savedData[$0])}}
                .frame(height: 110)
                .listRowBackground(Color(.white).opacity(0))
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .environment(\.editMode, $model.editList)
            .overlay {listOverlay}
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $model.search.text,
                        isPresented: $model.searchFocused,
                        placement: .navigationBarDrawer(displayMode: .always))
            .toolbarRole(.editor)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ZStack {
                        if model.editList == .inactive {inactiveMenu
                        } else {activeMenu}
                    }
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(Double(model.buttonRotation)))
                    VStack {}
                }
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: model.searchFocused, {model.searchFocusedHandler()})
        .onChange(of: model.selectionTitle) {Task {await model.getLocationInfo()}}
        .sheet(isPresented: $model.showSelection, onDismiss: {model.dismissSheet()}) {weatherSheet}
        .sheet(isPresented: $model.showOtherUnits, onDismiss: {model.showOtherUnits = false}) {UnitsView(units: $model.units)}
        .onReceive(model.timer) {model.currentTime = $0.timeIntervalSince1970}
        
        // need to figure out how to update all saved weather data
//        .onReceive(model.weatherDataTimer) {_ in updateWeatherData()}
        
        // change this to check time passed instead for less calls
//        .onAppear(perform: updateWeatherData)
        // for debug
//        .onAppear() {
//            if let data = try? readUserFromBundle(fileName: "Houston1") {
//                modelContext.insert(DataModel(name: "Houston", weatherData: data))
//            }
//            if let data = try? readUserFromBundle(fileName: "NewYork1") {
//                modelContext.insert(DataModel(name: "New York", weatherData: data))
//            }
//        }
    }

    
    
    var inactiveMenu: some View {
        Menu {
            Button("Edit") {
                withAnimation {
                    model.editList = .active
                    model.buttonRotation = 90.0
                }
            }
            Picker(selection: $model.units.temp) {
                Text("Fahrenheit").tag(UnitsTemp.fahrenheit)
                Text("Celsius").tag(UnitsTemp.celsius)
            } label: {}
            Button("Units") {model.showOtherUnits = true}
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    var activeMenu: some View {
        Button {
            withAnimation {
                model.editList = .inactive
                model.buttonRotation = 0
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
    
    var listOverlay: some View {
        VStack {
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
                                .environment(model.units)
                            
                            HStack {
                                Button("Cancel") {
                                    model.showSelection = false
                                }
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                if !savedData.contains(where: {$0.name == location.locality}) {
                                    Button("Add") {
                                        modelContext.insert(DataModel(name: location.locality, weatherData: data))
                                        model.showSelection = false
                                        model.search.text = ""
                                        model.searchFocused = false
                                    }
                                    .font(.title3)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
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
    func updateWeatherData() {
        Task {@MainActor in
            for index in savedData.indices {
                await fetchData(lat: savedData[index].weatherData.lat, lon: savedData[index].weatherData.lat) {
                    if let data = $0 {
                        savedData[index].weatherData = data
                    }
                }
            }
        }
    }
}

extension ContentView {
    @Observable
    class Model {
        var units = Units()
        var search = Search()
        var selectionTitle: String?
        var selectedResult: LocationInfo?
        var selectedWeatherData: WeatherData?
        var showSelection = false
        var searchFocused = false
        var searchListOpacity = 0.0
        var currentTime = Date().timeIntervalSince1970
        var showOtherUnits = false
        var editList: EditMode = .inactive
        var buttonRotation = 0.0
        let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
//        let weatherDataTimer = Timer.publish(every: 600, on: .main, in: .common).autoconnect()
        
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
        .modelContainer(for: DataModel.self, inMemory: true)
}

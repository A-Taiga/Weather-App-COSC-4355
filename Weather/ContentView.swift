//
//  ContentView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//


// todo
/*
    figure out how to update all saved weather locations
    add option to get weather for user location
    make units changable from WeatherView
    add charts for some of the tiles when clicked on
    find a good photo for snow background
    maybe add drag and drop functionality for saved locations or tiles
 */


import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @State var model = Model()
    @Query(sort: \DataModel.listIndex) var savedData: [DataModel]
    @State var locationManager = LocationManager()
    var body: some View {
        NavigationStack {
            Spacer()
            List {
                ForEach(savedData) { data in
                    SavedLocationView(name: data.location.locality, weatherData: data.weatherData, time: model.currentTime)
                            .environment(model.units)
                }
                .onMove(perform: move)
                .onDelete {set in _ = set.map{modelContext.delete(savedData[$0])}; try? modelContext.save()}
                .frame(height: 110)
                .listRowBackground(Color(.white).opacity(0))
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                
            }
            .listRowSpacing(30)
            .environment(\.editMode, $model.editList)
            .overlay {listOverlay()}
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $model.search.text,
                        isPresented: $model.searchFocused,
                        placement: .navigationBarDrawer(displayMode: .always))
            .toolbarRole(.editor)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ZStack {
                        if model.editList == .inactive {inactiveMenu()} else {activeMenu()}
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
        .sheet(isPresented: $model.showSelection, onDismiss: {model.dismissSheet()}) {weatherSheet()}
        .sheet(isPresented: $model.showOtherUnits, onDismiss: {model.showOtherUnits = false}) {UnitsView(units: $model.units)}
        .onReceive(model.timer) {model.currentTime = $0.timeIntervalSince1970}
        .onAppear() {
            locationManager.checkLocationAuthorization()
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        var temp = savedData
        temp.move(fromOffsets: source, toOffset: destination)
        for (index, item) in temp.enumerated() {
            item.listIndex = index
        }
        try? modelContext.save()
    }
    
    
    @ViewBuilder
    func inactiveMenu() -> some View {
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
    @ViewBuilder
    func activeMenu() -> some View {
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
    
    @ViewBuilder
    func listOverlay() -> some View {
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
    
    @ViewBuilder
    func weatherSheet() -> some View {
        VStack {
            if let location = model.selectedResult {
                ZStack {
                    GeometryReader { _ in
                        if let data = self.model.selectedWeatherData {
                            WeatherView(name: location.locality, weatherData: data, isSheet: true)
                                .environment(model.tempStyle)
                                .environment(model.units)
                            
                            HStack {
                                Button("Cancel") {
                                    model.showSelection = false
                                }
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                if !savedData.contains(where: {$0.location == location}) {
                                    Button ("Add") {
                                        modelContext.insert(DataModel(location: location,
                                                                      weatherData: data,
                                                                      listIndex: savedData.isEmpty ? 0 : savedData.count))
                                        try? modelContext.save()
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
                }.task {
                    await fetchData(lat: location.lat, lon: location.lon) {
                        self.model.selectedWeatherData = $0
                        if let weather = $0?.current.weather[0] {
                            if (weather.weatherIcon.last == "d") {
                                model.tempStyle.setBackgroundImageDay(from: weather.weatherMain)
                            } else {
                                model.tempStyle.setBackgroundImageNight(from: weather.weatherMain)
                            }
                        }
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
        var tempStyle = Style()
        var selectionTitle: String?
        var selectedResult: LocationModel?
        var selectedWeatherData: WeatherData?
        var showSelection = false
        var searchFocused = false
        var searchListOpacity = 0.0
        var currentTime = Date().timeIntervalSince1970
        var showOtherUnits = false
        var editList: EditMode = .inactive
        var buttonRotation = 0.0
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
        
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
                self.selectedResult = LocationModel(locality: $0,
                                                    administrativeArea: $1,
                                                    subAdministrativeArea: $2,
                                                    coordinates: $3)
            }
        }
    }
}


@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var location: CLLocationCoordinate2D?
    var manager = CLLocationManager()
    var place: CLPlacemark?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        if let location = locations.first {
            CLGeocoder().reverseGeocodeLocation(location) { value, error in
                guard let value else {print("error"); return}
                self.place = value.first
            }
        }
    }
    
    func checkLocationAuthorization() {
        manager.delegate = self
//        manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .restricted: print(".restricted")
        case .denied: print(".denied")
        case .authorizedAlways: print(".authorizedAlways")
        case .authorizedWhenInUse: location = manager.location?.coordinate
        case .authorized: location = manager.location?.coordinate
        @unknown default: print("user location dissabled")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
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

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
    @Query(sort: \DataModel.listIndex) var savedData: [DataModel]
    @ObservedObject var locationManager = LocationManager()
    
    @State private var userLocation: DataModel?
    @State private var style = Style()
    @State private var units = Units()
    
    var body: some View {
        TabView {
            
            Tab("", systemImage: "list.bullet") {
                LocationListView()
                    .modelContext(modelContext)
                    .environment(units)
            }
            
            Tab("", systemImage: "location.fill") {
                if let userLocation {WeatherView(for: userLocation).environment(units)
                }
            }
            
            Tab("", systemImage: "gear") {
                
            }
        }
        .onAppear(perform: locationManager.checkLocationAuthorization)
        .task {await setUserLocation()}
        .onReceive(locationManager.$place) { _ in
            Task {
                await self.setUserLocation()
            }
        }
    }
    
    func setStyle() {
        guard let data = userLocation?.weatherData else {return}
        if (data.current.weather[0].weatherIcon.last == "d") {
            style.setBackgroundImageDay(from: data.current.weather[0].weatherMain)
        }
        else {style.setBackgroundImageNight(from: data.current.weather[0].weatherMain)}
    }
    
    func setUserLocation() async {
        if let savedUserLocation: DataModel = savedData.filter({$0.isUserLocation}).first {
            userLocation = savedUserLocation
        } else {
//            guard let location = locationManager.location else {return}
            guard let place = locationManager.place else {return}
            guard let data = try? readUserFromBundle(fileName: "GoldHillOR") else {return}
            self.userLocation = DataModel(location: place,
                                          weatherData: data,
                                          listIndex: savedData.isEmpty ? 0 : savedData.count)
            self.userLocation!.isUserLocation = true
            self.modelContext.insert(self.userLocation!)
            setStyle()
//            await fetchData(lat: location.latitude, lon: location.longitude) { data in
//                guard let data else {return}
//                self.userLocation = DataModel(location: place,
//                                              weatherData: data,
//                                              listIndex: savedData.isEmpty ? 0 : savedData.count)
//                self.modelContext.insert(DataModel(location: place,
//                                                   weatherData: data,
//                                                   listIndex: savedData.isEmpty ? 0 : savedData.count))
//                try? modelContext.save()
//                setStyle()
//            }
        }
    }
}

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    @Published var location: CLLocationCoordinate2D?
    @Published var manager = CLLocationManager()
    @Published var place: LocationModel?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        if let location = locations.first {
            CLGeocoder().reverseGeocodeLocation(location) { value, error in
                guard let first = value?.first,
                      let local = first.locality
                else {print("locationManager() error"); return}
                self.place = LocationModel(locality: local,
                                           administrativeArea: first.administrativeArea ?? "",
                                           subAdministrativeArea: first.subAdministrativeArea ?? "",
                                           coordinates: location.coordinate)
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


//
//@Observable
//final class LocationManager: NSObject, CLLocationManagerDelegate {
//    
//    var location: CLLocationCoordinate2D?
//    var manager = CLLocationManager()
//    var place: LocationModel?
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        location = locations.first?.coordinate
//        if let location = locations.first {
//            CLGeocoder().reverseGeocodeLocation(location) { value, error in
////                guard let value = value?.first else {print("error"); return}
//                guard let first = value?.first,
//                      let local = first.locality
//                else {print("locationManager() error"); return}
//                self.place = LocationModel(locality: local,
//                                           administrativeArea: first.administrativeArea ?? "",
//                                           subAdministrativeArea: first.subAdministrativeArea ?? "",
//                                           coordinates: location.coordinate)
//            }
//        }
//    }
//    
//    func checkLocationAuthorization() {
//        manager.delegate = self
////        manager.startUpdatingLocation()
//        manager.startMonitoringSignificantLocationChanges()
//        switch manager.authorizationStatus {
//        case .notDetermined: manager.requestWhenInUseAuthorization()
//        case .restricted: print(".restricted")
//        case .denied: print(".denied")
//        case .authorizedAlways: print(".authorizedAlways")
//        case .authorizedWhenInUse: location = manager.location?.coordinate
//        case .authorized: location = manager.location?.coordinate
//        @unknown default: print("user location dissabled")
//        }
//    }
//    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        checkLocationAuthorization()
//    }
//}

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

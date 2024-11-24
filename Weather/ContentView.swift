//
//  ContentView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//


// todo


/*
 
 
 
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
    @State private var selectedUnits = SelectedUnits()
    @State private var timeModel = TimeModel()
    
    var body: some View {
        TabView {
            Tab("", systemImage: "list.bullet") {
                LocationListView()
                    .modelContext(modelContext)
                    .environment(selectedUnits)
                    .environment(timeModel)
            }
            
            Tab("", systemImage: "gear") {
                UnitsView(selectedUnits: $selectedUnits)
            }
        }
        .onAppear(perform: locationManager.checkLocationAuthorization)
        .task {await setUserLocation()}
        .onReceive(locationManager.$place) { _ in
            Task {
                await self.setUserLocation()
            }
        }
        .onAppear {
            // when app starts add timers for all locations to update every 10 minutes
            for index in savedData.indices {
                timeModel.createTimer(id: savedData[index].id, interval: 60*10) {
                    Task {
                        await savedData[index].fetch()
                    }
                }
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
            guard let place = locationManager.place else {return}
            guard let data = try? readUserFromBundle(fileName: "GoldHillOR") else {return}
            self.userLocation = DataModel(location: place,
                                          weatherData: data,
                                          listIndex: savedData.isEmpty ? 0 : savedData.count)
            self.userLocation!.isUserLocation = true
            
            
            self.modelContext.insert(self.userLocation!)
            
            setStyle()
        }
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


// MARK: TimeModel
// this class allows for fetching data in user defined time intervals
@Observable
class TimeModel {
    
    var currentTime = Date()
    var timers: [UUID:Timer] = [:]
    
    
    // init with a timer for the current date time
    init() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.currentTime = Date()
        }
    }
    
    // add a timer
    func createTimer(id: UUID, interval: TimeInterval, _ closure: @escaping () -> Void) {
        if timers.contains(where: {$0.key == id}) {return}
        timers[id] = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {_ in
            closure()
        }
    }
    
    // delete a timer
    func deleteTimer(for id: UUID) {
        guard let timer = timers[id] else {return}
        timer.invalidate()
    }
    
    // formatting function
    func computeTime(from timeZone: String, _ format: String? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        if let format {
            dateFormatter.dateFormat = format
        } else {
            dateFormatter.dateFormat = "h:mm a"
        }
        return dateFormatter.string(from: currentTime)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: DataModel.self, inMemory: true)
}

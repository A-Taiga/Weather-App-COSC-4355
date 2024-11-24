//
//  UserLocationManager.swift
//  Weather
//
//  Created by Anthony Polka on 11/24/24.
//

import Foundation
import MapKit


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

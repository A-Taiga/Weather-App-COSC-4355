//
//  UnitsView.swift
//  Weather
//
//  Created by Anthony Polka on 10/23/24.
//

import SwiftUI

struct UnitsView: View {
    
    @Binding private var selectedUnits: SelectedUnits
    
    init(selectedUnits: Binding<SelectedUnits>) {
        self._selectedUnits = selectedUnits
    }
    
    var body: some View {
        Form {
            Section(header: Text("Temprature")) {
                Picker(selection: $selectedUnits.temperature) {
                    Text("Fahrenheit (°F)").tag(TemperatureUnit.fahrenheit)
                    Text("Celsius (°C)").tag(TemperatureUnit.celsius)
                } label: {}
                .pickerStyle(.inline)
            }
            Section(header: Text("Other Units")) {
                Picker("Wind Speed", selection: $selectedUnits.speed) {
                    Text("mph").tag(SpeedUnit.milesPerHour)
                    Text("km/h").tag(SpeedUnit.kilometersPerHour)
                    Text("m/s").tag(SpeedUnit.metersPerSecond)
                    Text("kn").tag(SpeedUnit.knots)
                }
                Picker("Precipitation", selection: $selectedUnits.precipitation) {
                    Text("in").tag(PrecipitationUnit.inches)
                    Text("mm").tag(PrecipitationUnit.millimeters)
                    Text("cm").tag(PrecipitationUnit.centimeter)
                }
                Picker("Distance", selection: $selectedUnits.distance) {
                    Text("mi").tag(DistanceUnit.miles)
                    Text("km").tag(DistanceUnit.kilometers)
                }
            }
        }.scrollDisabled(true)
    }
}

#Preview {
    struct Preview: View {
        @State var selectedUnits = SelectedUnits()
        var body: some View {
            UnitsView(selectedUnits: $selectedUnits)
        }
    }
    return Preview()
}

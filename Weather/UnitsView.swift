//
//  UnitsView.swift
//  Weather
//
//  Created by Anthony Polka on 10/23/24.
//

import SwiftUI

struct UnitsView: View {
    
    @Binding private var units: Units
    
    init(units: Binding<Units>) {
        self._units = units
    }
    
    var body: some View {
            VStack {
                List {
                    Section("temperature") {
                        Picker(selection: $units.temp) {
                            Text("Fahrenheit (°F)").tag(UnitsTemp.fahrenheit)
                            Text("Celsius (°C)").tag(UnitsTemp.celsius)
                        } label: {}
                        .pickerStyle(.inline)
                    }
                    Section("Other Units") {
                        Picker("Wind", selection: $units.wind) {
                            Text("mph").tag(UnitsSpeed.milesPerHour)
                            Text("km/h").tag(UnitsSpeed.kilometersPerHour)
                            Text("m/s").tag(UnitsSpeed.metersPerSecond)
                            Text("kn").tag(UnitsSpeed.knots)
                        }
                        Picker("Precipitation", selection: $units.precipitation) {
                            Text("in").tag(UnitsPrecipitation.inches)
                            Text("mm").tag(UnitsPrecipitation.millimeters)
                            Text("cm").tag(UnitsPrecipitation.centimeter)
                        }
                        Picker("Distance", selection: $units.distance) {
                            Text("mi").tag(UnitsDistance.miles)
                            Text("km").tag(UnitsDistance.kilometers)
                        }
                    }
                }
            }
        }
}

#Preview {
    struct Preview: View {
        @State var units = Units()
        var body: some View {
            UnitsView(units: $units)
        }
    }
    return Preview()
}

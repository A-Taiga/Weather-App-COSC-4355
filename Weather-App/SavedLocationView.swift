//
//  SavedLocationView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import SwiftUI

struct SavedLocationView: View {
    
    @State var location: Location
    @State var address: AddressResult?
    @State var style = Style()
    
    init(location: Location) {
        self.location = location
        self.address = AddressResult(title: location.title, subtitle: location.subtitle)
    }
   
    var body: some View {
        ZStack {
            if let d = location.weatherData {
                HStack(alignment: .top) {
                    VStack {
                        Text(location.title)
                            .font(.title2)
                    }
                    Spacer()
                    if let data = location.weatherData {
                        VStack(alignment: .trailing) {
                            HStack {
                                getSymbol(icon: data.currently.icon)
                                    .scaledToFit()
                                Text("\(Int(data.currently.temperature))°")
                                    .font(.title)
                            }
                            Text("H: \(Int(data.daily.data[1].temperatureHigh))") +
                            Text(" L: \(Int(data.daily.data[1].temperatureLow))")
                        }
                    }
                }
                .onAppear() {
                    style.setFont(icon: d.currently.icon)
                    style.setBackground(icon: d.currently.icon)
                }
                
                NavigationLink (destination: WeatherView(weatherData: $location.weatherData, title: location.title)) {
                    EmptyView()
                }.opacity(0)
            }
        }
        .shadow(radius: 10)
        .foregroundStyle(style.fontColor)
        .padding()
        .background(LinearGradient(gradient: style.bgColor, startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        @State var location = Location(title: "Houston, TX", subtitle: "Texas, United States", lat: 0.0, lon: 0.0, weatherData: nil)
        var body: some View {
            NavigationStack {
                SavedLocationView(location: location)
                    .padding()
                    .frame(height: 150)
                    .task {
                        location.weatherData = readUserFromBundle(fileName: "Houston")
                    }
            }
        }
    }
    return Preview()
}

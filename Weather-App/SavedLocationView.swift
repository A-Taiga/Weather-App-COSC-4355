//
//  SavedLocationView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import SwiftUI

struct SavedLocationView: View {
    @Binding var weatherData: WeatherData?
    var viewModel = ViewModel()
    let title: String
    let subtitle: String
    
    init(weatherData: Binding<WeatherData?>, title: String, subtitle: String) {
        self._weatherData = weatherData
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        Group {
            HStack(alignment: .top) {
                VStack {
                    Text(title)
                        .font(.title2)
                }
                Spacer()
                if let data = weatherData {
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
        }
        .padding()
        .background(
            LinearGradient(gradient: viewModel.weatherBackground(icon: weatherData?.currently.icon ?? ""),
                           startPoint: .bottom,
                           endPoint: .top))

        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}



extension SavedLocationView {
    class ViewModel {
        
        func weatherBackground (icon: String) -> Gradient {
            switch (icon) {
            case "clear-day":   Gradient(colors: [Color("clear2"), Color("storm2")])
                //                case "clear-night":
            case "rain":        Gradient(colors: [Color("storm2"), Color("storm3")])
                //                case "snow":
                //                case "sleet":
                //                case "wind":
                //                case "fog":
                //                case "cloudy":
            case "partly-cloudy-day": Gradient(colors: [Color("clear2"), Color("storm2")])
                //                case "partly-cloudy-night":
            default: Gradient(colors:[.black])
            }
        }
    }
}
















#Preview {
    struct Preview: View {
        @State var data: WeatherData?
        var body: some View {
            SavedLocationView(weatherData: $data, title: "Jefferson City, MO", subtitle: "Missouri, United States")
                .font(.system(size: 15))
                .frame(height: 100)
                .padding()
                .task {
                    data = readUserFromBundle(fileName: "JeffersonCity")
                }
        }
    }
    return Preview()
}

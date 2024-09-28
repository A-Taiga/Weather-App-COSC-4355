//
//  WeatherView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import SwiftUI

struct WeatherView: View {
    
    var viewModel: ViewModel
    @Binding var weatherData: WeatherData?
    
    init(weatherData: Binding<WeatherData?>, title: String?, subtitle: String?) {
        self._weatherData = weatherData
        self.viewModel = ViewModel(title: title, subtitle: subtitle)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center) {
                Text(viewModel.title?.split(separator: ",")[0] ?? "--")
                    .font(.title)
                    .padding(.top, 100)
                Text("\(Int(weatherData?.currently.temperature ?? 0))°")
                    .font(.system(size: 60))
                if let summary = weatherData?.currently.summary {
                    Text(summary)
                        .font(.system(size: 30))
                }
                (Text("H: \(Int(weatherData?.daily.data[1].temperatureLow ?? 0))°") +
                Text(" L: \(Int(weatherData?.daily.data[1].temperatureHigh ?? 0))°"))
                .font(.system(size: 25))
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 200)
                        .opacity(0.1)
                        .blur(radius: 1)
                        .scaledToFill()
                    HourlyView(weatherData: $weatherData)
                }
                .padding()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .opacity(0.1)
                        .blur(radius: 1)
                        .scaledToFill()
                    WeeklyView(weatherData: $weatherData)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [Color("storm2"), Color("storm3")]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

extension WeatherView {
    class ViewModel {
        let title: String?
        let subtitle: String?
        
        init(title: String?, subtitle: String?) {
            self.title = title
            self.subtitle = subtitle
        }
    }
}

#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        var body: some View {
            WeatherView(weatherData: $weatherData, title: "Jefferson City, MO", subtitle: "Missouri, United States")
                .task {
                    weatherData = readUserFromBundle(fileName: "JeffersonCity")
                }
        }
    }
    return Preview()
}

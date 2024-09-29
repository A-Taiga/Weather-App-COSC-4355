//
//  WeatherView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import SwiftUI


extension WeatherView {
    @Observable
    class ViewModel {
    }
}

struct WeatherView: View {
    
    @State var style = Style()
    @State var viewModel = ViewModel()
    @Binding var weatherData: WeatherData?
    
    let title: String
    
    init(weatherData: Binding<WeatherData?>, title: String) {
        self._weatherData = weatherData
        self.title = title
    }
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            if let _ = weatherData {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    
                    Text(title.split(separator: ",")[0])
                        .font(.title)
                        .padding(.top, 100)
                    
                    Text("\(Int(weatherData?.currently.temperature ?? 0))")
                        .font(.system(size: 60))
                        .padding([.leading, .trailing], 25)
                        .overlay(alignment: .trailing) { Text("°") .font(.system(size: 60))}
                    
                    if let summary = weatherData?.currently.summary {
                        Text(summary)
                            .font(.system(size: 30))
                    }
                    
                    (Text("L: \(Int(weatherData?.daily.data[1].temperatureLow ?? 0))°") +
                     Text(" H: \(Int(weatherData?.daily.data[1].temperatureHigh ?? 0))°"))
                    .font(.system(size: 25))
                    
                    hourly()
                    daily()
                    
                    
                }
                .onAppear() {
                    guard let icon = weatherData?.currently.icon else {return}
                    style.setFont(icon: icon)
                    style.setBackground(icon: icon)
                }
            }
        }
        .foregroundStyle(style.fontColor)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: style.bgColor, startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
    }
    
    @ViewBuilder
    func hourly() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 250)
                .opacity(0.1)
                .blur(radius: 1)
                .scaledToFill()
            VStack(alignment: .leading) {
                (Text(Image(systemName: "clock")) + Text(" Hourly Forecast"))
                    .padding([.top, .leading])
                Divider().overlay(style.fontColor)
                HourlyView(weatherData: $weatherData)
                    .environment(style)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    func daily() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .opacity(0.1)
                .blur(radius: 1)
            VStack(alignment: .leading) {
                (Text(Image(systemName: "clock")) + Text(" Hourly Forecast"))
                    .padding([.top, .leading])
                Divider().overlay(style.fontColor)
                WeeklyView(weatherData: $weatherData)
                    .environment(style)
            }
        }
        .padding()
    }
    
}

@Observable
class Style {
    var fontColor: Color = .white
    var bgColor: Gradient = Gradient(colors: [Color("clear2"), Color("storm2")])
    
    func setFont(icon: String) {
        switch (icon) {
        case "clear-day":           fontColor = .black
        case "clear-night":         fontColor = .white
        case "rain":                fontColor = .black
        case "cloudy":              fontColor = .black
        case "partly-cloudy-day":   fontColor = .black
//            case "partly-cloudy-night":
//            case "snow":
//            case "sleet":
//            case "wind":
//            case "fog":
        default:                    fontColor = .red
        }
    }
    
    func setBackground(icon: String) {
        switch (icon) {
        case "clear-day":         bgColor = Gradient(colors: [Color("clear1"), Color("clear2"), Color("clear3"), Color("clear4")])
        case "clear-night":       bgColor = Gradient(colors: [Color("night1"), Color("night2"), Color("night3"), Color("night4")])
        case "rain":              bgColor = Gradient(colors: [Color("storm1"), Color("storm2"), Color("clear3"), Color("clear4")])
        case "cloudy":            bgColor = Gradient(colors: [Color("clear3"), Color("clear3"), Color("clear3"), Color("storm4")])
        case "partly-cloudy-day": bgColor = Gradient(colors: [Color("stormy1"), Color("storm2"), Color("storm2"), Color("storm1")])
//            case "partly-cloudy-night":
//            case "snow":
//            case "sleet":
//            case "wind":
//            case "fog":
        default:                  bgColor = Gradient(colors:[.black])
        }
    }
}


#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        @State var address: AddressResult? = AddressResult(title: "Houston, TX", subtitle: "Texas, United States")
        var body: some View {
            WeatherView(weatherData: $weatherData, title: "Houston, TX")
                .task {
                    weatherData = readUserFromBundle(fileName: "Houston")
                }
        }
    }
    return Preview()
}

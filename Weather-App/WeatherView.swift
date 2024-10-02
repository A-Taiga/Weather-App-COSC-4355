//
//  WeatherView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import SwiftUI


extension WeatherView {
    class ViewModel {
        let tileWidth: CGFloat = 170
        let tileHeight: CGFloat = 170
    }
}

struct WeatherView: View {
    
    @Environment(Units.self) var units
    @State var alertPressed = false
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
            if let data = weatherData {
               
            
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                   
                    
                    Text(title.split(separator: ",")[0])
                        .font(.title)
                        .padding(.top, 100)
                    
                    Text("\(units.handleTemp(val: data.currently.temperature))")
                        .font(.system(size: 60))
                        .padding([.leading, .trailing], 25)
                        .overlay(alignment: .trailing) { Text("°") .font(.system(size: 60))}
                    
                    if let summary = weatherData?.currently.summary {
                        Text(summary)
                            .font(.system(size: 30))
                    }
                    
                    (Text("L: \(units.handleTemp(val: data.daily.data[1].temperatureLow))°") +
                     Text(" H: \(units.handleTemp(val: data.daily.data[1].temperatureHigh))°"))
                    .font(.system(size: 25))
                    
                    alert()
                    hourly()
                    daily()
                    
                    Spacer()
                    
                    HStack {
                        tile(title: "Humidity",
                             value: "\(Int(data.currently.humidity * 100))%",
                             icon: Image(systemName: "humidity.fill").foregroundStyle(.blue,.white))
                        Spacer()
                        tile(title: "Feels Like",
                             value: "\(units.handleTemp(val: data.currently.feelsLike)) \(units.handleUnit(UnitsTemp.self))",
                             icon: Image(systemName: "thermometer.medium").foregroundStyle(.red,.white))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    wind()
                    moonPhases()
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
        .sheet(isPresented: $alertPressed, onDismiss: {self.alertPressed = false}) {
            if let alerts = weatherData?.alerts {
                AlertView(title: title, alertData: alerts, timeZone: weatherData!.timezone)
                    .padding(.top)
            }
        }
    }
    @ViewBuilder
    func moonPhases() -> some View {
        if let data = weatherData?.daily {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .opacity(0.1)
                    .blur(radius: 1)
                
                VStack(alignment: .leading) {
                    HStack {
                        VStack {
                            
                            (Text(Image(systemName: "moon.fill")) + Text(" Moon Phase"))
                            Spacer()
                            Text(getMoonPhaseName(data: data.data[0].moonPhase))
                            Spacer()
                            HStack {
                                ForEach (data.data, id: \.self) { day in
                                    VStack {
                                        Text(unixToTime(day.time, format: "E").prefix(1))
                                        getMoonPhase(data: day.moonPhase)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        getMoonPhase(data: data.data[0].moonPhase)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .aspectRatio(contentMode: .fit)
                            .padding(.trailing)
                    }
                }
                .padding()
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func alert() -> some View {
        if let data = weatherData?.alerts {
            if !data.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .opacity(0.1)
                        .blur(radius: 1)
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.black, .yellow)
                            Text(getAlertTitle(title: data[0].title))
                            if data.count > 1 {
                                Text("and \(data.count-1) more")
                                    .font(.subheadline)
                                    .fontWeight(.light)
                                    .frame(alignment: .centerFirstTextBaseline)
                            }
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding([.leading, .top])
                        
                        Divider().overlay(style.fontColor)
                        Text(data[0].title)
                            .padding()
                    }
                }
                .padding()
                .onTapGesture {
                    alertPressed = true
                }
            }
        } else {
            EmptyView()
        }
    }
    
    
    @ViewBuilder
    func wind() -> some View {
        
        if let data = weatherData?.currently {
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .opacity(0.1)
                    .blur(radius: 1)
                HStack {
                    VStack {
                    HStack {
                        Image(systemName: "wind")
                        Text("Wind")
                        Spacer()
                    }
                    .padding([.top,.leading])
                        Spacer()
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Speed")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("\(units.handleWind(val: data.windSpeed)) \(units.handleUnit(UnitsSpeed.self))")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                }
                                Divider().overlay{style.fontColor}
                                HStack {
                                    Text("Gusts")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("\(units.handleWind(val: data.windGust)) \(units.handleUnit(UnitsSpeed.self))")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider().overlay{style.fontColor}
                                HStack {
                                    Text("Direction")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("\(Int(data.windBearing))° \(getWindBearing(val: data.windBearing))")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    .padding([.leading, .bottom])

                        ZStack {
                            ForEach(1...120, id: \.self) { index in
                                Rectangle()
                                    .frame(width: 1, height: 10)
                                    .padding(.bottom, 120)
                                    .opacity(((index % 30) != 0) ? 0.5 : 1)
                                    .rotationEffect(Angle(degrees: Double(index) * 3))
                            }
                            Text("N")
                                .padding(.bottom, 160)
                            Text("S")
                                .padding(.top, 160)
                            Text("E")
                                .padding(.leading, 160)
                            Text("W")
                                .padding(.trailing, 160)
                            
                            Rectangle()
                                .frame(width: 3, height: 100)
                                .overlay(alignment: .top) {
                                    Image(systemName: "location.north.fill")
                                        .frame(width: 10, height: 10)
                                        .foregroundStyle(.white)
                                }
                                .rotationEffect(Angle(degrees: data.windBearing))
                        }
                        .frame(minWidth: 180, maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func tile(title: String, value: String, icon: some View) -> some View {
    
        RoundedRectangle(cornerRadius: 10)
            .opacity(0.1)
            .blur(radius: 1)
            .overlay {
                VStack(alignment: .center) {
                    HStack {
                        icon
                        Text(title)
                    }
                    .padding(.top, 10)
                    Text(value)
                        .font(.title)
                        .padding(.top)
                    Spacer()
                }
            }
            .scaledToFill()
            .padding()
    }
    
    @ViewBuilder
    func hourly() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 250)
                .opacity(0.1)
                .blur(radius: 1)
            VStack(alignment: .leading) {
                (Text(Image(systemName: "clock")) + Text(" Hourly Forecast"))
                    .padding([.top, .leading])
                Divider().overlay(style.fontColor)
                HourlyView(weatherData: $weatherData)
                    .environment(style)
                    .environment(units)
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
                    .environment(units)
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
        case "partly-cloudy-night": fontColor = .white
//            case "snow":
//            case "sleet":
//            case "wind":
//            case "fog":
        default:                    fontColor = .red
        }
    }
    
    func setBackground(icon: String) {
        switch (icon) {
        case "clear-day":           bgColor = Gradient(colors: [Color("clear1"), Color("clear2"), Color("clear3"), Color("clear4")])
        case "clear-night":         bgColor = Gradient(colors: [Color("night1"), Color("night2"), Color("night3"), Color("night4")])
        case "rain":                bgColor = Gradient(colors: [Color("storm1"), Color("storm2"), Color("clear3"), Color("clear4")])
        case "cloudy":              bgColor = Gradient(colors: [Color("cloudy1"), Color("cloudy2"), Color("cloudy3"), Color("cloudy4")])
        case "partly-cloudy-day":   bgColor = Gradient(colors: [Color("stormy1"), Color("storm2"), Color("storm2"), Color("storm1")])
        case "partly-cloudy-night": bgColor = Gradient(colors: [Color("night1"), Color("night2"), Color("night3"), Color("night4")])
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
                .environment(Units())
        }
    }
    return Preview()
}

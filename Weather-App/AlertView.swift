//
//  AlertView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/30/24.
//

import SwiftUI


struct AlertView: View {
    
    
    let title: String
    let alertData: [Alert]
    let timeZone: String

    init(title: String, alertData: [Alert], timeZone: String) {
        self.title = title
        self.alertData = alertData
        self.timeZone = timeZone
    }

    var body: some View {
        VStack() {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white, .yellow)
                Text("Weather Alert")
                    .font(.title)
            }
            .frame(height: 50)
            .padding(.bottom)
            
            List {
                ForEach(alertData, id: \.id) { alert in
                    DisclosureGroup() {
                        VStack(alignment: .leading) {
                            Text("Issue Date")
                                .fontWeight(.bold)
                            (Text("\(unixToTime(alert.time, format: "h:mm a")) (\(getTimeZone(zone: timeZone))), ") +
                            Text("\(unixToTime(alert.time, format: "MMMM d"))"))
                                .opacity(0.5)
                        }
                        VStack(alignment: .leading) {
                            Text("Expire Time")
                                .fontWeight(.bold)
                        
                            (Text("\(unixToTime(alert.expires, format: "h:mm a")) (\(getTimeZone(zone: timeZone))), ") +
                            Text("\(unixToTime(alert.expires, format: "MMMM d"))"))
                                .opacity(0.5)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Severity")
                                .fontWeight(.bold)
                            Text(alert.severity)
                                .opacity(0.5)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Description")
                                .fontWeight(.bold)
                            Text(alert.description.split(separator: " ")[0])
                                .opacity(0.5)
                            Spacer()
                            Text(LocalizedStringKey(formatDescription(description: alert.description)))
                                .opacity(0.5)
                        }
                    } label: {
                        HStack {
                            getAlertSymbol(title: alert.title).scaledToFit()
                                .padding(.trailing)
                            Text(getAlertTitle(title: alert.title))
                        }
                        .frame(maxHeight: 30)
                    }
                }
            }
        }
    }
    
    func getTimeZone (zone: String) -> String {
        let timeZone = TimeZone(identifier: zone)
        let result = TimeZone.abbreviationDictionary.first(where: {$1 == timeZone?.identifier})?.key
        guard let result = result else {return ""}
        return result
    }
    
    func formatDescription(description: String) -> String {
        return String((description.components(separatedBy: " ").dropFirst().joined(separator: " ")).dropFirst())
    }
}

#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        var body: some View {
            VStack {
                if let alerts = weatherData?.alerts {
                    AlertView(title: "Houston", alertData: alerts, timeZone: weatherData?.timezone ?? "")
                }
            }.task {
                weatherData = readUserFromBundle(fileName: "RapidCitySD")
            }
        }
    }
    return Preview()
}

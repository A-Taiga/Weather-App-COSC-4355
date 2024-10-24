//
//  AlertView.swift
//  Weather
//
//  Created by Anthony Polka on 10/23/24.
//

import SwiftUI

struct AlertView: View {
    let alerts: [Alert]
    let timeZone: String
    @Binding var presented: Bool
    
    init(alerts: [Alert], timeZone: String, didExit: Binding<Bool>) {
        self.alerts = alerts
        self.timeZone = timeZone
        self._presented = didExit
    }
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {presented = false
                } label: {
                    Image(systemName: "x.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .frame(height: 30)
            .padding()
            Image(systemName: "exclamationmark.triangle.fill")
                .symbolRenderingMode(.multicolor)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
            (Text("\(alerts.count) Weather ") +
            Text("\(alerts.count > 1 ? "Alerts" : "Alert")"))
            .font(.title)
            List(alerts) { alert in
                DisclosureGroup(alert.event) {
                    VStack(alignment: .leading) {
                        Text("Issue Date").fontWeight(.bold)
                        Text("\(unixToTime(Int32(alert.start), format: "MMMM d @ h:mm a")) \(getTimeZone(zone: timeZone))")
                            .foregroundStyle(.gray)
                        Divider()
                        Text("Expire Date").fontWeight(.bold)
                        Text("\(unixToTime(Int32(alert.end), format: "MMMM d @ h:mm a")) \(getTimeZone(zone: timeZone))")
                            .foregroundStyle(.gray)
                        Divider()
                        Text("Sender").fontWeight(.bold)
                        Text(alert.sender_name).foregroundStyle(.gray)
                        Divider()
                        Text("Description").fontWeight(.bold)
                        Text(LocalizedStringKey(alert.description)).foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

extension AlertView {
    func getTimeZone (zone: String) -> String {
            let timeZone = TimeZone(identifier: zone)
            let result = TimeZone.abbreviationDictionary.first(where: {$1 == timeZone?.identifier})?.key
            guard let result = result else {return ""}
            return result
        }
}

#Preview {
    struct Preview: View {
        @State var data: WeatherData?
        @State var close = false
        var body: some View {
            VStack {
                if let data = data,
                   let alerts = data.alerts {
                    AlertView(alerts: alerts, timeZone: data.timezone, didExit: $close).preferredColorScheme(.dark)
                }
            }.task {
                do {
                    data = try readUserFromBundle(fileName: "GoldHillOR")
                } catch {
                    print(error)
                }
            }
        }
    }
    return Preview()
}

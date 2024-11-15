//
//  AlertTileView.swift
//  Weather
//
//  Created by Anthony Polka on 11/14/24.
//

import SwiftUI

struct AlertTileView: View {
    
    
    let alerts: [Alert]
    @State private var onPress = false
    
    init(alerts: [Alert]) {
        self.alerts = alerts
    }
    
    var body: some View {
    
        ZStack {
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
            }
            Button {
                onPress = true
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .symbolRenderingMode(.multicolor)
                    Text(alerts[0].event)
                }
                .font(.title)
                .padding()
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $onPress) {
                AlertView(alerts: alerts, timeZone: "", didExit: $onPress)
            }
        }
    }
}

#Preview {
    
    struct Preview: View {
        @State var alerts: [Alert]
        init () {
            if let result = try? readUserFromBundle(fileName: "AlertsDummyData")?.alerts {
                self.alerts = result
            } else {
                self.alerts = []
            }
        }
        var body: some View {
            AlertTileView(alerts: alerts)
                .scaledToFit()
                .padding()
        }
    }
    return Preview()
}

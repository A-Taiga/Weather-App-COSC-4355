//
//  MoonPhaseTile.swift
//  Weather
//
//  Created by Anthony Polka on 10/15/24.
//

import SwiftUI
import TinyMoon

struct MoonPhaseTileView: View {
    
    @State private var model = Model()
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .opacity(0.1)
                .blur(radius: 1)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    if let phase = model.phases[model.currentPhaseName] {
                        Image(systemName:  phase)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    Text("Moon Phase")
                }
                .frame(height: 20)
                .padding([.top, .bottom, .leading])
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text(model.currentMoonName)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Divider()
                        HStack {
                            Text("Next Full Moon: ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(model.nextFullMoon) \(model.nextFullMoon > 1 ? "days" : "day")")
                        }
                        Divider()
                        HStack {
                            Text("Next New Moon: ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(model.nextNewMoon) \(model.nextNewMoon > 1 ? "days" : "day")")
                        }
                        Divider()
                        HStack {
                            Spacer()
                            ForEach(1..<8) { day in
                                if let date = Calendar.current.date(byAdding: .day, value: day, to: Date.now),
                                   let phase = model.phases[TinyMoon.calculateExactMoonPhase(date).moonPhase] {
                                    VStack {
                                        Text("\(model.getWeekDay(date: date).prefix(1))")
                                        Image(systemName: phase)
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize()
                    .padding()
                    Text(model.currentMoonEmoji)
                        .font(.system(size: 100))
                        .padding(.trailing)
                }
            }
        }
    }
}

extension MoonPhaseTileView {
    @Observable
    class Model {
        let currentMoonName: String
        let currentPhaseName: TinyMoon.MoonPhase
        let currentMoonEmoji: String
        let nextFullMoon: Int
        let nextNewMoon: Int
        
        let phases = [
            TinyMoon.MoonPhase.newMoon:          "moonphase.new.moon.inverse",
            TinyMoon.MoonPhase.waxingCrescent:   "moonphase.waxing.crescent.inverse",
            TinyMoon.MoonPhase.firstQuarter:     "moonphase.first.quarter.inverse",
            TinyMoon.MoonPhase.waxingGibbous:    "moonphase.waxing.gibbous.inverse",
            TinyMoon.MoonPhase.fullMoon:         "moonphase.full.moon.inverse",
            TinyMoon.MoonPhase.waningGibbous:    "moonphase.waning.gibbous.inverse",
            TinyMoon.MoonPhase.lastQuarter:      "moonphase.last.quarter.inverse",
            TinyMoon.MoonPhase.waningCrescent:   "moonphase.waning.crescent.inverse"
        ]
        
        init() {
            let moon = TinyMoon.calculateMoonPhase()
            self.currentMoonName = moon.name
            self.currentPhaseName = moon.moonPhase
            self.currentMoonEmoji = moon.emoji
            self.nextFullMoon = moon.daysTillFullMoon
            self.nextNewMoon = moon.daysTillNewMoon
        }
        
        func getWeekDay (date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    struct Preview: View {
        var body: some View {
            MoonPhaseTileView()
                .padding()
        }
    }
    return Preview()
}

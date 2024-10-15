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
            RoundedRectangle(cornerRadius: 10).fill(.black)
                .opacity(0.3)
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
                Divider().overlay(.primary)
                HStack {
                    VStack(alignment: .leading) {
                        Text(model.currentMoonName)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Divider().overlay(.primary)
                        HStack {
                            Text("Next Full Moon: ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(model.nextFullMoon) \(model.nextFullMoon > 1 ? "days" : "day")")
                        }
                        Divider().overlay(.primary)
                        HStack {
                            Text("Next New Moon: ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(model.nextNewMoon) \(model.nextNewMoon > 1 ? "days" : "day")")
                        }
                        Divider().overlay(.primary)
                        HStack {
                            Spacer()
                            ForEach(1..<8) { day in
                                if let date = Calendar.current.date(byAdding: .day, value: day, to: Date.now),
                                   let phase = model.phases[TinyMoon.calculateExactMoonPhase(date).moonPhase] {
                                    VStack {
//                                        Text("\(model.getWeekDay(date: date).prefix(1))")
                                        Text("\(date.formatted(.dateTime.weekday(.abbreviated)).prefix(1))")
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
        .onTapGesture {model.isPresented = true}
        .sheet(isPresented: $model.isPresented) {
            MoonPhaseInfoView(model: model)
                .apply{$0.presentationBackground(.ultraThinMaterial)}
                .foregroundStyle(.black)
                .onAppear{
                    setWindowBackgroundColor(.black)
                }
        }
    }
    
    private func setWindowBackgroundColor(_ color: UIColor) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let window = windowScene.windows.first {
            window.backgroundColor = color
        }
    }
}

extension MoonPhaseTileView {
    @Observable
    class Model {
        var isPresented = false
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
        
        
        
        func getMoonPhase(from date: Date) -> String {
            let moon = TinyMoon.calculateExactMoonPhase(date)
            guard let phase = phases[moon.moonPhase] else {return ""}
            return phase
        }
        
        func generateDays (for dateInterval: DateInterval) -> [Date] {
            generateDates(for: dateInterval,
                          matching: Calendar.current.dateComponents([.hour, .minute, .second], from: dateInterval.start)
            )
        }
        
        func generateDates (for dateInterval: DateInterval, matching components: DateComponents) -> [Date] {
            var dates = [dateInterval.start]
            Calendar.current.enumerateDates(
                startingAfter: dateInterval.start,
                matching: components,
                matchingPolicy: .nextTime
            ) { date, error, stop in
                guard let date = date else {print(error); return}
                guard date < dateInterval.end else {stop = true; return}
                dates.append(date)
            }
            return dates
        }
        
        func dateRange(for date: Date) -> DateInterval {
            guard let range = Calendar.dateInterval(Calendar.current)(of: .month, for: date),
                  let monthFirstWeek = Calendar.dateInterval(Calendar.current)(of: .weekOfMonth, for: range.start),
                  let monthLastWeek = Calendar.dateInterval(Calendar.current)(of: .weekOfMonth, for: range.end - 1)
            else {return DateInterval()}
            return DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        }
    }
}

#Preview {
    struct Preview: View {
        var body: some View {
            MoonPhaseTileView()
                .foregroundStyle(.white)
                .padding()
        }
    }
    return Preview()
}

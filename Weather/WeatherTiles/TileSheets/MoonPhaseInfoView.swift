//
//  MoonPhaseInfoView.swift
//  Weather
//
//  Created by Anthony Polka on 10/15/24.
//

import SwiftUI
import TinyMoon

struct MoonPhaseInfoView: View {
    
    private let model: MoonPhaseTileView.Model
    private let weekDays =  ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @State private var selectedDate = Date()
    @State private var selectedMoon = TinyMoon.calculateExactMoonPhase(Date())
    @State private var selectedMonth = 0
    func apply<V:View> (@ViewBuilder _ block: (Self) -> V) -> V {block(self)}
    
    init(model: MoonPhaseTileView.Model) {
        self.model = model
    }
    
    var body: some View {
        GeometryReader { outer in
            VStack {
                // MARK: Close button
                Button() { model.isPresented = false
                } label: {
                    Image(systemName: "x.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundStyle(.white)
                }
                
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()

                if let date = Calendar.current.date(byAdding: .month, value: selectedMonth, to: Date.now) {
                    
                    // MARK: Moon emoji
                    
                    Text(selectedMoon.name)
                        .font(.title)
                    Text(selectedDate.formatted(.dateTime.day().month().year()))
                    Text(selectedMoon.emoji)
                        .font(.system(size: 150))
                        .padding()
                   
                    // MARK: Month year
                    HStack {
                        Button() {selectedMonth -= 1
                        } label: {Image(systemName: "chevron.left")}
                        Text("\(date.formatted(.dateTime.month(.wide))) \(date.formatted(.dateTime.year()))")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                        Button {selectedMonth += 1
                        } label: {Image(systemName: "chevron.right")}
                    }
                    .padding()
                    
                    VStack {
                        // MARK: Week days
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                            ForEach(weekDays, id: \.self) { day in
                                Text(day)
                            }
                        }
                        
                        // MARK: Days
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                            ForEach(model.generateDays(for: model.dateRange(for: date)), id: \.self) { cDate in
                                Button {selectedMoon = TinyMoon.calculateExactMoonPhase(cDate)
                                    selectedDate = cDate
                                } label: {
                                    ZStack {
                                        if Calendar.current.isDate(cDate, equalTo: date, toGranularity: .month) {
                                            if Calendar.current.isDate(cDate, equalTo: selectedDate, toGranularity: .day) {
                                                RoundedRectangle(cornerRadius: 10).fill(.blue)
                                                    .scaledToFit()
                                                    .opacity(0.5)
                                            } else {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .scaledToFit()
                                                    .opacity(0.1)
                                            }
                                            VStack {
                                                if Calendar.current.isDate(cDate, equalTo: Date(), toGranularity: .day) {
                                                    Text("\(cDate.formatted(.dateTime.day()))")
                                                        .foregroundStyle(.red)
                                                } else {
                                                    Text("\(cDate.formatted(.dateTime.day()))")
                                                }
                                                
                                                Image(systemName: model.getMoonPhase(from: cDate))
                                            }
                                        }
                                    }
                                }.buttonStyle(.plain)
                            }
                        }
                    }.padding()
                }
            }
        }
    }
}




#Preview {
    struct Preview: View {
        @State var model = MoonPhaseTileView.Model()
        var body: some View {
            MoonPhaseInfoView(model: model)
        }
    }
    return Preview()
}

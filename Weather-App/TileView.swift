//
//  TileView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/28/24.
//


import SwiftUI



protocol Tile {
    var symbol: String {get set}
    var title: String { get set }
    var data: Currently {get set}
}


extension TileView {
    
    @Observable
    class ViewModel: Tile {
        
        var symbol: String
        var title: String
        var data: Currently
        var colors: [Color?] = [nil, nil, nil]
        
        init(symbol: String, title: String, data: Currently, colors: [Color?] = [nil,nil,nil]) {
            self.symbol = symbol
            self.title = title
            self.data = data
            self.colors = colors
        }
    }
}

struct TileView: View {
    
    @State var viewModel: ViewModel
    @Environment(Style.self) var style
    
    init(symbol: String, title: String, data: Currently, colors: [Color?] = [nil,nil,nil]) {
        self.viewModel = ViewModel(symbol: symbol, title: title, data: data, colors: colors)
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .opacity(0.1)
                .blur(radius: 1)
                .scaledToFill()
            VStack(alignment: .leading, spacing: 10) {
                HStack {

                    Image(systemName: viewModel.symbol)
                        .foregroundStyle(viewModel.colors[0] ?? .white,
                                         viewModel.colors[1] ?? .white,
                                         viewModel.colors[2] ?? .white)
                    Text(viewModel.title)
                }
                .font(.title3)
                
                Text("\(Int(viewModel.data.humidity * 100))%")
                    .frame(maxWidth: .infinity)
                    .font(.title)
                Spacer()
            }
            .foregroundStyle(style.fontColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }
}

#Preview {
    struct Preview: View {
        @State var weatherData: WeatherData?
        var body: some View {
            ZStack {
                if let currently = weatherData?.currently {
                    TileView(symbol: "humidity.fill",
                             title: "Humidity",
                             data: currently,
                             colors: [.blue, .white, nil])
                        .frame(width: 150, height: 150)
                        .environment(Style())
                }
            }
            .task {
                weatherData = readUserFromBundle(fileName: "Houston")
            }
        }
    }
    return Preview()
}

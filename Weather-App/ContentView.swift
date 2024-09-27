//
//  ContentView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State var viewModel = ViewModel()
    @StateObject var search = Search()
    @Environment(\.modelContext) private var modelContext
    @Query private var locations: [Location]
    @State var dummyData: WeatherData?
    
    var body: some View {
        NavigationStack {
            List {
                
                ForEach(locations, id: \.self) { location in
                    SavedLocationView(weatherData: Bindable(location).weatherData,
                                      title: location.title,
                                      subtitle: location.subtitle)
                }
                
                SavedLocationView(weatherData: $dummyData, title: "Jefferson City, MO", subtitle: "Missouri, United States")
                    .listRowSeparator(.hidden)
                    .font(.system(size: 15))
                    .frame(height: 100)
                    .task {
                        dummyData = readUserFromBundle(fileName: "JeffersonCity")
                    }
            }
            .listStyle(.plain)
            .searchable(text: $search.searchableText, placement: .navigationBarDrawer(displayMode: .always)) {
                ForEach(search.results, id: \.self) { location in
                    Button {
                        
                    } label: {
                        VStack(alignment: .leading) {
                            Text(location.title)
                            Text(location.subtitle)
                        }
                    }.buttonStyle(.plain)
                }
            }
        }
    }
}


extension ContentView {
    @Observable
    class ViewModel {
        var selection: Location?
        
        func locationSelect (address: AddressResult) {
            getCoordinateFrom(address: address.title) { coordinate, error in
                guard let latitude = coordinate?.latitude else {return}
                guard let longitude = coordinate?.longitude else {return}
                self.selection = Location(title: address.title,
                                          subtitle: address.subtitle,
                                          lat: latitude,
                                          lon: longitude,
                                          weatherData: nil)
                Task {
                    await fetchData(lat: latitude, lon: longitude) { data in
                        self.selection?.weatherData = data
                    }
                }
            }
        }
    }
}



#Preview {
    ContentView()
        .modelContainer(for: Location.self, inMemory: true)
}

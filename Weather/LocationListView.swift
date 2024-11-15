//
//  LocationListView2.swift
//  Weather
//
//  Created by Anthony Polka on 11/14/24.
//

import SwiftUI
import SwiftData
import CoreLocation


struct LocationListView: View {
    
    @Environment(Units.self) var units
    @Environment(\.modelContext) var modelContext
    @Query(sort: \DataModel.listIndex) var savedData: [DataModel]

    @State private var model = ViewModel()
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                List {
                    ForEach(savedData) { data in
                        SavedLocationItemView(for: data.id)
                            .frame(height: 100)
                            .environment(units)
                            .modelContext(modelContext)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    modelContext.delete(data)
                                    try? modelContext.save()
                                } label: {
                                    Label("delete", systemImage: "trash")
                                }
                            }
                    }
                    .onMove(perform: move)
                }
                .listRowSpacing(25)
                .listStyle(.insetGrouped)
                .searchable(text: $model.search.text,
                            isPresented: $model.searchFocused,
                            placement: .navigationBarDrawer(displayMode: .always))
                
                if model.searchFocused {
                    List(model.search.results) { result in
                        Button{
                            model.isPresented = true
                            model.getLocationInfo(for: result.title)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(result.title)
                                    .fontWeight(.heavy)
                                Text(result.subTitle)
                                    .fontWeight(.light)
                            }
                            .foregroundStyle(.white)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .sheet(isPresented: $model.isPresented, onDismiss: model.onDismiss, content: sheetView)
    }
}

extension LocationListView {
    
    @ViewBuilder
    func sheetView () -> some View {
        if let location = model.selectedLocation {
            ZStack(alignment: .top) {
                WeatherView(for: location)
                    .environment(self.units)
                HStack {
                    if !savedData.contains(where: {$0.location == location.location}) {
                        Button {
                            modelContext.insert(location)
                            model.isPresented = false
                            model.searchFocused = false
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    Spacer()
                    Button {
                        self.model.isPresented = false
                    } label: {
                        Image(systemName: "x.circle.fill")
                    }
                }
                .font(.title)
                .padding()
            }
        }
    }
}


extension LocationListView {
    
    func move(from source: IndexSet, to destination: Int) {
        var temp = savedData
        temp.move(fromOffsets: source, toOffset: destination)
        for (index, item) in temp.enumerated() {
            item.listIndex = index
        }
        try? modelContext.save()
    }
}

extension LocationListView {
    @Observable
    class ViewModel {
        var search = Search()
        var searchFocused = false
        var selectedLocation: DataModel?
        var isPresented: Bool = false
        
        
        func onDismiss() {
            isPresented = false
        }
        
        func getLocationInfo(for selectionTitle: String) {
            getCoords(from: selectionTitle) {
                
                let selectedLocation = LocationModel(locality: $0,
                                                    administrativeArea: $1,
                                                    subAdministrativeArea: $2,
                                                    coordinates: $3)
                Task {
                    await fetchData(lat: selectedLocation.lat, lon: selectedLocation.lon) {data in
                        guard let data else {return}
                        self.selectedLocation = DataModel(location: selectedLocation,
                                                          weatherData: data,
                                                          listIndex: 0)
                        
                        
                    }
                }
            }
        }
        
    }
}

#Preview {
    LocationListViewPreview(fileName: "NewYorkCity", cityName: "New York City", adminArea: "NY")
        .modelContainer(for: DataModel.self, inMemory: true)
}


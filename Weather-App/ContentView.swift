//
//  ContentView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import SwiftUI
import SwiftData


enum TempUnits: Hashable {
    case fahrenheit
    case celsius
}


@Observable
class Units {
    var temp: TempUnits = .fahrenheit
}


extension ContentView {
    
    @Observable
    class ViewModel {
        var currentSelection: AddressResult?
        var currentData: WeatherData? = nil
        var present = false
        var textPresent = false
        var showCancelButton = false
        var showPlaceholder = true
        var blurEnabled = false
        var isEditing: EditMode = .inactive
        var units = Units()
        
        func dissmissSheet() {
            currentData = nil
            currentSelection = nil
        }
        
        func searchSelect(location: AddressResult) {
            getCoordinateFrom(address: location.title) { coordinate, error in
                guard let coords = coordinate else {print(error ?? ""); return}
                self.currentSelection = location
                self.currentSelection?.latitude = coords.latitude
                self.currentSelection?.longitude = coords.longitude
                Task {
                    await fetchData(lat: coordinate?.latitude ?? 0.0,
                                    lon: coordinate?.longitude ?? 0.0) { data in
                        self.currentData = data
                        self.present = true
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext)  var modelContext
    @Environment(\.editMode) var editMode
    @Query  var locations: [Location]
    @State var viewModel = ViewModel()
    @StateObject  var search = Search()
    @FocusState  var searchFocused: Bool
    var body: some View {
        
        
        NavigationView {
            VStack {
                searchBar()
                ZStack {
                    savedLocations()
                        .blur(radius: viewModel.blurEnabled ? 20 : 0)
                    if searchFocused {
                        ZStack {
                            List {
                                ForEach(search.results, id: \.self) { location in
                                    Button {
                                        searchFocused = false
                                        viewModel.searchSelect(location: location)
                                    }
                                    label: {
                                        VStack(alignment: .leading) {
                                            Text(location.title)
                                                .fontWeight(.bold)
                                            Text(location.subtitle)
                                        }
                                    }
                                }
                                .listRowBackground(Color.white.opacity(0.09))
                            }
                            .scrollContentBackground(.hidden)
                            .listStyle(.plain)
                            .scrollIndicators(.hidden)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.present, onDismiss: {viewModel.dissmissSheet()}) {
            WeatherView (weatherData: $viewModel.currentData, title: viewModel.currentSelection?.title ?? "")
                .overlay {sheetOverlay()}
        }
        .onChange(of: search.text) {
            viewModel.showPlaceholder = search.text.isEmpty ? true : false
        }
        .onChange(of: searchFocused) {
            
            withAnimation {
                viewModel.showCancelButton = searchFocused
                viewModel.blurEnabled = searchFocused
            }
        }
    }
    
    @ViewBuilder
    func searchBar() -> some View {
        
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("", text: $search.text)
                    .focused($searchFocused)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .leading) {
                        if viewModel.showPlaceholder {
                            Text("Search").opacity(0.5)
                        }
                    }
                if !viewModel.showPlaceholder {
                    Button {
                        search.text = ""
                        viewModel.showPlaceholder = true
                    }label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding(5)
            .background(.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            .onTapGesture {
                withAnimation {
                    searchFocused = true
                    viewModel.blurEnabled = true
                    viewModel.showCancelButton = true
                }
            }
            
            if viewModel.showCancelButton {
                Button("Cancel") {
                    searchFocused = false
                    search.text = ""
                    withAnimation {viewModel.showCancelButton = false}
                }
                .padding(.trailing)
                .transition(.move(edge: .trailing))
            }
        }
    }
    
    @ViewBuilder
    func sheetOverlay () -> some View {
        VStack {
            HStack {
                Button ("Cancel"){
                    viewModel.present = false
                    searchFocused = true
                }
                .padding()
                Spacer()
                Button ("Add") {
                    if let selection = viewModel.currentSelection {
                        modelContext.insert(Location(title: selection.title,
                                                     subtitle: selection.subtitle,
                                                     lat: selection.latitude!,
                                                     lon: selection.longitude!,
                                                     weatherData: viewModel.currentData))
                    }
                    search.text = ""
                    viewModel.present = false
                }
                .padding()
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    func savedLocations() -> some View {
        List {
            ForEach(locations, id: \.self) { location in
                SavedLocationView(location: location)
                    .listRowBackground(Color(UIColor.secondarySystemGroupedBackground).opacity(0))
                    .listRowSeparator(.hidden)
                    .font(.system(size: 15))
                    .frame(height: 100)
            }.onDelete {set in
                _ = set.map{
                    modelContext.delete(locations[$0])
                }
            }
        }
        .environment(\.editMode, $viewModel.isEditing)
        .listStyle(.plain)
        .toolbar {
            if viewModel.isEditing == .active {
                Button("Done") {withAnimation {viewModel.isEditing = .inactive}}
            } else {
                Menu {
                    Button("Edit", action: {withAnimation {self.viewModel.isEditing = .active}})
                    Picker(selection: $viewModel.units.temp) {
                        Text("Fahrenheit").tag(TempUnits.fahrenheit)
                        Text("Celsius").tag(TempUnits.celsius)
                    } label: {
                        
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Location.self, inMemory: true)
}

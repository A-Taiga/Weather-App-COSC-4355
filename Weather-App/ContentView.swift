//
//  ContentView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import SwiftUI
import SwiftData



struct ContentView: View {
    
    @Environment(\.modelContext)  var modelContext
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
                .environment(viewModel.units)
                .overlay {sheetOverlay()}
        }
        .sheet(isPresented: $viewModel.unitsSelectted) {
            VStack {
                HStack {
                    Spacer()
                        .frame(maxWidth: .infinity)
                    Text("Units")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                    Button("Done") {
                        viewModel.unitsSelectted = false
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.plain)
                    .fontWeight(.bold)
                }
                .padding(.top)
                UnitsView(units: $viewModel.units)
            }
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
                }.foregroundStyle(.white).font(.title3).fontWeight(.heavy).shadow(radius: 10)
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
                .foregroundStyle(.white).font(.title3).fontWeight(.heavy).shadow(radius: 10)
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    func savedLocations() -> some View {
        List {
            ForEach(locations, id: \.self) { location in
                SavedLocationView(location: location)
                    .environment(viewModel.units)
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
                        Text("Fahrenheit").tag(UnitsTemp.fahrenheit)
                        Text("Celsius").tag(UnitsTemp.celsius)
                    } label: {}
                    Button("Units") {viewModel.unitsSelectted = true}
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                }
            }
        }
    }
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
        var unitsSelectted = false
        
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

#Preview {
    struct Preview: View {
        var body: some View {
            ContentView()
                .modelContainer(for: Location.self, inMemory: true)
        }
    }
    return Preview()
}

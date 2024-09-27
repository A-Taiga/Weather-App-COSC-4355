//
//  ContentView.swift
//  Weather-App
//
//  Created by Anthony Polka on 9/27/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @StateObject var search = Search()
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationStack {
            List {
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

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

//
//  ContentView.swift
//  Weather
//
//  Created by Anthony Polka on 10/14/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var model = Model()
    @Environment(\.modelContext) private var modelContext
    @Query private var savedData: [DataModel]
    
    var body: some View {
        NavigationStack {
            List(savedData) { data in
                
            }
        }
    }
}

extension ContentView {
    @Observable
    class Model {
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

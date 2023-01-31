//
//  ContentView.swift
//  Pesapal
//
//  Created by Ian on 30/01/2023.
//

import SwiftUI
import Swifter

struct ContentView: View {
    @EnvironmentObject private var server: Server
    @StateObject private var problem3ViewModel: Problem3ViewModel = Problem3ViewModel()
    @StateObject private var problem4ViewModel: Problem4ViewModel = Problem4ViewModel()
    @State private var selection: Int?
    
    var body: some View {
        NavigationView {
            List(selection: $selection) {
                NavigationLink("Problem 3", destination: Problem3())
                    .tag(1)
                NavigationLink("Problem 4", destination: Problem4())
                    .tag(2)
            }
            .listStyle(.sidebar)
            .navigationTitle("Pesapal Dev")
            #if os(macOS)
            Problem3()
            #endif
        }
        .environmentObject(problem3ViewModel)
        .environmentObject(problem4ViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

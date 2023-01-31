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
    @StateObject private var appService: AppService = AppService()
    @SceneStorage("ContentView.selection") private var selection: Int?
    
    var body: some View {
        NavigationView {
            List(selection: $selection) {
                NavigationLink("Problem 3", destination: Problem3())
                    .tag(1)
                NavigationLink("Problem 4", destination: Problem4())
                    .tag(2)
            }
            .listStyle(.sidebar)
            Problem3()
        }
        .environmentObject(appService)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

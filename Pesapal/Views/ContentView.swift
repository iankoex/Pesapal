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
    
    var body: some View {
        VStack {
            if server.isRunning {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .padding()
                Text("Server is running on port: \(server.port)")
                Link("Test on Browser", destination: URL(string: "http://localhost:8080")!)
            } else {
                Button("Start Server") {
                    server.start()
                }
            }
            
            Button("Connect to WS Server") {
                appService.connectToWebSocket()
            }
            
            Button("sendCommand") {
                appService.sendCommand()
            }
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

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
        HStack {
            Spacer()
            serverView
            Spacer()
            Divider()
            Spacer()
            socketView
            Spacer()
        }
        .frame(minWidth: 600, minHeight: 400)
        .navigationTitle(appService.participant?.name ?? "Pesapal Dev Challenge")
    }
    
    var serverView: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Server")
                .font(.title)
            if server.isRunning {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                Text("Server is running on port: \(server.port)")
                if let serverURL = URL(string: "http://localhost:8080") {
                    Link("Test on Browser", destination: serverURL)
                }
            } else {
                Button(action: server.start) {
                    Text("Start Server")
                }
            }
        }
    }
    
    var socketView: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Socket")
                .font(.title)
            Image(systemName: "bolt.circle")
                .font(.largeTitle)
                .foregroundColor(appService.isConnected ? .green : .red)
            
            Text(appService.isConnected ? "Connected" : "Disconnected")
            
            if let part = appService.participant {
                Text("Name: \(part.name), Rank: \(part.rank)")
            }
            
            HStack {
                Button(action: appService.connectToWebSocket) {
                    Text("Connect to Socket")
                }
                
                Button(role: .destructive, action: appService.disconnectFromWebSocket) {
                    Text("Disconnect")
                }
                .disabled(!appService.isConnected)
            }
            
            Button(action: appService.sendCommand) {
                Text("Send Command")
            }
            .disabled(!appService.isConnected)
            
            if appService.isShowingCommand {
                Text("Excecuting Command from")
                Text(appService.commandMessage)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

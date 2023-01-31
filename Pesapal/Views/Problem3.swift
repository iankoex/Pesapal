//
//  Problem3.swift
//  Pesapal
//
//  Created by Ian on 31/01/2023.
//

import SwiftUI

struct Problem3: View {
    @EnvironmentObject private var server: Server
    @EnvironmentObject private var appService: AppService
    
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
        .buttonStyle(.link)
        .frame(minWidth: 600, minHeight: 400)
        .navigationTitle(appService.participant?.name ?? "Problem 3: A distributed system")
        .onReceive(server.$isRunning) { isRunning in
            if isRunning { appService.connectToWebSocket() }
        }
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
                Button(action: server.stop) {
                    Text("Stop Server")
                }
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
                .imageScale(.large)
                .font(.largeTitle)
                .foregroundColor(appService.isConnected ? .green : .red)
            
            if appService.isConnected {
                HStack {
                    Text("Connected")
                    if let part = appService.participant {
                        Text("Name: \(part.name), Rank: \(part.rank)")
                    }
                }
            } else {
                Text("Disconnected")
            }
            
            if appService.isConnected {
                Button(role: .destructive, action: appService.disconnectFromWebSocket) {
                    Text("Disconnect")
                }
                
                Button(action: appService.sendCommand) {
                    Text("Send Command")
                }
            } else {
                Button(action: appService.connectToWebSocket) {
                    Text("Connect to Socket")
                }
                .disabled(!server.isRunning)
            }
            
            if appService.isShowingCommand {
                Text("Excecuting Command from")
                Text(appService.commandMessage)
            }
        }
    }
}

struct Problem3_Previews: PreviewProvider {
    static var previews: some View {
        Problem3()
    }
}

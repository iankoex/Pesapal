//
//  Problem3.swift
//  Pesapal
//
//  Created by Ian on 31/01/2023.
//

import SwiftUI

struct Problem3: View {
    @EnvironmentObject private var server: Server
    @EnvironmentObject private var problem3ViewModel: Problem3ViewModel
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var hSizeClass
    #endif
    
    var body: some View {
        Group {
            #if os(iOS)
            if hSizeClass == .regular {
                iPadOSmacOSView // iPad
            } else {
                iOSView
            }
            #elseif os(macOS)
            iPadOSmacOSView
                .buttonStyle(.link)
                .frame(minWidth: 600, minHeight: 400)
            #endif
        }
        .onReceive(server.$isRunning) { isRunning in
            if isRunning { problem3ViewModel.connectToWebSocket() }
        }
    }
    
    private var iPadOSmacOSView: some View {
        HStack {
            Spacer()
            serverView
            Spacer()
            Divider()
            Spacer()
            socketView
            Spacer()
        }
        .navigationTitle(problem3ViewModel.participant?.name ?? "Problem 3: A distributed system")
    }
    
    var iOSView: some View {
        ScrollView {
            VStack {
                serverView
                Divider()
                socketView
                Divider()
                Group {
                    Text("You can't open two instances of the same app on iOS. ") +
                    Text("Therefore, we can't solve the problem here. ") +
                    Text("However on iPadOS and macOS, ") +
                    Text("we can have multiple windows open.")
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(problem3ViewModel.participant?.name ?? "A distributed system")
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
                .foregroundColor(problem3ViewModel.isConnected ? .green : .red)
            
            if problem3ViewModel.isConnected {
                HStack {
                    Text("Connected")
                    if let part = problem3ViewModel.participant {
                        Text("Name: \(part.name), Rank: \(part.rank)")
                    }
                }
            } else {
                Text("Disconnected")
            }
            
            if problem3ViewModel.isConnected {
                Button(action: problem3ViewModel.disconnectFromWebSocket) {
                    Text("Disconnect")
                }
                .foregroundColor(.red)
                
                Button(action: problem3ViewModel.sendCommand) {
                    Text("Send Command")
                }
            } else {
                Button(action: problem3ViewModel.connectToWebSocket) {
                    Text("Connect to Socket")
                }
                .disabled(!server.isRunning)
            }
            
            if problem3ViewModel.isShowingCommand {
                Text("Excecuting Command from")
                Text(problem3ViewModel.commandMessage)
            }
        }
    }
}

struct Problem3_Previews: PreviewProvider {
    static var previews: some View {
        Problem3()
            .environmentObject(Problem3ViewModel())
    }
}

//
//  AppService.swift
//  Pesapal
//
//  Created by Ian on 30/01/2023.
//

import Foundation

class AppService: ObservableObject {
    @Published var webSocket: WebSocket = WebSocket()
    @Published var participant: Participant?
    
    func connectToWebSocket() {
        Task {
            await webSocket.connect()
        }
    }
    
    func sendCommand() {
        Task {
            await webSocket.send(Message(participant: Participant(id: UUID(), name: "adad", rank: 1000), type: .command))
        }
    }
}

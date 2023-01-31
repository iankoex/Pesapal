//
//  AppService.swift
//  Pesapal
//
//  Created by Ian on 30/01/2023.
//

import Foundation
import Combine
import SwiftUI

class AppService: ObservableObject {
    @Published private var webSocket: WebSocket = WebSocket()
    @Published var participant: Participant?
    private var cancellables: [AnyCancellable] = []
    
    init() {
        webSocket.objectWillChange.sink { _ in
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        .store(in: &cancellables)
        
        webSocket.$message.sink { msg in
            self.processIncommingMessage(msg)
        }
        .store(in: &cancellables)
    }
    
    var isConnected: Bool {
        withAnimation(.easeInOut) {
            webSocket.isConnected
        }
    }
    
    func connectToWebSocket() {
        Task {
            await webSocket.connect()
        }
    }
    
    func disconnectFromWebSocket() {
        withAnimation(.easeInOut) {
            participant = nil
        }
        webSocket.disconnect()
    }
    
    func sendCommand() {
        Task {
            await webSocket.send(Message(participant: Participant(rank: 1000), type: .command))
        }
    }
    
    private func processIncommingMessage(_ msg: Message?) {
        guard let msg = msg else {
            return
        }
        switch msg.type {
            case .command:
                print("Command")
            case .update:
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.participant = msg.participant
                    }
                }
        }
    }
}

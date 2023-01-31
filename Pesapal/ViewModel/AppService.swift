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
    @Published var commandMessage: String = ""
    @Published var isShowingCommand: Bool = false
    private var timer: Timer?
    private var cancellables: [AnyCancellable] = []
    
    init() {
        webSocket.objectWillChange.sink { _ in
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        .store(in: &cancellables)
        
        webSocket.$message
            .dropFirst()
            .sink { msg in
                self.processIncommingMessage(msg)
            }
            .store(in: &cancellables)
        
        $isShowingCommand
            .dropFirst()
            .sink { _ in
                self.scheduleTimer()
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
            guard let part = participant else {
                return
            }
            await webSocket.send(Message(participant: part, type: .command))
        }
    }
    
    private func processIncommingMessage(_ msg: Message?) {
        guard let msg = msg else {
            return
        }
        switch msg.type {
            case .command:
                showCommand(msg)
            case .update:
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.participant = msg.participant
                    }
                }
        }
    }
    
    private func showCommand(_ msg: Message) {
        let commandStr = "\(msg.participant.name) with rank \(msg.participant.rank)"
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.commandMessage = commandStr
                self.isShowingCommand = true
            }
        }
    }
    
    private func scheduleTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self.commandMessage = ""
                    self.isShowingCommand = false
                }
            }
        }
    }
}

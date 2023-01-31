//
//  WebSocket.swift
//  Pesapal
//
//  Created by Ian on 30/01/2023.
//

import Foundation

class WebSocket: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    private var websocket: URLSessionWebSocketTask?
    var keepListening = true
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    @Published var isConnected: Bool = false
    @Published var message: Message? = nil
    
    func connect() async {
        guard let resourceURL = URL(string: "http://localhost:8080/socket") else {
            return
        }
        let urlRequest = URLRequest(url: resourceURL)
        websocket = session.webSocketTask(with: urlRequest)
        listen()
        
        websocket?.resume()
    }
    
    func listen() {
        websocket?.receive(completionHandler: { [weak self] result in
            switch result {
                case let .success(raw):
                    self?.on(msg: raw)
                    if self?.keepListening == true {
                        self?.listen()
                    }
                case let .failure(err):
                    print("WebSocket Failure: \(err.localizedDescription)")
                    self?.websocket = nil
                    // try self?.connect()
            }
        })
    }
    
    private func on(msg: URLSessionWebSocketTask.Message) {
        switch msg {
            case let .string(str):
                recievedString(str)
            case .data:
                print("Some data Recieved")
            @unknown default:
                print("Some Unknown Default: from WebSocket")
        }
    }
    
    private func recievedString(_ str: String) {
        guard let data = str.data(using: .utf8) else {
            return
        }
        do {
            let msg = try self.decoder.decode(Message.self, from: data)
            self.message = msg
        } catch {
            print("WebSocket: \(error.localizedDescription)")
        }
    }
    
    func send(_ msg: Message) async {
        guard
            let data = try? encoder.encode(msg),
            let msgString = String(data: data, encoding: .utf8)
        else {
            return
        }
        do {
            try await websocket?.send(.string(msgString))
        } catch {
            print("WebSocket Send Error: \(error.localizedDescription)")
        }
    }
    
    func disconnect() {
        websocket?.cancel(with: .goingAway, reason: nil)
        websocket = nil
    }
    
    deinit {
        websocket?.cancel()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected = true
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
    }
}

//
//  WebSocket.swift
//  Pesapal
//
//  Created by Ian on 30/01/2023.
//

import Foundation
import Combine

class WebSocket: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    private var websocket: URLSessionWebSocketTask?
    var keepListening = true
    private var cancellables: [AnyCancellable] = []
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    @Published var isConnected: Bool = false
    @Published var str: String = "" // what is Recieved from server
    
    override init() {
        super.init()
        $str
            .dropFirst()
            .sink(receiveValue: { txt in
                do {
                    print("TXT", txt)
                    let data = txt.data(using: .utf8)
                    if let data = data {
                        let msg = try self.decoder.decode(Message.self, from: data)
                        print("Recived", msg)
//                        self.msg = msg
                    }
                } catch {
                    print("WebSocket: \(error.localizedDescription)")
                }
            })
            .store(in: &cancellables)
    }
    
    func connect() async {
        let resourceURL = URL(string: "http://localhost:8080/ws")!
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
                    print("WebSocket \(err.localizedDescription)")
                    self?.websocket = nil
                    // try self?.connect()
            }
        })
    }
    
    private func on(msg: URLSessionWebSocketTask.Message) {
        switch msg {
            case let .string(strr):
                str = strr
            case .data:
                print("Some data Recieved")
            @unknown default:
                print("Some Unknown Default: from WebSocket")
        }
    }
    
    func send(_ msg: Message) async {
        do {
            let data = try encoder.encode(msg)
            let msgString = data.base64EncodedString()
            try await websocket?.send(.string(msgString))
        } catch {
            print("cws Send Error \(error.localizedDescription)")
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
        print("Connected to cws")
        isConnected = true
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Disconnected from cws")
        isConnected = false
    }
}

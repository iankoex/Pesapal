//
//  Server.swift
//  Pesapal
//
//  Created by Ian on 30/01/2023.
//

import Foundation
import Swifter

final class Server: ObservableObject {
    let server: HttpServer = HttpServer()
    @Published var isRunning: Bool = false
    private var participants: [WebSocketSession: ActiveSession] = [:]
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    init() {
        self.start()
    }
    
    var port: Int {
        let port = try? server.port()
        return port ?? 0
    }
    
    private func configureRoutes() {
        server["/"] = scopes {
            html {
                body {
                    center {
                        h1 {
                            inner = "Hello There :)"
                        }
                        p {
                            inner = "This is a Swift Web Server"
                        }
                        img {
                            src = "https://swift.org/assets/images/swift.svg"
                        }
                    }
                }
            }
        }
        
        server["/ws"] = websocket(
            text: processIncomingText(session:text:),
            connected: participantConneted(session:),
            disconnected: participantDisconnected(session:)
        )
    }
    
    func start() {
        Task(priority: .background) {
            configureRoutes()
            do {
                try server.start(8080)
                await MainActor.run {
                    isRunning = server.operating
                }
                print("Server has started on port: \(try server.port())")
            } catch {
                print("Failed to Start Server:", error.localizedDescription)
            }
        }
    }
    
    private func processIncomingText(session: WebSocketSession, text: String) {
        print("Server", text, session.hashValue)
    }
    
    private func participantConneted(session: WebSocketSession) {
        print("Participant connected ", participants.count, session.hashValue)
        let participant = Participant(rank: participants.count)
        let activeSession = ActiveSession(ws: session, participant: participant)
        participants[session] = activeSession
        let msg = Message(participant: participant, type: .update)
        activeSession.ws.sendMessage(msg)
    }
    
    private func participantDisconnected(session: WebSocketSession) {
        print("Participant Discoonnected ", session.hashValue)
        guard let leavingSession = participants[session] else {
            return
        }
        let lowerRankParticipants = participants.filter {
            $0.value.participant.rank > leavingSession.participant.rank
        }
        lowerRankParticipants.values.forEach { value in
            guard let activeSession = participants[value.ws] else {
                return
            }
            var part = activeSession.participant
            part.rank -= 1
            let updatedSession = ActiveSession(ws: activeSession.ws, participant: part)
            participants[updatedSession.ws] = updatedSession
            let msg = Message(participant: updatedSession.participant, type: .update)
            updatedSession.ws.sendMessage(msg)
        }
        participants[session] = nil
    }
    
    private func notifyAllThatNewParticpantHasJoined(_ part: Participant) {
        let msg = Message(participant: part, type: .update)
        participants.values.forEach { activeSession in
            activeSession.ws.sendMessage(msg)
        }
    }
}

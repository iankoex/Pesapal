//
//  Message.swift
//  Pesapal
//
//  Created by Ian on 30/01/2023.
//

import Foundation

struct Message: Codable {
    var participant: Participant
    var type: MessageType
}

extension Message {
    enum MessageType: String, Codable {
        /// Use when client is sending a command to other clients or the clients are recieving commands
        case command
        /// The server will use this to update participants when a client joins in
        case update
    }
}

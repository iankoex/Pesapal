//
//  Participant.swift
//  Pesapal
//
//  Created by Ian on 30/01/2023.
//

import Foundation

struct Participant: Codable {
    var name: String {
        "Participant \(rank)"
    }
    var rank: Int
}

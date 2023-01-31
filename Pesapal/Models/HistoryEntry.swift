//
//  HistoryEntry.swift
//  Pesapal
//
//  Created by Ian on 31/01/2023.
//

import Foundation

struct HistoryEntry: Identifiable {
    var id = UUID()
    var text: String
    var result: String
}

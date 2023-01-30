//
//  WebSocketSession + Extensions .swift
//  Pesapal
//
//  Created by Ian on 30/01/2023.
//

import Foundation
import Swifter

extension WebSocketSession {
    func sendMessage(_ msg: Message) {
        let encoder = JSONEncoder()
        guard
            let data = try? encoder.encode(msg),
            let str = String(data: data, encoding: .utf8)
        else { return }
        self.writeText(str)
    }
}

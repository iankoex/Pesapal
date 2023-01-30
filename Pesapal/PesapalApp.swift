//
//  PesapalApp.swift
//  Pesapal
//
//  Created by Ian on 30/01/2023.
//

import SwiftUI

@main
struct PesapalApp: App {
    @StateObject var server: Server = Server()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(server)
        }
    }
}

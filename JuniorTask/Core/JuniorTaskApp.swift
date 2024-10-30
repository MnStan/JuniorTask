//
//  JuniorTaskApp.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import SwiftUI

@main
struct JuniorTaskApp: App {
    @StateObject var networkManager = NetworkManager()
    
    var body: some Scene {
        WindowGroup {
            MainView(networkManager: networkManager)
        }
    }
}

//
//  MainView-ViewModel.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import Foundation

extension MainView {
    @MainActor
    class ViewModel: ObservableObject {
        var networkManager: NetworkManagerProtocol
        
        @Published var events: [EventResponse.Embedded.Event] = []
        @Published var errorMessage: String? = nil
        
        init(networkManager: NetworkManagerProtocol) {
            self.networkManager = networkManager
        }
        
        func fetchEvents() {
            events = []
            errorMessage = nil
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    self.events = try await self.networkManager.getAllEvents()
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

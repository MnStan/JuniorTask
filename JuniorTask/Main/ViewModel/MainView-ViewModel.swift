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
        @Published var isFetching: Bool = false
        
        init(networkManager: NetworkManagerProtocol) {
            self.networkManager = networkManager
        }
        
        func fetchEvents() {
            isFetching = true
            events = []
            errorMessage = nil
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    self.events = try await self.networkManager.getAllEvents()
                } catch {
                    self.errorMessage = error.localizedDescription
                }
                
                isFetching = false
            }
        }
        
        func fetchNextEvents() {
            isFetching = true
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let nextEvents = try await self.networkManager.getNextPage()
                    self.events.append(contentsOf: nextEvents)
                } catch {
                    self.errorMessage = error.localizedDescription
                }
                
                isFetching = false
            }
        }
        
        func canFetchMorePages() -> Bool {
            networkManager.getNextURL() != nil
        }
    }
}

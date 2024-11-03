//
//  DetailsView-ViewModel.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 03/11/2024.
//

import Foundation

extension DetailsView {
    @MainActor
    class ViewModel: ObservableObject {
        var networkManager: NetworkManagerProtocol
        
        @Published var event: DetailEventResponse?
        @Published var errorMessage: String? = nil
        
        init(networkManager: NetworkManagerProtocol) {
            self.networkManager = networkManager
        }
        
        func fetchEventDetails(for event: String) {
            self.event = nil
            errorMessage = nil
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    self.event = try await self.networkManager.getEventDetails(for: event)
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

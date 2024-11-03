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
            fetchEvents()
        }
        
        func fetchEvents(sortOption: SortOption? = nil) {
            isFetching = true
            events = []
            errorMessage = nil
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    self.events = try await self.networkManager.getAllEvents(sortOption: sortOption)
                } catch let error as JTError {
                    self.errorMessage = error.description
                } catch {
                    self.errorMessage = error.localizedDescription
                }
                
                isFetching = false
            }
        }
        
        func fetchAgain() {
            fetchEvents()
        }
        
        func fetchNextEvents() {
            isFetching = true
            
            Task { [weak self] in
                guard let self else { return }
                do {
                    let nextEvents = try await self.networkManager.getNextPage()
                    self.events.append(contentsOf: nextEvents)
                } catch let error as JTError {
                    self.errorMessage = error.description
                } catch {
                    self.errorMessage = error.localizedDescription
                }

                
                isFetching = false
            }
        }
        
        func canFetchMorePages() -> Bool {
            networkManager.getNextURL() != nil
        }
        
        /// Returns the URL for the cover image for MainView of a given event
        /// - Parameter event: The event from which to retrieve an image
        /// - Returns: The URL of the "RECOMMENDATION" image it it exists; otherwise the URL of the smallest available image or nil if there are no images
        func getCoverImage(for event: EventResponse.Embedded.Event) -> URL? {
            guard !event.images.isEmpty else { return nil }
            
            // Attempt to find and return the "RECOMMENDATION" image if it exists
            if let recommendationImage = event.images.first(where: { image in
                image.url.absoluteString.contains("RECOMENDATION")
            })?.url {
                return recommendationImage
            } else {
                // If no "RECOMMENDATION" image exists, sort images by area (width * height) in ascending order
                let imagesArraySorted = event.images.sorted { lhs, rhs in
                    (lhs.width * lhs.height) < (rhs.width * lhs.height)
                }
                
                // Return the URL of the smallest image if one exists after sorting
                if let firstImage = imagesArraySorted.first {
                    return firstImage.url
                }
            }
            
            // Return nil if no image URL was found
            return nil
        }
        
        func convertDate(date: String) -> String? {
            date.convertToCorrectFormat()
        }
    }
}

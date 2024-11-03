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
        @Published var imagesURLs: [URL] = []
        
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
                    getImagesToDisplay()
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        
        func getSeatMapImage() -> URL? {
            return event?.seatmap.staticUrl
        }
        
        func getImagesToDisplay() {
            let groupedImages = groupImages(images: event?.images ?? [])

            for images in groupedImages.values {
                if images.count == 1 {
                    if let firstImage = images.first {
                        imagesURLs.append(firstImage.url)
                    }
                } else if let image = getMostSuitedImageToDisplay(images: images) {
                    imagesURLs.append(image.url)
                }
            }
        }
        
        // Function to group images by their ID's - each ID have multiple images in different resolutions in API return
        func groupImages(images: [EventResponse.Embedded.Event.EventImage]) -> [String: [EventResponse.Embedded.Event.EventImage]] {
            var groupedImages: [String: [EventResponse.Embedded.Event.EventImage]] = [:]
            
            for imageURL in images {
                let stringURL = imageURL.url.absoluteString
                let components = stringURL.split(separator: "/")
                if let lastComponent = components.last?.split(separator: "_").first {
                    let id = String(lastComponent)
                    
                    groupedImages[id, default: []].append(imageURL)
                }
            }
            
            return groupedImages
        }
        
        func getMostSuitedImageToDisplay(images: [EventResponse.Embedded.Event.EventImage]) -> EventResponse.Embedded.Event.EventImage? {
            let retinaImages = images.filter { image in
                image.url.absoluteString.contains("RETINA")
            }
            
            return retinaImages.max(by: { ($0.height * $0.width) < ($1.height * $1.width) })
        }
    }
}

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
        @Published var isLoading = false
        
        init(networkManager: NetworkManagerProtocol) {
            self.networkManager = networkManager
        }
        
        func fetchEventDetails(for event: String) {
            isLoading = true
            self.event = nil
            errorMessage = nil
            imagesURLs = []
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    self.event = try await self.networkManager.getEventDetails(for: event)
                    getImagesToDisplay()
                } catch {
                    self.errorMessage = error.localizedDescription
                }
                
                self.isLoading = false
            }
        }
        
        func getSeatMapImage() -> URL? {
            return event?.seatmap?.staticUrl
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
        
        func getName() -> String? {
            event?.name
        }
        
        func getInformations() -> [(String, String)] {
            var informations: [String: String] = [:]
            
            if let event = event {
                if let classifications = event.classifications.first {
                    informations["igatunek"] = classifications.segment.name
                }
                
                informations["cdata"] = event.dates.start.localDate.convertToCorrectFormat()
                informations["dczas"] = event.dates.start.localTime?.convertTimeToCorrectFormat()
                
                if let venueName = event.embedded.venues.first?.name {
                    informations["gObiekt"] = venueName
                }
                
                if let classification = event.embedded.attractions?.first {
                    informations["bnazwa_zespołu"] = classification.name
                }
                
                if let cityName = event.embedded.venues.first?.city {
                    informations["fmiasto"] = cityName.name
                }
                
                if let countryName = event.embedded.venues.first?.country {
                    informations["ekraj"] = countryName.name
                }
                
                if let venueAddress = event.embedded.venues.first?.address {
                    informations["hadres"] = venueAddress.line1
                }
                
                if let minimumPrice = event.priceRanges?.first {
                    informations["jod:"] = "\(minimumPrice.min) \(minimumPrice.currency)"
                }
                
                
            }
            
            return informations.sorted { $0.key < $1.key }
        }
        
        func getMapURL() -> URL? {
            event?.seatmap?.staticUrl
        }
        
        func prepareKeyToDisplay(to display: String) -> String {
            display.dropFirst().capitalized.replacingOccurrences(of: "_", with: " ")
        }
    }
}

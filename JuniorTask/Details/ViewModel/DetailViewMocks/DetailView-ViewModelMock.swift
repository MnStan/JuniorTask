//
//  DetailView-ViewModelMock.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 03/11/2024.
//
import Foundation

class DetailNetworkManagerMock: NetworkManager {
    override func getNextURL() -> String? {
        nil
    }
    
    override func getAllEvents(_ session: URLSession = URLSession.shared, sortOption: SortOption?) async throws -> [EventResponse.Embedded.Event] {
        
        return []
    }
    
    override func getEventDetails(_ session: URLSession = URLSession.shared, for event: String) async throws -> DetailEventResponse {
        return DetailEventResponse(id: "Z698xZQpZaF52", name: "FREEDOM - In Memory Of George Michael", images: [
            EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "https://s1.ticketm.net/dam/a/c77/1005b91d-943d-42b3-be2d-a652b1583c77_RETINA_PORTRAIT_16_9.jpg")!, width: 640, height: 360),
            EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "https://s1.ticketm.net/dam/a/c77/1005b91d-943d-42b3-be2d-a652b1583c77_TABLET_LANDSCAPE_LARGE_16_9.jpg")!, width: 2048, height: 1152),
            EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "https://s1.ticketm.net/dam/a/c77/1005b91d-943d-42b3-be2d-a652b1583c77_RETINA_PORTRAIT_16_9.jpg")!, width: 640, height: 360),
            EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "https://s1.ticketm.net/dam/a/c77/1005b91d-943d-42b3-be2d-a652b1583c77_RETINA_PORTRAIT_16_9.jpg")!, width: 640, height: 360),
            EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "https://s1.ticketm.net/dam/a/54b/c438d3d8-1d18-4d55-b7cf-a3a3ce2bb54b_1031261_RETINA_LANDSCAPE_16_9.jpg")!, width: 1136, height: 639),
            EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "https://s1.ticketm.net/dam/a/c77/1005b91d-943d-42b3-be2d-a652b1583c77_RETINA_PORTRAIT_16_9.jpg")!, width: 640, height: 360),
            EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "https://s1.ticketm.net/dam/a/c77/1005b91d-943d-42b3-be2d-a652b1583c77_RETINA_PORTRAIT_16_9.jpg")!, width: 640, height: 360),
            EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "https://s1.ticketm.net/dam/a/0ab/3e5c44d2-4c93-45b6-9b2a-4d1d6667a0ab_985031_RETINA_LANDSCAPE_16_9.jpg")!, width: 1136, height: 639),
        ], dates: DetailEventResponse.DetailEventDates(start: DetailEventResponse.DetailEventDates.EventStart(localDate: "2024-11-17", localTime: "19:30:00")), embedded: DetailEventResponse.DetailEventEmbedded(venues: [EventResponse.Embedded.Event.EventEmbedded.Venue(name: "EVA EVENTS", city: EventResponse.Embedded.Event.EventEmbedded.Venue.City(name: "Warszawa"), address: EventResponse.Embedded.Event.EventEmbedded.Venue.Address(line1: "Warszawska 5"), country: EventResponse.Embedded.Event.EventEmbedded.Venue.Country(name: "Polska"))], attractions: [DetailEventResponse.DetailEventEmbedded.Attraction(name: "Imagine Dragons")]), priceRanges: [DetailEventResponse.PriceRange(currency: "PLN", min: 22.32)], classifications: [DetailEventResponse.EventClassification(primary: true, segment: DetailEventResponse.EventClassification.Promoter(id: "id", name: "Music"))], seatmap: DetailEventResponse.SeatMap(id: "id", staticUrl: URL(string: "https://media.ticketmaster.eu/poland/58bafb3115a5ad0f9846c492e160c1b0.png")!))
    }
}

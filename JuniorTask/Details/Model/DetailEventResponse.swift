//
//  DetailEventResponse.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 03/11/2024.
//

import Foundation

struct DetailEventResponse: Decodable {
    let id: String
    let name: String
    let images: [EventResponse.Embedded.Event.EventImage]
    let dates: DetailEventDates
    let embedded: DetailEventEmbedded
    let priceRanges: [PriceRange]?
    let classifications: [EventClassification]
    let seatmap: SeatMap
    
    enum CodingKeys: String, CodingKey {
        case id, name, images, dates, priceRanges, classifications, seatmap
        case embedded = "_embedded"
    }
    
    struct DetailEventEmbedded: Decodable {
        let venues: [EventResponse.Embedded.Event.EventEmbedded.Venue]
        let attractions: [Attraction]?
        
        struct Attraction: Decodable {
            let name: String
        }
    }
    
    struct DetailEventDates: Decodable {
        let start: EventStart
        
        struct EventStart: Decodable {
            let localDate: String
            let localTime: String?
        }
    }
    
    struct PriceRange: Decodable {
        let currency: String
        let min: Double
    }
    
    struct EventClassification: Decodable {
        let primary: Bool
        let segment: Promoter
        
        struct Promoter: Decodable {
            let id: String
            let name: String
        }
    }
    
    struct SeatMap: Decodable {
        let id: String
        let staticUrl: URL
    }
}

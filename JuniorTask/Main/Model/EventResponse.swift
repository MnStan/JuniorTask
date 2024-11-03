//
//  EventResponse.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import Foundation

struct EventResponse: Decodable {
    let embedded: Embedded
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
    }
    
    struct Embedded: Decodable {
        var events: [Event]
        
        struct Event: Decodable {
            let id: String
            let name: String
            let images: [EventImage]
            let dates: EventDates
            let embedded: EventEmbedded
            
            enum CodingKeys: String, CodingKey {
                case id, name, images, dates
                case embedded = "_embedded"
            }
            
            struct EventImage: Decodable {
                let ratio: String?
                let url: URL
                let width: Int
                let height: Int
            }
            
            struct EventDates: Decodable {
                let start: EventStart
                
                struct EventStart: Decodable {
                    let localDate: String
                }
            }
            
            struct EventEmbedded: Decodable {
                let venues: [Venue]
                
                struct Venue: Decodable {
                    let name: String
                    let city: City
                    let address: Address?
                    let country: Country
                    
                    struct City: Decodable {
                        let name: String
                    }
                    
                    struct Address: Decodable {
                        let line1: String
                    }
                    
                    struct Country: Decodable {
                        let name: String
                    }
                }
            }
        }
    }
    
    struct Links: Decodable {
        let next: NextLink?
        
        struct NextLink: Decodable {
            let href: String
        }
    }
}

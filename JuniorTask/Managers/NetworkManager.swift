//
//  NetworkManager.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import Foundation

protocol NetworkManagerProtocol {
    func getAllEvents(_ session: URLSession) async throws -> [EventResponse.Embedded.Event]
}

extension NetworkManagerProtocol {
    func getAllEvents(_ session: URLSession = URLSession.shared) async throws -> [EventResponse.Embedded.Event] {
        return try await getAllEvents(session)
    }
}

class NetworkManager: ObservableObject, NetworkManagerProtocol {
    private var apiKey: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "ticketmaster-info", ofType: "plist") else {
                fatalError("Couldn't find file 'ticketmaster-info.plist'.")
            }
            
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "API_KEY") as? String else {
                fatalError("Couldn't find key 'API_KEY in 'tickemaster-info.plist'.")
            }
            
            return value
        }
    }
    
    private let baseStringURL = "https://app.ticketmaster.com"
    private let allEventsStringURL: String = "/discovery/v2/events.json?countryCode=PL"
    private let apiKeyStringURL: String = "&apikey="
    
    func getAllEvents(_ session: URLSession = URLSession.shared) async throws -> [EventResponse.Embedded.Event] {
        guard let url = URL(string: baseStringURL + allEventsStringURL + apiKeyStringURL + apiKey) else {
            throw JTError.urlError
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                throw JTError.responseError(description: "\(response.statusCode)")
            }
            
            let events = try JSONDecoder().decode(EventResponse.self, from: data)
            
            return events.embedded.events
        } catch let error as JTError {
            throw error
        } catch let urlError as URLError {
            throw JTError.networkError(description: urlError.localizedDescription)
        }
        catch {
            throw JTError.unownedError
        }
    }
}

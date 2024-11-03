//
//  NetworkManager.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import Foundation

protocol NetworkManagerProtocol {
    func getAllEvents(_ session: URLSession, sortOption: SortOption?) async throws -> [EventResponse.Embedded.Event]
    func getNextPage(_ session: URLSession) async throws -> [EventResponse.Embedded.Event]
    func getNextURL() -> String?
    func getEventDetails(_ session: URLSession, for event: String) async throws -> DetailEventResponse
}

extension NetworkManagerProtocol {
    func getAllEvents(_ session: URLSession = URLSession.shared, sortOption: SortOption? = nil) async throws -> [EventResponse.Embedded.Event] {
        do {
            return try await getAllEvents(session, sortOption: sortOption)
        } catch {
            throw error
        }
    }
    
    func getNextPage(_ session: URLSession = URLSession.shared) async throws -> [EventResponse.Embedded.Event] {
        do {
            return try await getNextPage(session)
        } catch {
            throw error
        }
    }
    
    func getEventDetails(_ session: URLSession = URLSession.shared, for event: String) async throws -> DetailEventResponse {
        do {
            return try await getEventDetails(session, for: event)
        } catch {
            throw error
        }
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

    private var urlScheme = "https"
    private var urlHost = "app.ticketmaster.com"
    private var nextPageURL: String? = nil
    private var canFetchMorePages = true
    
    func getAllEvents(_ session: URLSession = URLSession.shared, sortOption: SortOption?) async throws -> [EventResponse.Embedded.Event] {

        var components = URLComponents()
        components.scheme = urlScheme
        components.host = urlHost
        components.path = "/discovery/v2/events.json"
        components.queryItems = [
            URLQueryItem(name: "countryCode", value: "PL"),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        
        if let sortOption = sortOption {
            components.queryItems?.append(URLQueryItem(name: "sort", value: sortOption.rawValue))
        }
            
        guard let url = components.url else {
            throw JTError.urlError
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                throw JTError.responseError(description: "\(response.statusCode)")
            }
            
            let events = try JSONDecoder().decode(EventResponse.self, from: data)
            nextPageURL = events.links.next?.href
            
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
    
    func getNextPage(_ session: URLSession = URLSession.shared) async throws -> [EventResponse.Embedded.Event] {
        guard let nextPageURL else {
            canFetchMorePages = false
            return []
        }
        
        var fullURLString = "\(urlScheme)://\(urlHost)\(nextPageURL)&apikey=\(apiKey)"

        // Check if url contains random sort option if so remove ,asc. It is a bug from API. Api returns nextPageURL with random,asc sort option but that is not valid option
        if fullURLString.contains("random") {
            fullURLString = fullURLString.replacingOccurrences(of: ",asc", with: "")
        }
        
        guard let url = URL(string: fullURLString) else {
            throw JTError.urlError
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                throw JTError.requestFailed(description: "\(response.statusCode)")
            }
            
            let events = try JSONDecoder().decode(EventResponse.self, from: data)
            self.nextPageURL = events.links.next?.href
            
            return events.embedded.events
        }  catch let error as JTError {
            throw error
        } catch let urlError as URLError {
            throw JTError.networkError(description: urlError.localizedDescription)
        }
        catch {
            throw JTError.unownedError
        }
    }
    
    func getNextURL() -> String? {
        nextPageURL
    }
    
    func getEventDetails(_ session: URLSession = URLSession.shared, for event: String) async throws -> DetailEventResponse {
        var components = URLComponents()
        components.scheme = urlScheme
        components.host = urlHost
        components.path = "/discovery/v2/events/\(event).json"
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey)
        ]
            
        guard let url = components.url else {
            throw JTError.urlError
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                throw JTError.requestFailed(description: "\(response.statusCode)")
            }
            
            let eventDetails = try JSONDecoder().decode(DetailEventResponse.self, from: data)
            
            return eventDetails
        }  catch let error as JTError {
            throw error
        } catch let urlError as URLError {
            throw JTError.networkError(description: urlError.localizedDescription)
        }
        catch {
            print(error)
            throw JTError.unownedError
        }
    }
}

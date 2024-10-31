//
//  MainView-ViewModelTests.swift
//  JuniorTaskTests
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import XCTest
@testable import JuniorTask

class NetworkManagerMockWithoutData: NetworkManagerProtocol {
    func getNextURL() -> String? {
        nil
    }
    
    func getAllEvents(_ session: URLSession = URLSession.shared) async throws -> [EventResponse.Embedded.Event] {
        return []
    }
}

class NetworkManagerMockWithData: NetworkManagerProtocol {
    func getNextURL() -> String? {
        "nextPage"
    }
    
    func getAllEvents(_ session: URLSession) async throws -> [EventResponse.Embedded.Event] {
        return [EventResponse.Embedded.Event(id: "1", name: "", images: [EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "www.w.en/2kjfsaldkjf-sadf-asd-fas_ARTIST_PAGE.jpg")!, width: 300, height: 200), EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "www.w.en/2kjfsaldkjf-sadf-asd-asdf_SOURCE.jpg")!, width: 500, height: 700), EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "www.w.en/2kjfsaldkjf-sadf-asd-fas_RECOMENDATION.jpg")!, width: 100, height: 150)], dates: EventResponse.Embedded.Event.EventDates(start: EventResponse.Embedded.Event.EventDates.EventStart(localDate: "")), embedded: EventResponse.Embedded.Event.EventEmbedded(venues: [EventResponse.Embedded.Event.EventEmbedded.Venue(name: "", city: EventResponse.Embedded.Event.EventEmbedded.Venue.City(name: ""), address: EventResponse.Embedded.Event.EventEmbedded.Venue.Address(line1: ""))]))]
    }
    
    func getNextPage(_ session: URLSession) async throws -> [EventResponse.Embedded.Event] {
        return [EventResponse.Embedded.Event(id: "1", name: "", images: [EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "www.w.en")!, width: 150, height: 150)], dates: EventResponse.Embedded.Event.EventDates(start: EventResponse.Embedded.Event.EventDates.EventStart(localDate: "")), embedded: EventResponse.Embedded.Event.EventEmbedded(venues: [EventResponse.Embedded.Event.EventEmbedded.Venue(name: "", city: EventResponse.Embedded.Event.EventEmbedded.Venue.City(name: ""), address: EventResponse.Embedded.Event.EventEmbedded.Venue.Address(line1: ""))]))]
    }
}

class NetworkManagerMockWithDataForImageTest: NetworkManagerProtocol {
    func getNextURL() -> String? {
        "nextPage"
    }
    
    func getAllEvents(_ session: URLSession) async throws -> [EventResponse.Embedded.Event] {
        return [EventResponse.Embedded.Event(id: "1", name: "", images: [EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "www.w.en/2kjfsaldkjf-sadf-asd-fas_ARTIST_PAGE.jpg")!, width: 300, height: 200), EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "www.w.en/2kjfsaldkjf-sadf-asd-asdf_SOURCE.jpg")!, width: 500, height: 700), EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "www.w.en/2kjfsaldkjf-sadf-asd-fas_SMALL.jpg")!, width: 100, height: 150)], dates: EventResponse.Embedded.Event.EventDates(start: EventResponse.Embedded.Event.EventDates.EventStart(localDate: "")), embedded: EventResponse.Embedded.Event.EventEmbedded(venues: [EventResponse.Embedded.Event.EventEmbedded.Venue(name: "", city: EventResponse.Embedded.Event.EventEmbedded.Venue.City(name: ""), address: EventResponse.Embedded.Event.EventEmbedded.Venue.Address(line1: ""))]))]
    }
    
    func getNextPage(_ session: URLSession) async throws -> [EventResponse.Embedded.Event] {
        return [EventResponse.Embedded.Event(id: "1", name: "", images: [EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "www.w.en")!, width: 150, height: 150)], dates: EventResponse.Embedded.Event.EventDates(start: EventResponse.Embedded.Event.EventDates.EventStart(localDate: "")), embedded: EventResponse.Embedded.Event.EventEmbedded(venues: [EventResponse.Embedded.Event.EventEmbedded.Venue(name: "", city: EventResponse.Embedded.Event.EventEmbedded.Venue.City(name: ""), address: EventResponse.Embedded.Event.EventEmbedded.Venue.Address(line1: ""))]))]
    }
}

class NetworkManagerMockWithThrow: NetworkManagerProtocol {
    func getNextURL() -> String? {
        nil
    }
    
    func getAllEvents(_ session: URLSession = URLSession.shared) async throws -> [EventResponse.Embedded.Event] {
        throw JTError.responseError(description: "Bad response")
    }
}

final class MainView_ViewModelTests: XCTestCase {
    @MainActor func testFetchingEventsEmptyData() {
        let networkManagerMock = NetworkManagerMockWithoutData()
        let sut = MainView.ViewModel(networkManager: networkManagerMock)
        let _ = sut.fetchEvents()
        let expectation = expectation(description: "Waiting for fetchEvents to complete")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.events.count, 0)
            expectation.fulfill()
        }
        
        XCTAssertEqual(sut.events.count, 0)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    @MainActor func testFetchingEventsWithData() {
        let networkManagerMock = NetworkManagerMockWithData()
        let sut = MainView.ViewModel(networkManager: networkManagerMock)
        let _ =  sut.fetchEvents()
        let expectation = expectation(description: "Waiting for fetchEvents to complete")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.events.count, 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    @MainActor func testFetchingEventsWithError() {
        let networkManagerMock = NetworkManagerMockWithThrow()
        let sut = MainView.ViewModel(networkManager: networkManagerMock)
        let _ =  sut.fetchEvents()
        let expectation = expectation(description: "Waiting for fetchEvents to complete")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssert(sut.errorMessage != nil)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    @MainActor func testFetchingNextPageWithData() {
        let networkManagerMock = NetworkManagerMockWithData()
        let sut = MainView.ViewModel(networkManager: networkManagerMock)
        let _ = sut.fetchEvents()
        let _ = sut.fetchNextEvents()
        let expectation = expectation(description: "Waiting for fetchNextPage to complete")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(sut.events.count == 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    @MainActor func testGettingURLForCoverImage() {
        let networkManagerMock = NetworkManagerMockWithData()
        let sut = MainView.ViewModel(networkManager: networkManagerMock)
        let _ = sut.fetchEvents()
        let expectation = expectation(description: "Waiting for fetchEvents to complete")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.events.count, 1)
            XCTAssert(sut.getCoverImage(for: sut.events.first!) != nil)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    @MainActor func testGettingURLForImageWithoutRecommendedOne() {
        let networkManagerMock = NetworkManagerMockWithDataForImageTest()
        let sut = MainView.ViewModel(networkManager: networkManagerMock)
        let _ = sut.fetchEvents()
        let expectation = expectation(description: "Waiting for fetchEvents to complete")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssert(sut.events.count > 0)
            XCTAssertEqual(sut.getCoverImage(for: sut.events.first!), URL(string: "www.w.en/2kjfsaldkjf-sadf-asd-fas_SMALL.jpg")!)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

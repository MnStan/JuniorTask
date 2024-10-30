//
//  MainView-ViewModelTests.swift
//  JuniorTaskTests
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import XCTest
@testable import JuniorTask

class NetworkManagerMockWithoutData: NetworkManagerProtocol {
    func getAllEvents(_ session: URLSession = URLSession.shared) async throws -> [EventResponse.Embedded.Event] {
        return []
    }
}

class NetworkManagerMockWithData: NetworkManagerProtocol {
    func getAllEvents(_ session: URLSession) async throws -> [EventResponse.Embedded.Event] {
        return [EventResponse.Embedded.Event(id: "", name: "", images: [EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "www.w.en")!)], dates: EventResponse.Embedded.Event.EventDates(start: EventResponse.Embedded.Event.EventDates.EventStart(localDate: "")), embedded: EventResponse.Embedded.Event.EventEmbedded(venues: [EventResponse.Embedded.Event.EventEmbedded.Venue(name: "", city: EventResponse.Embedded.Event.EventEmbedded.Venue.City(name: ""), address: EventResponse.Embedded.Event.EventEmbedded.Venue.Address(line1: ""))]))]
    }
}

class NetworkManagerMockWithThrow: NetworkManagerProtocol {
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
}

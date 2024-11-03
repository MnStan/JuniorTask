//
//  DetailView-ViewModelTests.swift
//  JuniorTaskTests
//
//  Created by Maksymilian Stan on 03/11/2024.
//

import XCTest
@testable import JuniorTask

class NetworkManagerMockWithImages: NetworkManagerProtocol {
    func getNextURL() -> String? {
        nil
    }
    
    func getAllEvents(_ session: URLSession = URLSession.shared, sortOption: SortOption?) async throws -> [EventResponse.Embedded.Event] {
        return []
    }
    
    func getEventDetails(_ session: URLSession = URLSession.shared, for event: String) async throws -> DetailEventResponse {
        return DetailEventResponse(id: "1", name: "", images: [EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "https://s1.ticketm.net/dam/b/d2c/e7f86ae6-2341-40af-91b0-3b26f5d2ed2c_1031281_ARTIST_PAGE_3_2.jpg")!, width: 300, height: 200), EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "https://s1.ticketm.net/dam/c/d2c/f7f86ae6-2341-40af-91b0-3b26f5d2ed2c_1031281_ARTIST_PAGE_3_2.jpg")!, width: 500, height: 700), EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "https://s1.ticketm.net/dam/a/d2c/d7f86ae6-2341-40af-91b0-3b26f5d2ed2c_1031281_ARTIST_PAGE_RETINA_3_2.jpg")!, width: 100, height: 150), EventResponse.Embedded.Event.EventImage(ratio: "", url: URL(string: "https://s1.ticketm.net/dam/a/d2c/d7f86ae6-2341-40af-91b0-3b26f5d2ed2c_1031281_ARTIST_PAGE_RETINA_3_2.jpg")!, width: 1000, height: 150)], dates: DetailEventResponse.DetailEventDates(start: DetailEventResponse.DetailEventDates.EventStart(localDate: "", localTime: "")), embedded: DetailEventResponse.DetailEventEmbedded(venues: [], attractions: []), priceRanges: [], classifications: [], seatmap: DetailEventResponse.SeatMap(id: "", staticUrl: URL(string: "")!))
    }
}

final class DetailView_ViewModelTests: XCTestCase {
    @MainActor func testGroupingImages() {
        let networkManagerMock = NetworkManagerMockWithImages()
        let sut = DetailsView.ViewModel(networkManager: networkManagerMock)
        let expectation = expectation(description: "Waiting for fetchEvetnDetails to complete")
        sut.fetchEventDetails(for: "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let imageGroups = sut.groupImages(images: sut.event?.images ?? [])
            
            // Three different ID's in mock data
            XCTAssertEqual(imageGroups.count, 3)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    @MainActor func testGettingMostSuitedImagesToDisplay() {
        let networkManagerMock = NetworkManagerMockWithImages()
        let sut = DetailsView.ViewModel(networkManager: networkManagerMock)
        let expectation = expectation(description: "Waiting for fetchEvetnDetails to complete")
        sut.fetchEventDetails(for: "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let image = sut.getMostSuitedImageToDisplay(images: sut.event?.images ?? [])
            
            XCTAssertEqual(image?.url.absoluteString, "https://s1.ticketm.net/dam/a/d2c/d7f86ae6-2341-40af-91b0-3b26f5d2ed2c_1031281_ARTIST_PAGE_RETINA_3_2.jpg")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    @MainActor func testGettingImages() {
        let networkManagerMock = NetworkManagerMockWithImages()
        let sut = DetailsView.ViewModel(networkManager: networkManagerMock)
        let expectation = expectation(description: "Waiting for fetchEvetnDetails to complete")
        sut.fetchEventDetails(for: "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.imagesURLs.count, 3)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

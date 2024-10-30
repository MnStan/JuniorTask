//
//  NetworkTests.swift
//  JuniorTaskTests
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import XCTest
@testable import JuniorTask

class MockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("No request handler provided.")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            XCTFail("Error handling the request: \(error)")
        }
    }

    override func stopLoading() {}
}

final class NetworkTests: XCTestCase {
    let sut = NetworkManager()
    
    var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }()
    
    override class func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testFetchingData() async throws {
        MockURLProtocol.requestHandler = { request in
            let url = request.url?.absoluteString.components(separatedBy: "&apikey")[0]
            XCTAssertEqual(url, "https://app.ticketmaster.com/discovery/v2/events.json?countryCode=PL")
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            return (response, self.mockData)
        }
        
        let result = try await sut.getAllEvents(session)
        XCTAssertEqual(result.first?.id, "Z698xZQpZaa4-")
        XCTAssertEqual(result.first?.dates.start.localDate, "2024-10-30")
    }
    
    func testGetAllEventsHandlesServerError() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        do {
            let _ = try await sut.getAllEvents(session)
        } catch {
            XCTAssertEqual(error as? JTError, JTError.responseError(description: "500"))
        }
    }
    
    func testGetAllEventsHandlesNoData() async throws {
        let mockData = """
        {
            "_embedded": {
                "events": []
            },
            "_links": {
            }
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, mockData)
        }
        
        let result = try await sut.getAllEvents(session)
        XCTAssertEqual(result.isEmpty, true)
    }

    let mockData = """
{"_embedded":{"events":[{"name":"John Maus","type":"event","id":"Z698xZQpZaa4-","test":false,"url":"https://www.ticketmaster.pl/event/john-maus-tickets/38241?language=en-us","locale":"en-us","images":[{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_RETINA_PORTRAIT_16_9.jpg","width":640,"height":360,"fallback":false},{"ratio":"3_2","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_ARTIST_PAGE_3_2.jpg","width":305,"height":203,"fallback":false},{"ratio":"4_3","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_CUSTOM.jpg","width":305,"height":225,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_TABLET_LANDSCAPE_16_9.jpg","width":1024,"height":576,"fallback":false},{"ratio":"3_2","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_RETINA_PORTRAIT_3_2.jpg","width":640,"height":427,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_RETINA_LANDSCAPE_16_9.jpg","width":1136,"height":639,"fallback":false},{"ratio":"16_9","url":"https://media.ticketmaster.eu/poland/3b1dc2179598f087d8a849c315b2b5a1.jpg","width":205,"height":115,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_RECOMENDATION_16_9.jpg","width":100,"height":56,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_TABLET_LANDSCAPE_LARGE_16_9.jpg","width":2048,"height":1152,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_SOURCE","width":2426,"height":1365,"fallback":false},{"ratio":"3_2","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_TABLET_LANDSCAPE_3_2.jpg","width":1024,"height":683,"fallback":false}],"sales":{"public":{"startDateTime":"2024-09-17T10:51:00Z","startTBD":false,"startTBA":false,"endDateTime":"2024-10-30T22:59:00Z"}},"dates":{"access":{"startDateTime":"2024-10-30T18:00:00Z","startApproximate":false,"endApproximate":false},"start":{"localDate":"2024-10-30","localTime":"19:00:00","dateTime":"2024-10-30T18:00:00Z","dateTBD":false,"dateTBA":false,"timeTBA":false,"noSpecificTime":false},"timezone":"Europe/Warsaw","status":{"code":"onsale"},"spanMultipleDays":false},"classifications":[{"primary":false,"segment":{"id":"KZFzniwnSyZfZ7v7nJ","name":"Music"},"genre":{"id":"KnvZfZ7vAvv","name":"Alternative"},"subGenre":{"id":"KZazBEonSMnZfZ7vAvJ","name":"Alternative"},"family":false},{"primary":false,"segment":{"id":"KZFzniwnSyZfZ7v7nJ","name":"Music"},"genre":{"id":"KnvZfZ7vAeA","name":"Rock"},"subGenre":{"id":"KZazBEonSMnZfZ7v6a6","name":"Punk"},"family":false},{"primary":true,"segment":{"id":"KZFzniwnSyZfZ7v7nJ","name":"Music"},"genre":{"id":"KnvZfZ7vAvt","name":"Metal"},"subGenre":{"id":"KZazBEonSMnZfZ7vkFd","name":"Heavy Metal"},"family":false}],"promoter":{"id":"1285","name":"WINIARY BOOKINGS Masłowski Stobiński Spółka Cywilna"},"promoters":[{"id":"1285","name":"WINIARY BOOKINGS Masłowski Stobiński Spółka Cywilna"}],"priceRanges":[{"type":"standard including fees","currency":"PLN","min":139.0,"max":139.0},{"type":"standard","currency":"PLN","min":139.0,"max":139.0}],"seatmap":{"staticUrl":"https://media.ticketmaster.eu/poland/ebf66dfe94f8ac241fad371df1d54ec6.jpg","id":"seatmap"},"_links":{"self":{"href":"/discovery/v2/events/Z698xZQpZaa4-?locale=en-us"},"attractions":[{"href":"/discovery/v2/attractions/K8vZ917Cfh0?locale=en-us"},{"href":"/discovery/v2/attractions/K8vZ91794y7?locale=en-us"}],"venues":[{"href":"/discovery/v2/venues/Z198xZQpZkvk?locale=en-us"}]},"_embedded":{"venues":[{"name":"Niebo","type":"venue","id":"Z198xZQpZkvk","test":false,"url":"https://www.ticketmaster.pl/venue/niebo-warszawa--bilety/nie/101","locale":"en-us","postalCode":"02-209","timezone":"Europe/Warsaw","city":{"name":"Warsaw"},"state":{"name":"Mazowieckie"},"country":{"name":"Poland","countryCode":"PL"},"address":{"line1":"ul.  Nowy Świat 21"},"location":{"longitude":"21.01822","latitude":"52.23236"},"upcomingEvents":{"mfx-pl":11,"_total":11,"_filtered":0},"_links":{"self":{"href":"/discovery/v2/venues/Z198xZQpZkvk?locale=en-us"}}}],"attractions":[{"name":"John Maus","type":"attraction","id":"K8vZ917Cfh0","test":false,"url":"https://www.ticketmaster.com/john-maus-tickets/artist/1581059","locale":"en-us","externalLinks":{"youtube":[{"url":"https://www.youtube.com/channel/UCGKrUFoCfn2QGnCBfC17OIQ"}],"twitter":[{"url":"https://twitter.com/JOHNMAUS/"}],"itunes":[{"url":"https://music.apple.com/us/artist/john-maus/423445122"}],"spotify":[{"url":"https://open.spotify.com/artist/4R073T3AVJKqAsbzLmLW9u?autoplay=true"}],"wiki":[{"url":"https://en.wikipedia.org/wiki/John_Walker_(musician)"}],"facebook":[{"url":"https://www.facebook.com/pages/John-Maus/141499528174"}],"musicbrainz":[{"id":"4c48078c-af4e-4ca3-9838-5841d91826e1","url":"https://musicbrainz.org/artist/4c48078c-af4e-4ca3-9838-5841d91826e1"}]},"images":[{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_RETINA_PORTRAIT_16_9.jpg","width":640,"height":360,"fallback":false},{"ratio":"3_2","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_ARTIST_PAGE_3_2.jpg","width":305,"height":203,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_EVENT_DETAIL_PAGE_16_9.jpg","width":205,"height":115,"fallback":false},{"ratio":"4_3","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_CUSTOM.jpg","width":305,"height":225,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_TABLET_LANDSCAPE_16_9.jpg","width":1024,"height":576,"fallback":false},{"ratio":"3_2","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_RETINA_PORTRAIT_3_2.jpg","width":640,"height":427,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_RETINA_LANDSCAPE_16_9.jpg","width":1136,"height":639,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_RECOMENDATION_16_9.jpg","width":100,"height":56,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_TABLET_LANDSCAPE_LARGE_16_9.jpg","width":2048,"height":1152,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_SOURCE","width":2426,"height":1365,"fallback":false},{"ratio":"3_2","url":"https://s1.ticketm.net/dam/a/3d6/39c8fddf-4a93-4ffe-bb9e-a6a46d13e3d6_TABLET_LANDSCAPE_3_2.jpg","width":1024,"height":683,"fallback":false}],"classifications":[{"primary":true,"segment":{"id":"KZFzniwnSyZfZ7v7nJ","name":"Music"},"genre":{"id":"KnvZfZ7vAvv","name":"Alternative"},"subGenre":{"id":"KZazBEonSMnZfZ7vAde","name":"Indie Rock"},"type":{"id":"KZAyXgnZfZ7v7l1","name":"Group"},"subType":{"id":"KZFzBErXgnZfZ7vA71","name":"Band"},"family":false}],"upcomingEvents":{"wts-tr":1,"mfx-pl":1,"_total":2,"_filtered":0},"_links":{"self":{"href":"/discovery/v2/attractions/K8vZ917Cfh0?locale=en-us"}}},{"name":"Winiary Bookings","type":"attraction","id":"K8vZ91794y7","test":false,"url":"https://www.ticketmaster.com/winiary-bookings-tickets/artist/2534145","locale":"en-us","images":[{"ratio":"16_9","url":"https://s1.ticketm.net/dam/c/797/5e693c26-2881-4776-8f0c-3aa94bfa3797_106511_TABLET_LANDSCAPE_16_9.jpg","width":1024,"height":576,"fallback":true},{"ratio":"3_2","url":"https://s1.ticketm.net/dam/a/556/95b9aeea-5d87-4a6b-ac4c-039e536a6556_RETINA_PORTRAIT_3_2.jpg","width":640,"height":427,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/c/797/5e693c26-2881-4776-8f0c-3aa94bfa3797_106511_RETINA_LANDSCAPE_16_9.jpg","width":1136,"height":639,"fallback":true},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/556/95b9aeea-5d87-4a6b-ac4c-039e536a6556_EVENT_DETAIL_PAGE_16_9.jpg","width":205,"height":115,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/556/95b9aeea-5d87-4a6b-ac4c-039e536a6556_RECOMENDATION_16_9.jpg","width":100,"height":56,"fallback":false},{"ratio":"3_2","url":"https://s1.ticketm.net/dam/a/556/95b9aeea-5d87-4a6b-ac4c-039e536a6556_ARTIST_PAGE_3_2.jpg","width":305,"height":203,"fallback":false},{"ratio":"4_3","url":"https://s1.ticketm.net/dam/a/556/95b9aeea-5d87-4a6b-ac4c-039e536a6556_CUSTOM.jpg","width":305,"height":225,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/c/f50/96fa13be-e395-429b-8558-a51bb9054f50_105951_TABLET_LANDSCAPE_LARGE_16_9.jpg","width":2048,"height":1152,"fallback":true},{"ratio":"3_2","url":"https://s1.ticketm.net/dam/c/797/5e693c26-2881-4776-8f0c-3aa94bfa3797_106511_TABLET_LANDSCAPE_3_2.jpg","width":1024,"height":683,"fallback":true},{"ratio":"1_1","url":"https://s1.ticketm.net/dam/a/556/95b9aeea-5d87-4a6b-ac4c-039e536a6556_SOURCE","width":800,"height":800,"fallback":false},{"ratio":"16_9","url":"https://s1.ticketm.net/dam/a/556/95b9aeea-5d87-4a6b-ac4c-039e536a6556_RETINA_PORTRAIT_16_9.jpg","width":640,"height":360,"fallback":false}],"classifications":[{"primary":true,"segment":{"id":"KZFzniwnSyZfZ7v7nJ","name":"Music"},"genre":{"id":"KnvZfZ7vAvv","name":"Alternative"},"subGenre":{"id":"KZazBEonSMnZfZ7vAvJ","name":"Alternative"},"type":{"id":"KZAyXgnZfZ7v7la","name":"Individual"},"subType":{"id":"KZFzBErXgnZfZ7vAdd","name":"Performer"},"family":false}],"upcomingEvents":{"mfx-pl":105,"_total":105,"_filtered":0},"_links":{"self":{"href":"/discovery/v2/attractions/K8vZ91794y7?locale=en-us"}}}]}}]},"_links":{"first":{"href":"/discovery/v2/events.json?countryCode=PL&page=0&size=1"},"prev":{"href":"/discovery/v2/events.json?countryCode=PL&page=4&size=1"},"self":{"href":"/discovery/v2/events.json?size=1&countryCode=PL&page=5"},"next":{"href":"/discovery/v2/events.json?countryCode=PL&page=6&size=1"},"last":{"href":"/discovery/v2/events.json?countryCode=PL&page=829&size=1"}},"page":{"size":1,"totalElements":830,"totalPages":830,"number":5}}
""".data(using: .utf8)!
}

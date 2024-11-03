//
//  EvenInformationsView.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 01/11/2024.
//

import SwiftUI

struct EventInformationsView: View {
    var event: EventResponse.Embedded.Event
    var date: String?
    
    var body: some View {
        VStack(spacing: 10) {
            Text(event.name)
                .font(.body)
                .bold()
                .multilineTextAlignment(.center)
            
            ForEach(event.embedded.venues, id: \.name) { venue in
                VStack {
                    Text(venue.name)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                    Text(venue.city.name)
                        .font(.subheadline)
                }
            }
            
            if let date = date {
                Text(date).bold()
                    .lineLimit(0)
                    .minimumScaleFactor(0.5)
            }
        }
    }
}

#Preview {
    EventInformationsView(event: EventResponse.Embedded.Event(id: "", name: "", images: [], dates: EventResponse.Embedded.Event.EventDates(start: EventResponse.Embedded.Event.EventDates.EventStart(localDate: "")), embedded: EventResponse.Embedded.Event.EventEmbedded(venues: [])))
}

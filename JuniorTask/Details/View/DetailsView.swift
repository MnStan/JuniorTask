//
//  DetailsView.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import SwiftUI

struct DetailsView: View {
    @ObservedObject var networkManager: NetworkManager
    @StateObject var viewModel: ViewModel
    var selectedID: String
    
    init(networkManager: NetworkManager, selectedID: String) {
        self.networkManager = networkManager
        _viewModel = StateObject(wrappedValue: ViewModel(networkManager: networkManager))
        self.selectedID = selectedID
    }
    
    var body: some View {
        ScrollView {
            Text(viewModel.errorMessage ?? "No error")
            Text(selectedID)
            Text(viewModel.event?.name ?? "")
            Text(viewModel.event?.classifications.first!.segment.name ?? "")
            Text(viewModel.event?.dates.start.localDate ?? "")
            Text(viewModel.event?.dates.start.localTime ?? "")
            Text(viewModel.event?.embedded.venues.first?.name ?? "")
            Text(viewModel.event?.embedded.venues.first?.address?.line1 ?? "")
            Text(viewModel.event?.embedded.venues.first?.city.name ?? "")
            Text("\(viewModel.event?.priceRanges?.first?.min ?? 3)")
            
            ForEach(viewModel.imagesURLs, id: \.self) { image in
                AsyncImage(url: image) { Image in
                    Image
                        .resizable()
                        .frame(width: 300, height: 300)
                } placeholder: {
                    Image(systemName: "chevron.right")
                }

            }
            
            if let seatMap = viewModel.getSeatMapImage() {
                AsyncImage(url: seatMap) { image in
                    image
                        .resizable()
                        .frame(width: 300, height: 300)
                } placeholder: {
                    Image(systemName: "chevron.right")
                }

            }
        }
        .onAppear {
            viewModel.fetchEventDetails(for: selectedID)
        }
    }
}

#Preview {
    let networkManager = MainNetworkManagerMock()
    
    DetailsView(networkManager: networkManager, selectedID: "Z698xZQpZaF52")
}

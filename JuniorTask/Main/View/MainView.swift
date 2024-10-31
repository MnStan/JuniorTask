//
//  MainView.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var networkManager: NetworkManager
    @StateObject var viewModel: ViewModel
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        _viewModel = StateObject(wrappedValue: ViewModel(networkManager: networkManager))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.events, id: \.id) { element in
                HStack {
                    if let image = viewModel.getCoverImage(for: element) {
                        CacheAsyncImage(url: image) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .frame(width: 150)
                            case .failure(_):
                                Image(systemName: "questionmark.circle.fill")
                                    .resizable()
                                    .frame(width: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            @unknown default:
                                fatalError()
                            }
                        }
                        .border(.black, width: 1)
                    } else {
                        Image(systemName: "questiomark.circle.fill")
                            .resizable()
                            .frame(width: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    VStack {
                        Text(element.name)
                            .border(.black, width: 1)
                            .multilineTextAlignment(.leading)
                        
                        if let date = viewModel.convertDate(date: element.dates.start.localDate) {
                            Text(date)
                        }
                        
                        ForEach(element.embedded.venues, id: \.name) { venue in
                            Text(venue.name)
                            Text(venue.city.name)
                        }
                    }
                }
            }
            
            if viewModel.isFetching {
                ProgressView()
            } else {
                Color.clear
                    .frame(height: 0)
                    .onAppear {
                        if viewModel.canFetchMorePages() && !viewModel.isFetching{
                            viewModel.fetchNextEvents()
                        }
                    }
            }
        }
        .onAppear {
            viewModel.fetchEvents()
        }
        .overlay {
            if viewModel.errorMessage != nil {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    let networkManager = NetworkManager()
    
    return MainView(networkManager: networkManager)
}

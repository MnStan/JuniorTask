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
    
    private func createGridColumns(width: CGFloat) -> [GridItem] {
        [GridItem(.fixed(width), alignment: .leading),
        GridItem(.fixed(width), alignment: .leading)]
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.gray.opacity(0.75), .blue.opacity(0.25)], startPoint: .bottom, endPoint: .top).ignoresSafeArea()
                .overlay {
                    Color.clear
                        .background(.thinMaterial)
                }
            
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        if !viewModel.imagesURLs.isEmpty {
                            TabView {
                                ForEach(viewModel.imagesURLs, id: \.self) { image in
                                    AsyncImage(url: image) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .padding([.leading, .trailing])
                                            .shadow(radius: 10)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                            .frame(height: geometry.size.height / 2)
                            .tabViewStyle(.page)
                            .indexViewStyle(.page(backgroundDisplayMode: .always))
                        }
                        
                        if let name = viewModel.getName() {
                            Text(name)
                                .font(.title)
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        
                        Divider()
                            .padding([.leading, .trailing])
                        
                        LazyVGrid(columns: createGridColumns(width: geometry.size.width / 2.5)) {
                            ForEach(viewModel.getInformations(), id: \.1) { item in
                                VStack(alignment: .leading) {
                                    Text(viewModel.prepareKeyToDisplay(to: item.0))
                                        .font(.caption)
                                        .bold()
                                        .foregroundStyle(.gray)
                                    Text(item.1)
                                }
                                .padding()
                            }
                        }
                        .padding()
                        
                        Divider()
                            .padding([.leading, .trailing])
                        
                        if let mapURL = viewModel.getMapURL() {
                            AsyncImage(url: mapURL) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding([.leading, .trailing])
                                    .shadow(radius: 10)
                            } placeholder: {
                                ProgressView()
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchEventDetails(for: selectedID)
        }
    }
}

#Preview {
    let networkManager = DetailNetworkManagerMock()
    
    DetailsView(networkManager: networkManager, selectedID: "Z698xZQpZaF52")
}

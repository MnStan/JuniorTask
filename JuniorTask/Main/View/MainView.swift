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
    @State var sortOption: SortOption = .relevanceDESC
    @State var isShowingAlert = false
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        _viewModel = StateObject(wrappedValue: ViewModel(networkManager: networkManager))
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(colors: [Color.gray.opacity(0.75), .blue.opacity(0.25)], startPoint: .bottom, endPoint: .top).ignoresSafeArea()
                        .overlay {
                            Color.clear
                                .background(.thinMaterial)
                        }
                    
                    VStack {
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(viewModel.events, id: \.id) { element in
                                    NavigationLink(destination: DetailsView(networkManager: networkManager, selectedID: element.id)) {
                                        HStack {
                                            if let image = viewModel.getCoverImage(for: element) {
                                                ImageView(image: image)
                                            }
                                            
                                            EventInformationsView(event: element, date: viewModel.convertDate(date: element.dates.start.localDate))
                                                .frame(width: (geometry.size.width / 2) - 25)
                                            
                                            Image(systemName: "chevron.right")
                                        }
                                        .padding(10)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 5)
                                
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
                            .padding([.top], 15)
                        }
                    }
                }
            }
            .navigationTitle("Wydarzenia")
            .toolbar {
                Menu {
                    ForEach(SortOption.allCases) { option in
                        Button {
                            sortOption = option
                        } label: {
                            if option == sortOption {
                                Label(option.description, systemImage: "checkmark")
                            } else {
                                Text(option.description)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                .onChange(of: sortOption) { newValue in
                    viewModel.fetchEvents(sortOption: sortOption)
                }
            }
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            if newValue != nil {
                isShowingAlert.toggle()
            }
        }
        .alert("Coś poszło nie tak", isPresented: $isShowingAlert) {
            Button("Ok") {
                viewModel.fetchAgain()
            }
        } message: {
            Text(viewModel.errorMessage?.description ?? "Wystąpił nieznany błąd")
        }
    }
}

#Preview {
    let networkManager = MainNetworkManagerMock()
    
    MainView(networkManager: networkManager)
}

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
                Text(element.name)
            }
        }
        .onAppear {
            viewModel.fetchEvents()
        }
    }
}

#Preview {
    let networkManager = NetworkManager()
    
    return MainView(networkManager: networkManager)
}

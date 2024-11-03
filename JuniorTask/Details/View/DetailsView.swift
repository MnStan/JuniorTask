//
//  DetailsView.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import SwiftUI

struct DetailsView: View {
    @ObservedObject var networkManager: NetworkManager
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    let networkManager = MainNetworkManagerMock()
    
    DetailsView(networkManager: networkManager)
}

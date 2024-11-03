//
//  InformationView.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 03/11/2024.
//

import SwiftUI

struct InformationView: View {
    var informationName: String
    var information: String
    var imageName: String? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(informationName)
                .font(.caption)
                .bold()
                .foregroundStyle(.gray)
            
            HStack {
                if let imageName {
                    Image(systemName: imageName)
                }
                
                Text(information)
            }
        }
    }
}

#Preview {
    InformationView(informationName: "Data", information: "2024-11-17", imageName: "calendar")
}

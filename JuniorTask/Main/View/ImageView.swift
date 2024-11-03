//
//  ImageView.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 01/11/2024.
//

import SwiftUI

struct ImageView: View {
    var image: URL
    
    var body: some View {
        CacheAsyncImage(url: image) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 150, height: 100)
            case .failure(_):
                Image("event-cover-placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            @unknown default:
                fatalError()
            }
        }
    }
}

#Preview {
    ImageView(image: URL(string: "")!)
}

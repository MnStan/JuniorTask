//
//  CacheAsyncImage.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import SwiftUI

// A view that asynchronously loads and caches an image from a given URL utilising AsyncImage - feature that simplifies the process of asynchronously loading and displaying remote images
struct CacheAsyncImage<Content>: View where Content: View {
    // Properties that are the same as properties of AsyncImage
    private let url: URL
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    /// Creates a new instance of CacheAsyncImage
    /// - Parameters:
    ///   - url: The url of the image to load
    ///   - scale: The scale factor for the image - default scale is 1.0
    ///   - transaction: The transaction for animations - default is empty
    ///   - content: A closure that produces the content view
    init (
        url: URL,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View {
        // If the image is already cached, image is rendered using closure with success phase
        if let cached = ImageCache[url] {
            content(.success(cached))
        } else {
            // If image is not cached, using AsyncImage load image from URL
            AsyncImage(url: url, scale: scale, transaction: transaction) { phase in
                switch phase {
                case .success(_):
                    // If image is loaded successfully cache and render
                    cacheAndRender(phase: phase)
                case .failure(_):
                    // If loading fails, try to load it again
                    AsyncImage(url: url, scale: scale, transaction: transaction) { phase in
                        cacheAndRender(phase: phase)
                    }
                case .empty:
                    // Show progress indicator while image is being rendered
                    ZStack {
                        ProgressView()
                        Color.clear
                            .frame(width: 150, height: 100)
                    }
                @unknown default:
                    fatalError()
                }
            }
        }
    }
    
    /// This function caches the successfully loaded image and returns content
    /// - Parameter phase: Current phase of image loading
    /// - Returns: A view to render
    func cacheAndRender(phase: AsyncImagePhase) -> some View {
        if case .success(let image) = phase {
            // If successful, cache the image for future use
            ImageCache[url] = image
        }
        
        return content(phase)
    }
}

#Preview {
    let url = URL(string: "https://s1.ticketm.net/dam/a/e8c/5265b9d2-a06c-4dc8-a432-a8dd9d042e8c_ARTIST_PAGE_3_2.jpg")
    CacheAsyncImage(url: url!) { phase in
        switch phase {
        case .empty:
            ProgressView()
        case .success(let image):
            image
        case .failure(_):
            Text("Failure")
        @unknown default:
            fatalError()
        }
    }
}

/// Cache class to store and manage loaded images
fileprivate class ImageCache {
    static private var cache: [URL: Image] = [:]
    static private var order: [URL] = []
    // The maximum number of images that can be cached to reduce storage taken up by cached images
    static private var maxCacheSize = 100
    
    /// Accessing cached images using their URL
    /// - Parametr url: The ur of the image to retrieve or store
    static subscript(url: URL) -> Image? {
        get {
            // Return the cached image for specific URL if it exists
            ImageCache.cache[url]
        }
        set {
            // Checking if image is already in cache
                if cache[url] == nil {
                    // If not add the URL to the tracking order
                    order.append(url)
                    
                    // Check if the cache exceeds the maximum size
                    if order.count > maxCacheSize {
                        // Remove the oldest URL from order
                        let oldestURL = order.removeFirst()
                        // Remove the oldest image from cache
                        ImageCache.cache.removeValue(forKey: oldestURL)
                    }
                }
            
            // Update cache with new image
            ImageCache.cache[url] = newValue
        }
    }
}

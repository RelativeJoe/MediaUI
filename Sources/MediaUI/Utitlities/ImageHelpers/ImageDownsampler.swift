//
//  ImageDownsampler.swift
//  
//
//  Created by Joe Maghzal on 17/07/2023.
//

import SwiftUI

public actor ImageDownsampler {
//MARK: - Properties
    private let imageData: Data
//MARK: - Initializers
    public init(_ imageData: Data) {
        self.imageData = imageData
    }
//MARK: - Functions
    public func downsampled(for size: CGSize, scale: CGFloat = 3) -> CGImage? {
        let maxPixelDimensions = max(size.width, size.height) * scale
        let downsamplingOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelDimensions
        ] as [CFString : Any] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, [kCGImageSourceShouldCache: false] as CFDictionary), let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsamplingOptions) else {
            return nil
        }
        return cgImage
    }
}

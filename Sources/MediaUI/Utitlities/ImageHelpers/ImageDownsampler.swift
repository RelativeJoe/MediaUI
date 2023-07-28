//
//  ImageDownsampler.swift
//  
//
//  Created by Joe Maghzal on 17/07/2023.
//

import SwiftUI
import STools

public actor ImageDownsampler {
//MARK: - Properties
    private let imageData: Data?
    private let image: UNImage?
//MARK: - Initializers
    public init(_ imageData: Data?) {
        self.imageData = imageData
        self.image = nil
    }
    public init(_ image: UNImage?) {
        self.image = image
        self.imageData = nil
    }
    public init(data: Data?, image: UNImage?) {
        self.imageData = data
        self.image = image
    }
//MARK: - Functions
    public func downsampled(using builder: ImageSizeBuilder, scale: CGFloat = 3) -> (image: UNImage, size: CGSize)? {
        guard let imageData = imageData ?? image?.data(.high), let image = image ?? UNImage(data: imageData) else {
            return nil
        }
        return downsampled(for: builder.build(for: image))
    }
    public func downsampled(for size: CGSize, scale: CGFloat = 3) -> (image: UNImage, size: CGSize)? {
        guard let imageData = imageData ?? image?.data(.high) else {
            return nil
        }
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
#if canImport(AppKit)
        return (UNImage(cgImage: cgImage, size: size), size)
#else
        return (UNImage(cgImage: cgImage), size)
#endif
    }
}

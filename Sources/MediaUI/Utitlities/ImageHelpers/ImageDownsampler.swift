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
    public func downsampled(width: CGFloat?, height: CGFloat?, scale: CGFloat = 3) -> UNImage? {
        return downsampled(for: ImageFitSizeBuilder(width: width, height: height), scale: scale)
    }
    public func downsampled(width: CGFloat?, scale: CGFloat = 3) -> UNImage? {
        return downsampled(for: ImageFitSizeBuilder(width: width), scale: scale)
    }
    public func downsampled(height: CGFloat?, scale: CGFloat = 3) -> UNImage? {
        return downsampled(for: ImageFitSizeBuilder(height: height), scale: scale)
    }
    public func downsampled(for sizeBuilder: ImageFitSizeBuilder, scale: CGFloat = 3) -> UNImage? {
        guard let imageData = imageData ?? image?.data(.high), let image = image ?? UNImage(data: imageData) else {
            return nil
        }
        let size = sizeBuilder.build(for: image)
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
        return UNImage(cgImage: cgImage, size: size)
#else
        return UNImage(cgImage: cgImage)
#endif
    }
}

//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/30/22.
//

import SwiftUI
import STools

//MARK: - Public Helpers
public extension Data {
    var unImage: UNImage? {
        get {
            return UNImage(data: self)
        }
    }
    func downsampledImage(width: CGFloat?, height: CGFloat?) -> UNImage? {
        if let width, let height {
            return downSampled(maxWidth: width, maxHeight: height)
        }else if let width {
            return downSampled(width: width)
        }else if let height {
            return downSampled(height: height)
        }
        return nil
    }
    func downSampled(height: CGFloat) -> UNImage? {
        guard let oldImage = UNImage(data: self), let image = downsample(to: CGSize(width: oldImage.fitWidth(for: height), height: height)) else {
            return nil
        }
        return image
    }
    func downSampled(width: CGFloat) -> UNImage? {
        guard let oldImage = UNImage(data: self), let image = downsample(to: CGSize(width: width, height: oldImage.fitHeight(for: width))) else {
            return nil
        }
        return image
    }
    func downSampled(maxWidth: CGFloat, maxHeight: CGFloat) -> UNImage? {
        guard let oldImage = UNImage(data: self), let image = downsample(to: oldImage.maxDimensions(width: maxWidth, height: maxHeight)) else {
            return nil
        }
        return image
    }
    func downsample(to size: CGSize) -> UNImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(self as CFData, imageSourceOptions) else {
            return nil
        }
        let maxDimensionInPixels = Swift.max(size.width, size.height) * 3
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as [CFString : Any] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
#if canImport(AppKit)
        return UNImage(cgImage: downsampledImage, size: size)
#else
        return UNImage(cgImage: downsampledImage)
#endif
    }
}

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
        set {
            self = newValue?.asData(.high) ?? Data()
        }
    }
}

//MARK: - Internal Helpers
internal extension Data {
    func downSampled(height: CGFloat) -> UNImage? {
        guard let oldImage = UNImage(data: self), let image = self.downsample(to: CGSize(width: oldImage.fitWidth(for: height), height: height)) else {
            return nil
        }
        return image
    }
    func downSampled(width: CGFloat) -> UNImage? {
        guard let oldImage = UNImage(data: self), let image = self.downsample(to: CGSize(width: width, height: oldImage.fitHeight(for: width))) else {
            return nil
        }
        return image
    }
    func downSampled(maxWidth: CGFloat, maxHeight: CGFloat) -> UNImage? {
        guard let oldImage = UNImage(data: self), let image = self.downsample(to: oldImage.maxDimensions(width: maxWidth, height: maxHeight)) else {
            return nil
        }
        return image
    }
    func downsample(to pointSize: CGSize) -> UNImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(self as CFData, imageSourceOptions) else {
            return nil
        }
        let maxDimensionInPixels = Swift.max(pointSize.width, pointSize.height) * 3
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
#if canImport(AppKit)
        return UNImage(cgImage: downsampledImage, size: pointSize)
#else
        return UNImage(cgImage: downsampledImage)
#endif
    }
}

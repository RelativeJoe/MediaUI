//
//  File.swift
//  
//
//  Created by Joe Maghzal on 5/7/22.
//

import SwiftUI
import STools

//MARK: - Public Functions
public extension UNImage {
    func data(_ quality: ImageQuality) -> Data? {
        #if canImport(UIKit)
        return jpegData(compressionQuality: quality.rawValue)
        #elseif canImport(AppKit)
        return tiffRepresentation
        #endif
    }
    func fitWidth(for height: CGFloat) -> CGFloat {
        let ratio = size.width/size.height
        return ratio * height
    }
    func fitHeight(for width: CGFloat) -> CGFloat {
        let ratio = size.height/size.width
        return ratio * width
    }
    func downsampledImage(width: CGFloat) -> UNImage? {
        guard let image = data(.high)?.downsample(to: CGSize(width: width, height: fitHeight(for: width))) else {
            return nil
        }
        return image
    }
    func downsampledImage(width: CGFloat?, height: CGFloat?) -> UNImage? {
        if let width, let height {
            return downsampledImage(maxWidth: width, maxHeight: height) 
        }else if let width {
            return downsampledImage(width: width)
        }else if let height {
            return downsampledImage(height: height)
        }
        return nil
    }
    func downsampledImage(height: CGFloat) -> UNImage? {
        guard let image = data(.high)?.downsample(to: CGSize(width: fitWidth(for: height), height: height)) else {
            return nil
        }
        return image
    }
    func downsampledImage(maxWidth: CGFloat, maxHeight: CGFloat) -> UNImage? {
        let image = data(.high)?.downsample(to: maxDimensions(width: maxWidth, height: maxHeight))
        return image
    }
    func maxDimensions(width: CGFloat, height: CGFloat) -> CGSize {
        let ratio = size.width/size.height
        let inverseRatio = size.height/size.width
        let maxHeight = width/ratio
        if maxHeight > height {
            let maxWidth = height/inverseRatio
            return CGSize(width: maxWidth, height: height)
        }
        return CGSize(width: width, height: maxHeight)
    }
}

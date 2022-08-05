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
    func asData(_ quality: ImageQuality) -> Data? {
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
        guard let image = self.asData(.high)?.downsample(to: CGSize(width: width, height: self.fitHeight(for: width))) else {
            return nil
        }
        return image
    }
    func downsampledImage(height: CGFloat) -> UNImage? {
        guard let image = self.asData(.high)?.downsample(to: CGSize(width: self.fitWidth(for: height), height: height)) else {
            return nil
        }
        return image
    }
    func downsampledImage(maxWidth: CGFloat, maxHeight: CGFloat) -> UNImage? {
        let image = asData(.high)?.downsample(to: self.maxDimensions(width: maxWidth, height: maxHeight))
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

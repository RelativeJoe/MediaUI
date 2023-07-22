//
//  ImageFitSizeBuilder.swift
//  
//
//  Created by Joe Maghzal on 17/07/2023.
//

import SwiftUI
import STools

public struct ImageSizeBuilder {
//MARK: - Properties
    private let width: CGFloat?
    private let height: CGFloat?
//MARK: - Initializer
    public init(width: CGFloat?, height: CGFloat?) {
        self.width = width
        self.height = height
    }
    public init(width: CGFloat?) {
        self.width = width
        self.height = nil
    }
    public init(height: CGFloat?) {
        self.width = nil
        self.height = height
    }
//MARK: - Functions
    public func build(for image: UNImage) -> CGSize {
        let ratio = image.size.width / image.size.height
        let inverseRatio = image.size.height / image.size.width
        if let width, let height {
            let maxHeight = width / ratio
            if maxHeight > height {
                let maxWidth = height/inverseRatio
                return CGSize(width: maxWidth, height: height)
            }
            return CGSize(width: width, height: maxHeight)
        }else if let width {
            return CGSize(width: width, height: inverseRatio * width)
        }else if let height {
            return CGSize(width: ratio * height, height: height)
        }
        return CGSize()
    }
}

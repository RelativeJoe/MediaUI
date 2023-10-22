//
//  UNImageHelpers.swift
//
//
//  Created by Joe Maghzal on 22/10/2023.
//

import SwiftUI

extension Data {
    init?(_ unImage: UNImage?) {
        var data: Data?
#if canImport(UIKit)
        data = unImage?.pngData()
#elseif canImport(AppKit)
        data = unImage?.tiffRepresentation
#endif
        if let data {
            self = data
        }else {
            return nil
        }
    }
}

extension UNImage {
    convenience init(_ cgImage: CGImage, size: CGSize) {
#if canImport(UIKit)
        self.init(cgImage: cgImage)
#elseif canImport(AppKit)
        self.init(cgImage: cgImage, size: size)
#endif
    }
}

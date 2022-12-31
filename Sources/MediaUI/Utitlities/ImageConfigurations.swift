//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/29/22.
//

import Foundation
import SwiftUI
import STools

public struct ImageConfigurations {
    public static let cache: NSCache<NSURL, UNImage> = {
        let cache = NSCache<NSURL, UNImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
    }()
}

public extension NSCache where ObjectType == UNImage, KeyType == NSURL {
    func image(for url: URL?) -> UNImage? {
        guard let url else {
            return nil
        }
        return object(forKey: url as NSURL)
    }
    func set(image: UNImage?, url: URL?) {
        guard let url else {return}
        if let image {
            setObject(image, forKey: url as NSURL)
        }else {
            removeObject(forKey: url as NSURL)
        }
    }
}


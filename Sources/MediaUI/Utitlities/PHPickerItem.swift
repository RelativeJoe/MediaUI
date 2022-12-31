//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/8/22.
//

import Foundation

#if canImport(Charts) || canImport(UIKi)//remove after macOS 13 goes public
@available(iOS 14.0, macOS 13.0, *)
public struct PHPickerItem: Identifiable {
    public var id = UUID()
    var itemType: ItemType?
    var error: Error?
    static public let empty = PHPickerItem()
    func getItemType() throws -> ItemType {
        guard let itemType = itemType else {
            guard let error = error else {
                throw ItemError.unexpected
            }
            throw error
        }
        return itemType
    }
}

@available(iOS 14.0, macOS 13.0, *)
extension PHPickerItem: Equatable {
    public static func == (lhs: PHPickerItem, rhs: PHPickerItem) -> Bool {
        return lhs.itemType == rhs.itemType && lhs.id == rhs.id && lhs.error?.localizedDescription == rhs.error?.localizedDescription
    }
}

@available(iOS 14.0, macOS 13.0, *)
public enum ItemType: Equatable {
    case photo(AnyImage), video(URL)
    public var id: Int {
        switch self {
            case .photo:
                return 0
            case .video:
                return 1
        }
    }
}

@available(iOS 14.0, macOS 13.0, *)
public enum ItemError: Error, Equatable {
    case unknown, unexpected
}
#endif

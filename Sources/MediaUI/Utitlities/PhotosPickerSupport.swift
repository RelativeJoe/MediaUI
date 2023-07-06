//
//  File.swift
//  
//
//  Created by Joe Maghzal on 05/07/2023.
//

import SwiftUI
import PhotosUI

@available(iOS 14.0, *)
public struct PickerItem {
    public var item: Any
    public func decodeData() async throws -> Data {
        if #available(iOS 16.0, *) {
            guard let pickerItem = item as? PhotosPickerItem else {
                throw MediaError.unexpected
            }
            guard let data = try await pickerItem.loadTransferable(type: Data.self) else {
                throw MediaError.unexpected
            }
            return data
        }
        guard let pickerItem = item as? PHPickerResult else {
            throw MediaError.unexpected
        }
        return try await pickerItem.load(type: Data.self)
    }
    public func decodeURL() async throws -> URL {
        if #available(iOS 16.0, *) {
            guard let pickerItem = item as? PhotosPickerItem else {
                throw MediaError.unexpected
            }
            guard let data = try await pickerItem.loadTransferable(type: URL.self) else {
                throw MediaError.unexpected
            }
            return data
        }
        guard let pickerItem = item as? PHPickerResult else {
            throw MediaError.unexpected
        }
        return try await pickerItem.load(type: URL.self)
    }
}

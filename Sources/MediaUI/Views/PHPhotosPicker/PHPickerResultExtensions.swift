//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/8/22.
//

#if canImport(Charts) || canImport(UIKi)
import Foundation
import UniformTypeIdentifiers
import PhotosUI

@available(iOS 14.0, macOS 13.0, *)
extension PHPickerResult {
    public func load<T: PHPickerItemTypeTransferable>(type: T.Type) async throws -> T {
        guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first, let type = UTType(typeIdentifier) else {
            throw MediaError.itemTypeError
        }
        if type.conforms(to: .image) {
            guard let item = try await loadImage() as? T else {
                throw MediaError.itemTypeMismatch
            }
            return item
        }else if type.conforms(to: .movie) {
            guard let item =  try await loadVideo() as? T else {
                throw MediaError.itemTypeMismatch
            }
            return item
        }
        throw MediaError.itemTypeError
    }
    public func loadImage() async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                guard let data, error == nil else {
                    if let error {
                        continuation.resume(throwing: error)
                    }else {
                        continuation.resume(throwing: MediaError.unexpected)
                    }
                    return
                }
                continuation.resume(returning: data)
            }
        }
    }
    public func loadVideo() async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                guard let url, error == nil else {
                    if let error {
                        continuation.resume(throwing: error)
                    }else {
                        continuation.resume(throwing: MediaError.unexpected)
                    }
                    return
                }
                continuation.resume(returning: url)
            }
        }
    }
}

public protocol PHPickerItemTypeTransferable {
}

extension Data: PHPickerItemTypeTransferable {
}

extension URL: PHPickerItemTypeTransferable {
}
#endif


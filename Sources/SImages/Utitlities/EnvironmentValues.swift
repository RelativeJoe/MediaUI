//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/7/22.
//

import SwiftUI
import PhotosUI

#if canImport(Charts)//remove after iOS 16 goes public
@available(iOS 16.0, macOS 13.0, *)
internal struct PhotosPickerConfigurationsKey: EnvironmentKey {
    internal static let defaultValue: PhotosPickerConfigurations? = nil
}

@available(iOS 16.0, macOS 13.0, *)
internal extension EnvironmentValues {
    var configurations: PhotosPickerConfigurations? {
        get {
            self[PhotosPickerConfigurationsKey.self]
        }
        set {
            self[PhotosPickerConfigurationsKey.self] = newValue
        }
    }
}
#endif


//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/30/22.
//

#if canImport(UIKit) || canImport(Charts)
import SwiftUI
import PhotosUI

@available(iOS 16.0, macOS 13.0, *)
internal struct PresentableMedia: Hashable {
    internal var isPresented = false
    internal var selected = false
    internal var anyImage = AnyImage.empty
    internal var mediaState = MediaState.empty
    internal var pickerItem: PhotosPickerItem?
}
#endif

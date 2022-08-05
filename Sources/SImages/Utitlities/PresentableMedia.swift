//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/30/22.
//
#if canImport(Charts)
import SwiftUI
import PhotosUI

@available(iOS 16.0, macOS 13.0, *)
struct PresentableMedia: Hashable {
    var isPresented = false
    var selected = false
    var anyImage = AnyImage.empty
    var mediaState = MediaState.empty
    var pickerItem: PhotosPickerItem?
}
#endif

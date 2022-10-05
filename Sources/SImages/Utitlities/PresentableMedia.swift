//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/30/22.
//

import SwiftUI
import PhotosUI

@available(iOS 16.0, macOS 13.0, *)
internal struct PresentableMedia: Hashable {
    var isPresented = false
    var selected = false
    var anyImage = AnyImage.empty
    var mediaState = MediaState.empty
    var pickerItem: PhotosPickerItem?
}

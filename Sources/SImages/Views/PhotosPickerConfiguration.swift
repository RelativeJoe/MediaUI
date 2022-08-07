//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/7/22.
//

import SwiftUI
import PhotosUI

#if canImport(Charts)
@available(iOS 16.0, *)
final class PhotosPickerConfigurations: ObservableObject {
    @Published var isPresented = false
    @Published var pickerItems = [String: [PhotosPickerItem]]()
    @Published var bindingPickerItems = [PhotosPickerItem]() {
        didSet {
            guard !bindingPickerItems.isEmpty else {return}
            pickerItems[currentlyPicking] = bindingPickerItems
            bindingPickerItems.removeAll()
            currentlyPicking = ""
        }
    }
    @Published var id = ""
    @Published var currentlyPicking = "" {
        didSet {
            isPresented = !currentlyPicking.isEmpty
        }
    }
}
#endif

enum PhotosPickerID: String, RawRepresentable {
    case mediaImage, mediaSet
}

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
final internal class PhotosPickerConfigurations: ObservableObject {
    @Published internal var isPresented = false
    @Published internal var pickerItems = [String: [PhotosPickerItem]]()
    @Published internal var bindingPickerItems = [PhotosPickerItem]() {
        didSet {
            guard !bindingPickerItems.isEmpty else {return}
            pickerItems[currentlyPicking] = bindingPickerItems
            bindingPickerItems.removeAll()
            currentlyPicking = ""
        }
    }
    @Published internal var id = ""
    @Published internal var currentlyPicking = "" {
        didSet {
            isPresented = !currentlyPicking.isEmpty
        }
    }
}
#endif

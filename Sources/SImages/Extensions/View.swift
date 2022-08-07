//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/7/22.
//

import SwiftUI
import PhotosUI

#if canImport(Charts)
//MARK: - Internal Functions
@available(iOS 16.0, *)
internal extension View {
    @ViewBuilder func privatePickerItems(id: String, action: @escaping ([PhotosPickerItem]) -> Void) -> some View {
        self.modifier(PhotoPickerItemModifier(id, action: action))
    }
    @ViewBuilder func privatePickerItem(id: String, action: @escaping (PhotosPickerItem?) -> Void) -> some View {
        self.modifier(PhotoPickerItemModifier(id, singleAction: action))
    }
}

//MARK: - Public Functions
@available(iOS 16.0, *)
public extension View {
///SImages: Add multiple PhotosPicker in this view
    @ViewBuilder func multiPhotosPicker(id: String, isPresented: Binding<Bool>, maxSelectionCount: Int? = nil, selectionBehavior: PhotosPickerSelectionBehavior = .default, matching filter: PHPickerFilter? = nil, preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy = .automatic, photoLibrary: PHPhotoLibrary = .shared()) -> MultiPhotosPicker<Self> {
        MultiPhotosPicker(id: id, isPresented: isPresented, filter: filter, encoding: preferredItemEncoding, maxSelectionCount: maxSelectionCount, behavior: selectionBehavior, library: photoLibrary, content: self)
    }
///SImages: Enables multiple PhotosPicker in this view
    @ViewBuilder func photosPickerConfigurations() -> some View {
        self.modifier(PhotosPickerConfigurationsModifer())
    }
}
#endif

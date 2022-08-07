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
struct MultiPhotosPicker: ViewModifier {
    @EnvironmentObject var configurations: PhotosPickerConfigurations
    @Environment(\.photosPickerId) private var id
    @Binding public var isPresented: Bool
    let filter: PHPickerFilter?
    let encoding: PhotosPickerItem.EncodingDisambiguationPolicy
    let maxSelectionCount: Int?
    let behavior: PhotosPickerSelectionBehavior
    let library: PHPhotoLibrary
    func body(content: Content) -> some View {
        Group {
            if configurations.id == id || configurations.id.isEmpty {
                content
                    .photosPicker(isPresented: $configurations.isPresented, selection: $configurations.bindingPickerItems, maxSelectionCount: maxSelectionCount, selectionBehavior: behavior, matching: filter, preferredItemEncoding: encoding, photoLibrary: library)
                    .onAppear {
                        if configurations.id.isEmpty {
                            configurations.id = id
                        }
                    }.onDisappear {
                        configurations.id = ""
                    }
            }else {
                content
            }
        }.onChange(of: isPresented) { newValue in
            configurations.currentlyPicking = newValue ? id: ""
        }
    }
}

@available(iOS 16.0, *)
public extension View {
    @ViewBuilder func multiPhotosPicker(isPresented: Binding<Bool>, maxSelectionCount: Int? = nil, selectionBehavior: PhotosPickerSelectionBehavior = .default, matching filter: PHPickerFilter? = nil, preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy = .automatic, photoLibrary: PHPhotoLibrary) -> some View {
        self.modifier(MultiPhotosPicker(isPresented: isPresented, filter: filter, encoding: preferredItemEncoding, maxSelectionCount: maxSelectionCount, behavior: selectionBehavior, library: photoLibrary))
    }
}
#endif

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
    @Environment(\.configurations) private var configurations
    @Environment(\.photosPickerId) private var id
    @Binding var isPresented: Bool
    @State private var configurationsBindingPickerItems = [PhotosPickerItem]()
    @State private var configurationsPresentation = false
    let filter: PHPickerFilter?
    let encoding: PhotosPickerItem.EncodingDisambiguationPolicy
    let maxSelectionCount: Int?
    let behavior: PhotosPickerSelectionBehavior
    let library: PHPhotoLibrary
    func body(content: Content) -> some View {
        Group {
            if configurations.id == id || configurations.id.isEmpty {
                content
                    .photosPicker(isPresented: $configurationsPresentation, selection: $configurationsBindingPickerItems, maxSelectionCount: maxSelectionCount, selectionBehavior: behavior, matching: filter, preferredItemEncoding: encoding, photoLibrary: library)
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
            configurations.currentlyPicking = newValue ? PhotosPickerID.mediaSet.rawValue: ""
        }.onChange(of: configurations.isPresented) { newValue in
            configurationsPresentation = newValue
        }.onChange(of: configurationsPresentation) { newValue in
            configurations.isPresented = newValue
        }.onChange(of: configurations.bindingPickerItems) { newValue in
            configurationsBindingPickerItems = newValue
        }.onChange(of: configurationsBindingPickerItems) { newValue in
            configurations.bindingPickerItems = newValue
        }
    }
}

@available(iOS 16.0, *)
extension View {
    @ViewBuilder func multiPhotosPicker(isPresented: Binding<Bool>, maxSelectionCount: Int? = nil, selectionBehavior: PhotosPickerSelectionBehavior = .default, matching filter: PHPickerFilter? = nil, preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy = .automatic, photoLibrary: PHPhotoLibrary) -> some View {
        self.modifier(MultiPhotosPicker(isPresented: isPresented, filter: filter, encoding: preferredItemEncoding, maxSelectionCount: maxSelectionCount, behavior: selectionBehavior, library: photoLibrary))
    }
}
#endif
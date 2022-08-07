//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/7/22.
//

import SwiftUI
import PhotosUI
import STools

#if canImport(Charts)
@available(iOS 16.0, *)
public struct MultiPhotosPicker<Content: View>: View {
    @EnvironmentObject private var configurations: PhotosPickerConfigurations
    @Binding private var isPresented: Bool
    private let id: String
    private let filter: PHPickerFilter?
    private let encoding: PhotosPickerItem.EncodingDisambiguationPolicy
    private let maxSelectionCount: Int?
    private let behavior: PhotosPickerSelectionBehavior
    private let library: PHPhotoLibrary
    private let content: Content
    public var body: some View {
        Group {
            if configurations.id == id || configurations.id.isEmpty {
                if maxSelectionCount == 1 {
                    content
                        .photosPicker(isPresented: $configurations.isPresented, selection: $configurations.bindingPickerItems, maxSelectionCount: 1, selectionBehavior: behavior, matching: filter, preferredItemEncoding: encoding, photoLibrary: library)
                }else {
                    content
                        .photosPicker(isPresented: $configurations.isPresented, selection: $configurations.bindingPickerItems, maxSelectionCount: maxSelectionCount, selectionBehavior: behavior, matching: filter, preferredItemEncoding: encoding, photoLibrary: library)
                }
            }else {
                content
            }
        }.onAppear {
            if configurations.id.isEmpty {
                configurations.id = id
            }
        }.onDisappear {
            configurations.id = ""
        }.onChange(of: isPresented) { newValue in
            configurations.currentlyPicking = newValue ? id: ""
        }.onChange(of: configurations.isPresented) { newValue in
            guard !configurations.isPresented else {return}
            isPresented = newValue
        }
    }
}

//MARK: - Public Functions
@available(iOS 16.0, *)
public extension MultiPhotosPicker {
///MultiPhotosPicker: Listen to the changes for multiple photo selection
    @ViewBuilder func pickerItems(_ action: @escaping ([PhotosPickerItem]) -> Void) -> some View {
        self.privatePickerItems(id: id, action: action)
    }
///MultiPhotosPicker: Listen to the changes for single photo selection
    @ViewBuilder func pickerItem(_ action: @escaping (PhotosPickerItem?) -> Void) -> some View {
        self.privatePickerItem(id: id, action: action)
    }
}

//MARK: - Internal Initializer
@available(iOS 16.0, *)
internal extension MultiPhotosPicker {
    init(id: String, isPresented: Binding<Bool>, filter: PHPickerFilter?, encoding: PhotosPickerItem.EncodingDisambiguationPolicy, maxSelectionCount: Int?, behavior: PhotosPickerSelectionBehavior, library: PHPhotoLibrary, content: Content) {
        self._isPresented = isPresented
        self.id = id
        self.filter = filter
        self.encoding = encoding
        self.maxSelectionCount = maxSelectionCount
        self.behavior = behavior
        self.library = library
        self.content = content
    }
}
#endif

//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/7/22.
//

import SwiftUI
import PhotosUI

#if canImport(Charts)//remove after iOS 16 goes public
//MARK: - Internal Functions
@available(iOS 16.0, macOS 13.0, *)
internal extension View {
    @ViewBuilder func privatePickerItems(id: String, action: @escaping ([PhotosPickerItem]) -> Void) -> some View {
        self.modifier(PhotoPickerItemModifier(id, action: action))
    }
    @ViewBuilder func privatePickerItem(id: String, action: @escaping (PhotosPickerItem?) -> Void) -> some View {
        self.modifier(PhotoPickerItemModifier(id, singleAction: action))
    }
}

//MARK: - Public Functions
@available(iOS 16.0, macOS 13.0, *)
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

#if canImport(Charts) || canImport(UIKi)//remove after macOS 13 goes public
@available(iOS 14.0, macOS 13.0, *)
public extension View {
#if canImport(UIKit)
    @ViewBuilder func phPhotosPicker(isPresented: Binding<Bool>, selection: Binding<[PHPickerResult]>, filter: PHPickerFilter, selectionLimit: Int? = nil, loading: PhotosPickerLoading, preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode, style: PHPhotosPickerStyle = .sheetPresented) -> some View {
        switch style {
            case .sheetPresented:
                self
                    .sheet(isPresented: isPresented) {
                        PHPhotosPicker(isPresented: isPresented, result: selection, filter: filter, selectionLimit: selectionLimit, preferredAssetRepresentationMode: preferredAssetRepresentationMode)
                    }
                
            case .fullscreenPresented:
                self
                    .fullScreenCover(isPresented: isPresented) {
                        PHPhotosPicker(isPresented: isPresented, result: selection, filter: filter, selectionLimit: selectionLimit, preferredAssetRepresentationMode: preferredAssetRepresentationMode)
                    }
        }
    }
    @ViewBuilder func phPhotosPicker(isPresented: Binding<Bool>, selection: Binding<[PHPickerItem]>, filter: PHPickerFilter, selectionLimit: Int? = nil, loading: PhotosPickerLoading, preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode, style: PHPhotosPickerStyle = .sheetPresented) -> some View {
        switch style {
            case .sheetPresented:
                self
                    .sheet(isPresented: isPresented) {
                        PHPhotosPicker(isPresented: isPresented, pickerItems: selection, filter: filter, selectionLimit: selectionLimit, loading: loading, preferredAssetRepresentationMode: preferredAssetRepresentationMode)
                    }
            case .fullscreenPresented:
                self
                    .fullScreenCover(isPresented: isPresented) {
                        PHPhotosPicker(isPresented: isPresented, pickerItems: selection, filter: filter, selectionLimit: selectionLimit, loading: loading, preferredAssetRepresentationMode: preferredAssetRepresentationMode)
                    }
        }
    }
#else
    @ViewBuilder func phPhotosPicker(isPresented: Binding<Bool>, selection: Binding<[PHPickerResult]>, filter: PHPickerFilter, selectionLimit: Int? = nil, loading: PhotosPickerLoading, preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode) -> some View {
        self
            .sheet(isPresented: isPresented) {
                PHPhotosPicker(isPresented: isPresented, result: selection, filter: filter, selectionLimit: selectionLimit, preferredAssetRepresentationMode: preferredAssetRepresentationMode)
            }
    }
    @ViewBuilder func phPhotosPicker(isPresented: Binding<Bool>, selection: Binding<[PHPickerItem]>, filter: PHPickerFilter, selectionLimit: Int? = nil, loading: PhotosPickerLoading, preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode) -> some View {
        self
            .sheet(isPresented: isPresented) {
                PHPhotosPicker(isPresented: isPresented, pickerItems: selection, filter: filter, selectionLimit: selectionLimit, loading: loading, preferredAssetRepresentationMode: preferredAssetRepresentationMode)
            }
    }
#endif
}
#endif

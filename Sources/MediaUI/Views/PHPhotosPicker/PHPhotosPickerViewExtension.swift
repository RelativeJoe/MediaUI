//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/7/22.
//

#if canImport(Charts) || canImport(UIKi)
import SwiftUI
import PhotosUI

@available(iOS 14.0, macOS 13.0, *)
public extension View {
#if canImport(UIKit)
    @ViewBuilder func phPhotosPicker(isPresented: Binding<Bool>, selection: Binding<[PHPickerResult]>, filter: PHPickerFilter, selectionLimit: Int? = nil, preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic, style: PHPhotosPickerStyle = .sheet) -> some View {
        let picker = PHPhotosPicker(isPresented: isPresented, phPickerItems: selection, filter: filter, selectionLimit: selectionLimit, preferredAssetRepresentationMode: preferredAssetRepresentationMode)
        switch style {
            case .sheet:
                sheet(isPresented: isPresented) {
                    picker
                }
            case .fullscreen:
                fullScreenCover(isPresented: isPresented) {
                    picker
                }
        }
    }
#else
    func phPhotosPicker(isPresented: Binding<Bool>, selection: Binding<[PHPickerResult]>, filter: PHPickerFilter, selectionLimit: Int? = nil, preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic, style: PHPhotosPickerStyle = .sheet) -> some View {
        sheet(isPresented: isPresented) {
            PHPhotosPicker(isPresented: isPresented, phPickerItems: selection, filter: filter, selectionLimit: selectionLimit, preferredAssetRepresentationMode: preferredAssetRepresentationMode)
        }
    }
#endif
}
#endif

//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/8/22.
//

import SwiftUI
import PhotosUI
import STools
import UniformTypeIdentifiers
import Combine

#if canImport(Charts) || canImport(UIKi)
///MediaUI: SwiftUI wrapper for PHPickerViewController.
@available(iOS 14.0, macOS 13.0, *)
public struct PHPhotosPicker {
//MARK: - Properties
    @Binding internal var isPresented: Bool
    @Binding private var pickerItems: [PHPickerResult]
    private let filter: PHPickerFilter
    private let selectionLimit: Int?
    private let preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode
//MARK: - Coordinator
    public func makeCoordinator() -> PHPhotosPickerCoordinator {
        return PHPhotosPickerCoordinator(isPresented: $isPresented, pickerItems: $pickerItems)
    }
}

#if canImport(UIKit)
@available(iOS 14.0, *)
extension PHPhotosPicker: UIViewControllerRepresentable {
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        return configureViewController(context: context)
    }
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
}

#elseif canImport(AppKit)
@available(macOS 13.0, *)
extension PHPhotosPicker: NSViewControllerRepresentable {
    public func makeNSViewController(context: Context) -> PHPickerViewController {
        return configureViewController(context: context)
    }
    public func updateNSViewController(_ nsViewController: PHPickerViewController, context: Context) {
    }
}
#endif

//MARK: - Internal Initializer
@available(iOS 14.0, macOS 13.0, *)
internal extension PHPhotosPicker {
    func configureViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = filter
        if let selectionLimit = selectionLimit {
            configuration.selectionLimit = selectionLimit
        }
        configuration.preferredAssetRepresentationMode = preferredAssetRepresentationMode
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = context.coordinator
        return pickerViewController
    }
}

//MARK: - Internal Initializer
@available(iOS 14.0, macOS 13.0, *)
public extension PHPhotosPicker {
///MediaUI: Presenting a PHPickerViewController.
    init(isPresented: Binding<Bool>, phPickerItems: Binding<[PHPickerResult]>, filter: PHPickerFilter, selectionLimit: Int? = nil, preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic) {
        self._isPresented = isPresented
        self.filter = filter
        self.selectionLimit = selectionLimit
        self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
        self._pickerItems = phPickerItems
    }
}

@available(iOS 14.0, macOS 13.0, *)
public enum PHPhotosPickerStyle {
    case sheet
#if canImport(UIKit)
    case fullscreen
#endif
}
#endif

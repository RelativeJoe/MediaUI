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
    @Binding internal var isPresented: Bool
    @State internal var phPickerItems = [PHPickerItem]()
    @Binding private var pickerItems: [PHPickerItem]
    @State internal var isLoading = false
    @Binding private var result: [PHPickerResult]
    private let filter: PHPickerFilter
    private let selectionLimit: Int?
    internal let loading: PhotosPickerLoading?
    private let preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode
    private let isBinding: Bool
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

//MARK: - UNViewControllerRepresentable
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
    public func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
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
///MediaUI: Presenting a PHPickerViewController to be used with phPickerItems for listening to picked items changes.
    init(isPresented: Binding<Bool>, filter: PHPickerFilter, selectionLimit: Int?, loading: PhotosPickerLoading, preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode) {
        self._isPresented = isPresented
        self.filter = filter
        self.selectionLimit = selectionLimit
        self.loading = loading
        self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
        self._pickerItems = .constant([])
        self._result = .constant([])
        self.isBinding = false
    }
///MediaUI: Presenting a PHPickerViewController.
    init(isPresented: Binding<Bool>, pickerItems: Binding<[PHPickerItem]>, filter: PHPickerFilter, selectionLimit: Int?, loading: PhotosPickerLoading, preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode) {
        self._isPresented = isPresented
        self.filter = filter
        self.selectionLimit = selectionLimit
        self.loading = loading
        self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
        self._pickerItems = pickerItems
        self._result = .constant([])
        self.isBinding = true
    }
///MediaUI: Presenting a PHPickerViewController without any type of loading.
    init(isPresented: Binding<Bool>, result: Binding<[PHPickerResult]>, filter: PHPickerFilter, selectionLimit: Int?, preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode) {
        self._isPresented = isPresented
        self.filter = filter
        self.selectionLimit = selectionLimit
        self.loading = nil
        self.preferredAssetRepresentationMode = preferredAssetRepresentationMode
        self._pickerItems = .constant([])
        self._result = result
        self.isBinding = true
    }
}

//MARK: - Public Functions
@available(iOS 14.0, macOS 13.0, *)
public extension PHPhotosPicker {
///PHPhotosPicker: Listen to changes in picked items.
    @ViewBuilder func phPickerItems(_ action: @escaping ([PHPickerItem]) -> Void) -> some View {
        self
            .onChange(of: phPickerItems) { newValue in
                if isBinding {
                    pickerItems = newValue
                }
                action(newValue)
            }
    }
///PHPhotosPicker: Listen to changes in picker loading.
    @ViewBuilder func onLoadingChange(_ action: @escaping (Bool) -> Void) -> some View {
        self
            .onChange(of: isLoading) { newValue in
                action(newValue)
            }
    }
}

@available(iOS 14.0, macOS 13.0, *)
final public class Coordinator {
    private var currentValueSubject = PassthroughSubject<[PHPickerItem], Never>()
    private var pickerItems = [PHPickerItem]()
    private var parent: PHPhotosPicker
    internal init(_ parent: PHPhotosPicker) {
        self.parent = parent
    }
}

//MARK: - Private Functions
@available(iOS 14.0, macOS 13.0, *)
private extension Coordinator {
    func loadItem(itemProvider: NSItemProvider) {
        guard let loading = parent.loading else {return}
        guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first, let type = UTType(typeIdentifier) else {
            return
        }
        if loading == .emptySingle {
            parent.phPickerItems.append(.empty)
        }
        if type.conforms(to: .image) {
            loadImage(for: itemProvider)
        }else if type.conforms(to: .movie) {
            loadVideo(for: itemProvider)
        }else {
            if loading == .emptySingle {
                guard let index = parent.phPickerItems.firstIndex(where: {$0.itemType == nil && $0.error == nil}) else {return}
                parent.phPickerItems.remove(at: index)
            }
        }
    }
    func loadImage(for itemProvider: NSItemProvider) {
        itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] data, error in
            guard let strongSelf = self else {
                return
            }
            guard let data = data, error == nil else {
                return
            }
            let phPickerItem = PHPickerItem(itemType: .photo(AnyImage(data)))
            strongSelf.append(phPickerItem: phPickerItem)
        }
    }
    func loadVideo(for itemProvider: NSItemProvider) {
        itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
            guard let strongSelf = self else {
                return
            }
            guard let url = url, error == nil else {
                return
            }
            let phPickerItem = PHPickerItem(itemType: .video(url))
            strongSelf.append(phPickerItem: phPickerItem)
        }
    }
    func append(phPickerItem: PHPickerItem) {
        guard let loading = parent.loading else {return}
        switch loading {
            case .emptyBatch, .emptySingle:
                guard let index = parent.phPickerItems.firstIndex(where: {$0.itemType == nil && $0.error == nil}) else {return}
                parent.phPickerItems[index] = phPickerItem
            case .single:
                parent.phPickerItems.append(phPickerItem)
            case .batch:
                pickerItems.append(phPickerItem)
        }
    }
}

//MARK: - PHPickerViewControllerDelegate
@available(iOS 14.0, macOS 13.0, *)
extension Coordinator: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {return}
            strongSelf.parent.isPresented.toggle()
            guard let loading = strongSelf.parent.loading else {
                return
            }
            strongSelf.parent.isLoading = true
            if loading == .emptyBatch {
                results.forEach { result in
                    strongSelf.parent.phPickerItems.append(.empty)
                }
            }
            results.forEach { result in
                strongSelf.loadItem(itemProvider: result.itemProvider)
            }
            if loading == .batch {
                strongSelf.parent.phPickerItems = strongSelf.pickerItems
            }
            strongSelf.parent.isLoading = false
        }
    }
}

@available(iOS 14.0, macOS 13.0, *)
public enum PHPhotosPickerStyle {
    case sheetPresented
#if canImport(UIKit)
    case fullscreenPresented
#endif
}

///MediaUI: A type to represent PhotosPicker loading.
@available(iOS 14.0, macOS 13.0, *)
public enum PhotosPickerLoading {
///MediaUI: Load all the images without an empty placeholder array..
    case batch
///MediaUI: Load all the images with an empty placeholder array..
    case emptyBatch
///MediaUI: Load a single Image directly without an empty placeholder.
    case single
///MediaUI: Load a single Image directly with an empty placeholder.
    case emptySingle
}
#endif


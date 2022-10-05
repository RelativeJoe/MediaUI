//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/5/22.
//

import SwiftUI
import PhotosUI
import STools

///SImages: A MediaSet is a collection of Photos picked by the user. You can place it inside an HStack, VStack, LazyVGrid, LazyHGrid...
@available(iOS 16.0, macOS 13.0, *)
public struct MediaSet<Medias: Mediabley, Content: View>: View {
    @Binding private var overridenPickerItems: [PhotosPickerItem]
    @Binding private var isPresented: Bool
    @Binding private var content: [Medias]
    @State private var pickerItems = [PhotosPickerItem]()
    private var overridePicker = false
    private let filter: PHPickerFilter?
    private let encoding: PhotosPickerItem.EncodingDisambiguationPolicy
    private let maxSelectionCount: Int?
    private let behavior: PhotosPickerSelectionBehavior
    private let library: PHPhotoLibrary
    private var contentForLoading: (() -> Content)?
    private var contentForMedia: ((DownsampledImage, Medias, Int) -> Content)?
    public var body: some View {
        Group {
            if content.isEmpty {
                Color.clear
            }
            ForEach(Array(content.enumerated()), id: \.offset) { index, item in
                if item.data == Data() {
                    if let contentForLoading {
                        contentForLoading()
                    }else {
                        ProgressView()
                    }
                }else {
                    contentForMedia?(DownsampledImage(image: content[index].data.unImage), item, index)
                }
            }
        }.stateModifier(overridePicker) { view in
            view
                .onChange(of: overridenPickerItems) { newValue in
                    newValue.forEach { _ in
                        content.append(Medias.empty)
                    }
                    newValue.forEach { item in
                        updateState(pickerItem: item)
                    }
                }
        }.stateModifier(!overridePicker) { view in
            view
                .photosPicker(isPresented: $isPresented, selection: $pickerItems, maxSelectionCount: maxSelectionCount, selectionBehavior: behavior, matching: filter, preferredItemEncoding: encoding, photoLibrary: library)
                .onChange(of: pickerItems) { newValue in
                    newValue.forEach { _ in
                        content.append(Medias.empty)
                    }
                    newValue.forEach { item in
                        updateState(pickerItem: item)
                    }
                }
        }
    }
}

//MARK: - Private Initializer
@available(iOS 16.0, macOS 13.0, *)
private extension MediaSet {
    init(isPresented: Binding<Bool>, content: Binding<[Medias]>, filter: PHPickerFilter?, encoding: PhotosPickerItem.EncodingDisambiguationPolicy, maxSelectionCount: Int?, behavior: PhotosPickerSelectionBehavior, library: PHPhotoLibrary, contentForLoading: (() -> Content)?, contentForMedia: ((DownsampledImage, Medias, Int) -> Content)?, overiddenItems: Binding<[PhotosPickerItem]>?, override: Bool) {
        self._isPresented = isPresented
        self._content = content
        self.filter = filter
        self.encoding = encoding
        self.maxSelectionCount = maxSelectionCount
        self.behavior = behavior
        self.library = library
        self.contentForLoading = contentForLoading
        self.contentForMedia = contentForMedia
        self.overridePicker = override
        self._overridenPickerItems = overiddenItems ?? .constant([])
    }
}

//MARK: - Public Initializer
@available(iOS 16.0, macOS 13.0, *)
extension MediaSet {
///SImages: Initialize a MediaSet.
    public init(isPresented: Binding<Bool>, content: Binding<[Medias]>) {
        self._isPresented = isPresented
        self._content = content
        self.filter = nil
        self.encoding = .automatic
        self.maxSelectionCount = nil
        self.behavior = .default
        self.library = PHPhotoLibrary.shared()
        self.overridePicker = false
        self._overridenPickerItems = .constant([])
    }
}

//MARK: - Private Modifiers
@available(iOS 16.0, macOS 13.0, *)
private extension MediaSet {
    func updateState(pickerItem: PhotosPickerItem?) {
        Task {
            guard let pickerItem = pickerItem else {return}
            guard let image = try? await pickerItem.loadTransferable(type: Data.self) else {
                pickerItems.removeAll(where: {$0 == pickerItem})
                if let index = content.firstIndex(where: {$0.data == Data()}) {
                    content.remove(at: index)
                }
                return
            }
            if let index = content.firstIndex(where: {$0.data == Data()}) {
                content[index].data = image
            }
            pickerItems.removeAll(where: {$0 == pickerItem})
        }
    }
}

//MARK: - Public Modifiers
@available(iOS 16.0, macOS 13.0, *)
public extension MediaSet {
///Assign a filter/some filters to the PhotosPicker.
    func filter(by filter: PHPickerFilter?) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia, overiddenItems: $overridenPickerItems, override: overridePicker)
    }
///MediaSet: Assing an encoding to the PhotosPicker's picked Photos.
    func encode(using encoding: PhotosPickerItem.EncodingDisambiguationPolicy) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia, overiddenItems: $overridenPickerItems, override: overridePicker)
    }
///MediaSet: Assing the maximum amount of Photos for the user to pick.
    func maxSelection(_ maxSelectionCount: Int?) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia, overiddenItems: $overridenPickerItems, override: overridePicker)
    }
///MediaSet: Assing the behavior to the PhotosPicker.
    func selection(behavior: PhotosPickerSelectionBehavior) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia, overiddenItems: $overridenPickerItems, override: overridePicker)
    }
///MediaSet: Assing the Libray of the PhotosPicker.
    func using(library: PHPhotoLibrary) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia, overiddenItems: $overridenPickerItems, override: overridePicker)
    }
///MediaSet: Assing the content to be displayed for each of the picked Photos.
    func loading(@ViewBuilder contentForLoading: @escaping () -> Content) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia, overiddenItems: $overridenPickerItems, override: overridePicker)
    }
///MediaSet: Assing the MediaImage to be displayed for each of the picked Photos.
    func content(@ViewBuilder contentForMedia: @escaping (DownsampledImage, Medias, Int) -> Content) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia, overiddenItems: $overridenPickerItems, override: overridePicker)
    }
    func using(items: Binding<[PhotosPickerItem]>) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia, overiddenItems: items, override: true)
    }
}

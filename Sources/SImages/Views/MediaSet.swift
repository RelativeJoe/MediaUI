//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/5/22.
//

#if canImport(Charts)

import SwiftUI
import PhotosUI

///SImages: A MediaSet is a collection of Photos picked by the user. You can place it inside an HStack, VStack, LazyVGrid, LazyHGrid...
@available(iOS 16.0, *)
public struct MediaSet<Medias: Mediabley, Content: View>: View {
    @EnvironmentObject private var configurations: PhotosPickerConfigurations
    @Binding private var isPresented: Bool
    @State private var pickerItems = [PhotosPickerItem]()
    @Binding private var content: [Medias]
    private let filter: PHPickerFilter?
    private let encoding: PhotosPickerItem.EncodingDisambiguationPolicy
    private let maxSelectionCount: Int?
    private let behavior: PhotosPickerSelectionBehavior
    private let library: PHPhotoLibrary
    private var contentForLoading: (() -> Content)?
    private var contentForMedia: ((DownsampledImage<Text>, Medias, Int) -> Content)?
    let id = UUID().uuidString
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
                    contentForMedia?(DownsampledImage<Text>(image: .binding($content[index].data.unImage)), item, index)
                }
            }
        }.multiPhotosPicker(id: id, isPresented: $isPresented, maxSelectionCount: maxSelectionCount, selectionBehavior: behavior, matching: filter, preferredItemEncoding: encoding, photoLibrary: library)
        .pickerItems { items in
            pickerItems = items
            pickerItems.forEach { _ in
                content.append(Medias.empty)
            }
            pickerItems.forEach { item in
                updateState(pickerItem: item)
            }
        }
    }
}

//MARK: - Private Initializer
@available(iOS 16.0, *)
private extension MediaSet {
    init(_ isPresented: Binding<Bool>, content: Binding<[Medias]>, filter: PHPickerFilter?, encoding: PhotosPickerItem.EncodingDisambiguationPolicy, maxSelectionCount: Int?, behavior: PhotosPickerSelectionBehavior, library: PHPhotoLibrary, contentForLoading: (() -> Content)?, contentForMedia: ((DownsampledImage<Text>, Medias, Int) -> Content)?) {
        self._isPresented = isPresented
        self._content = content
        self.filter = filter
        self.encoding = encoding
        self.maxSelectionCount = maxSelectionCount
        self.behavior = behavior
        self.library = library
        self.contentForLoading = contentForLoading
        self.contentForMedia = contentForMedia
    }
}

//MARK: - Public Initializer
@available(iOS 16.0, *)
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
    }
}

//MARK: - Private Modifiers
@available(iOS 16.0, *)
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
@available(iOS 16.0, *)
public extension MediaSet {
///Assign a filter/some filters to the PhotosPicker
    func filter(by filter: PHPickerFilter?) -> Self {
        MediaSet($isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia)
    }
///MediaSet: Assing an encoding to the PhotosPicker's picked Photos
    func encode(using encoding: PhotosPickerItem.EncodingDisambiguationPolicy) -> Self {
        MediaSet($isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia)
    }
///MediaSet: Assing the maximum amount of Photos for the user to pick
    func maxSelection(_ maxSelectionCount: Int?) -> Self {
        MediaSet($isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia)
    }
///MediaSet: Assing the behavior to the PhotosPicker
    func selection(behavior: PhotosPickerSelectionBehavior) -> Self {
        MediaSet($isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia)
    }
///MediaSet: Assing the Libray of the PhotosPicker
    func using(library: PHPhotoLibrary) -> Self {
        MediaSet($isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia)
    }
///MediaSet: Assing the content to be displayed for each of the picked Photos
    func loading(@ViewBuilder contentForLoading: @escaping () -> Content) -> Self {
        MediaSet($isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia)
    }
///MediaSet: Assing the MediaImage to be displayed for each of the picked Photos
    func content(@ViewBuilder contentForMedia: @escaping (DownsampledImage<Text>, Medias, Int) -> Content) -> Self {
        MediaSet($isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForLoading: contentForLoading, contentForMedia: contentForMedia)
    }
}
#endif

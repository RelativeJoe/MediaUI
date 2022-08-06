//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/5/22.
//

#if canImport(Charts)

import SwiftUI
import PhotosUI

//MARK: - Public Initializer
@available(iOS 16.0, *)
public struct MediaSet<Medias: Mediabley, Content: View>: View {
    @Binding private var isPresented: Bool
    @State private var pickerItems = [PhotosPickerItem]()
    @Binding private var content: [Medias]
    private let filter: PHPickerFilter?
    private let encoding: PhotosPickerItem.EncodingDisambiguationPolicy
    private let maxSelectionCount: Int?
    private let behavior: PhotosPickerSelectionBehavior
    private let library: PHPhotoLibrary
    private var contentForItem: ((Medias, Int) -> Content)?
    private var contentForMedia: ((DownsampledImage<Text>, Medias, Int) -> Content)?
///MediaSet: A MediaSet is a collection of Photos picked by the user. You can place it inside an HStack, VStack, LazyVGrid, LazyHGrid...
    public init(pickerPresented: Binding<Bool>, content: Binding<[Medias]>) {
        self._isPresented = pickerPresented
        self._content = content
        self.filter = nil
        self.encoding = .automatic
        self.maxSelectionCount = nil
        self.behavior = .default
        self.library = PHPhotoLibrary.shared()
    }
    public var body: some View {
        ZStack {
            Color.clear
                .frame(width: 200, height: 200)
            Group {
                ForEach(Array(content.enumerated()), id: \.element) { index, item in
                    contentForMedia?(DownsampledImage<Text>(image: .binding($content[index].data.unImage)), item, index)
                }
            }
        }.photosPicker(isPresented: $isPresented, selection: $pickerItems, maxSelectionCount: maxSelectionCount, selectionBehavior: behavior, matching: filter, preferredItemEncoding: encoding, photoLibrary: library)
        .onChange(of: pickerItems) { newValue in
            newValue.forEach { item in
                updateState(pickerItem: item)
            }
        }
    }
}

//MARK: - Private Initializer
@available(iOS 16.0, *)
private extension MediaSet {
    func updateState(pickerItem: PhotosPickerItem?) {
        guard let pickerItem = pickerItem else {return}
        Task {
            guard let image = try? await pickerItem.loadTransferable(type: Data.self) else {return}
            DispatchQueue.main.async { [self] in
                withAnimation() {
                    var media = Medias.empty
                    media.data = image
                    content.append(media)
                }
            }
        }
    }
    init(isPresented: Binding<Bool>, content: Binding<[Medias]>, filter: PHPickerFilter?, encoding: PhotosPickerItem.EncodingDisambiguationPolicy, maxSelectionCount: Int?, behavior: PhotosPickerSelectionBehavior, library: PHPhotoLibrary, contentForItem: ((Medias, Int) -> Content)?, contentForMedia: ((DownsampledImage<Text>, Medias, Int) -> Content)?) {
        self._isPresented = isPresented
        self._content = content
        self.filter = filter
        self.encoding = encoding
        self.maxSelectionCount = maxSelectionCount
        self.behavior = behavior
        self.library = library
        self.contentForItem = contentForItem
        self.contentForMedia = contentForMedia
    }
}

//MARK: - Public Modifiers
@available(iOS 16.0, *)
public extension MediaSet {
///Assign a filter/some filters to the PhotosPicker
    func filter(by filter: PHPickerFilter?) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForItem: contentForItem, contentForMedia: contentForMedia)
    }
///MediaSet: Assing an encoding to the PhotosPicker's picked Photos
    func encode(using encoding: PhotosPickerItem.EncodingDisambiguationPolicy) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForItem: contentForItem, contentForMedia: contentForMedia)
    }
///MediaSet: Assing the maximum amount of Photos for the user to pick
    func maxSelection(_ maxSelectionCount: Int?) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForItem: contentForItem, contentForMedia: contentForMedia)
    }
///MediaSet: Assing the behavior to the PhotosPicker
    func selection(behavior: PhotosPickerSelectionBehavior) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForItem: contentForItem, contentForMedia: contentForMedia)
    }
///MediaSet: Assing the Libray of the PhotosPicker
    func using(library: PHPhotoLibrary) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForItem: contentForItem, contentForMedia: contentForMedia)
    }
///MediaSet: Assing the content to be displayed for each of the picked Photos
    func content(@ViewBuilder contentForItem: @escaping (Medias, Int) -> Content) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForItem: contentForItem, contentForMedia: contentForMedia)
    }
///MediaSet: Assing the MediaImage to be displayed for each of the picked Photos
    func content(@ViewBuilder contentForMedia: @escaping (DownsampledImage<Text>, Medias, Int) -> Content) -> Self {
        MediaSet(isPresented: $isPresented, content: $content, filter: filter, encoding: encoding, maxSelectionCount: maxSelectionCount, behavior: behavior, library: library, contentForItem: contentForItem, contentForMedia: contentForMedia)
    }
}
#endif
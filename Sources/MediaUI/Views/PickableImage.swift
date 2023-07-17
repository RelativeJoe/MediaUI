//
//  File.swift
//  
//
//  Created by Joe Maghzal on 05/07/2023.
//

import Foundation

#if canImport(UIKit) || canImport(Charts)
import SwiftUI
import PhotosUI
import STools

@available(iOS 16.0, macOS 13.0, *)
public struct PickableImage<PlaceholderContent: View, ErrorContent: View, LoadingContent: View>: View {
//MARK: - Properties
    @MediaPicker(\.single) var picker
    @Binding private var data: Data?
    @State private var state = MediaState.idle
    private let width: CGFloat?
    private let height: CGFloat?
    private let placeholderView: PlaceholderContent
    private let errorView: (Error) -> ErrorContent
    private let loadingView: LoadingContent
//MARK: - View
    public var body: some View {
        Button(action: {
            do {
                try picker.presentPicker()
            }catch {
                state = .failure(error)
            }
        }) {
            switch state {
                case .idle:
                    DownsampledImage(data: data)
                        .frame(width: width, height: height)
                        .placeholder {
                            placeholderView
                        }
                case .loading:
                    loadingView
                case .failure(let error):
                    errorView(error)
            }
        }.onChange($picker) { newValue in
            Task.detached(priority: .background) {
                await loadPickedPhoto(newValue)
            }
        }
    }
}

//MARK: - Public Initializer
@available(iOS 16.0, macOS 13.0, *)
public extension PickableImage where PlaceholderContent == Color, ErrorContent == Text, LoadingContent == LoadingView {
///MediaUI: Initialize a MediaImage from  a Binding Mediable.
    init(data: Binding<Data?>) {
        self._data = data
        self.width = nil
        self.height = nil
        self.placeholderView = Color.clear
        self.errorView = { error in
            Text(error.localizedDescription)
        }
        self.loadingView = LoadingView()
    }
}

//MARK: - Internal Initializer
@available(iOS 16.0, macOS 13.0, *)
internal extension PickableImage {
    init(data: Binding<Data?>, width: CGFloat?, height: CGFloat?, placeholderView: PlaceholderContent, errorView: @escaping (Error) -> ErrorContent, loadingView: LoadingContent) {
        self._data = data
        self.width = width
        self.height = height
        self.placeholderView = placeholderView
        self.errorView = errorView
        self.loadingView = loadingView
    }
}

//MARK: - Private Functions
@available(iOS 16.0, macOS 13.0, *)
private extension PickableImage {
    func loadPickedPhoto(_ item: PhotosPickerItem) async {
        state = .loading
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {return}
            self.data = data
            state = .idle
        }catch {
            state = .failure(error)
        }
    }
}

//MARK: - Public Modifiers
@available(iOS 16.0, macOS 13.0, *)
public extension PickableImage {
///MediaImage: Positions this View within an invisible frame with the specified size.
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        PickableImage(data: $data, width: width, height: height, placeholderView: placeholderView, errorView: errorView, loadingView: loadingView)
    }
///MediaImage: Adds a placeholder View if no Image can be displayed.
    func placeholder<NewPlaceholderContent: View>(@ViewBuilder placeholderView: () -> NewPlaceholderContent) -> PickableImage<NewPlaceholderContent, ErrorContent, LoadingContent> {
        PickableImage<NewPlaceholderContent, ErrorContent, LoadingContent>(data: $data, width: width, height: height, placeholderView: placeholderView(), errorView: errorView, loadingView: loadingView)
    }
    func onError<NewErrorContent: View>(@ViewBuilder errorView: @escaping (Error) -> NewErrorContent) -> PickableImage<PlaceholderContent, NewErrorContent, LoadingContent> {
        PickableImage<PlaceholderContent, NewErrorContent, LoadingContent>(data: $data, width: width, height: height, placeholderView: placeholderView, errorView: errorView, loadingView: loadingView)
    }
    func onLoading<NewLoadingContent: View>(@ViewBuilder loadingView: () -> NewLoadingContent) -> PickableImage<PlaceholderContent, ErrorContent, NewLoadingContent> {
        PickableImage<PlaceholderContent, ErrorContent, NewLoadingContent>(data: $data, width: width, height: height, placeholderView: placeholderView, errorView: errorView, loadingView: loadingView())
    }
}
#endif

//
//  File.swift
//  
//
//  Created by Joe Maghzal on 9/29/22.
//

import SwiftUI
import STools
import PhotosUI
import Combine

///MediaUI: A NetworkImage is a View that displays an Image from the internet in a Downsampled style.
public struct NetworkImage: View {
//MARK: - Properties
    @State private var imageState = ImageState.loading
    @State private var error: String?
    @State private var unImage: UNImage?
    @State public var imageURL: URL?
    private let loading: AnyView?
    private let errorView: ((String?) -> AnyView)?
    public var settings = ImageSettings()
//MARK: - View
    public var body: some View {
        content
            .onTask {
                await load()
            }
    }
    var content: some View {
        Group {
            switch imageState {
                case .idle:
                    DownsampledImage(image: unImage, settings: settings)
                case .loading:
                    if let loading {
                        loading
                    }else {
                        #if canImport(UIKit)
                        ActivityView()
                        #endif
                    }
                case .error:
                    errorView?(error) ?? (settings.placeHolder ?? AnyView(Text(error ?? "")))
            }
        }.frame(width: settings.width, height: settings.height)
    }
}

//MARK: - Private Functions
private extension NetworkImage {
    func load() async {
        guard unImage == nil else {return}
        guard let imageURL else {
            error = "Invalid Image URL"
            imageState = .error
            return
        }
        if let image = ImageConfigurations.cache.image(for: imageURL) {
            unImage = image
            imageState = .idle
        }else {
            Task.detached {
                do {
                    await MainActor.run {
                        imageState = .loading
                    }
                    let data = try await URLSession.shared.data(from: imageURL).0
                    await MainActor.run {
                        unImage = UNImage(data: data)
                        imageState = .idle
                    }
                }catch {
                    await MainActor.run {
                        self.error = error.localizedDescription
                        imageState = .error
                    }
                }
            }
        }
    }
}

//MARK: - Public Initializers
public extension NetworkImage {
    ///MediaUI: Initialize a NetworkImage from a String.
    init(url: String?) {
        if let url {
            self._imageURL = State(wrappedValue: URL(string: url))
        }
        self.loading = nil
        self.errorView = nil
    }
    ///MediaUI: Initialize a NetworkImage from an URL.
    init(url: URL?) {
        self._imageURL = State(wrappedValue: url)
        self.loading = nil
        self.errorView = nil
    }
}

//MARK: - Internal Initializers
internal extension NetworkImage {
    init(imageState: ImageState = ImageState.idle, error: String?, unImage: UNImage?, imageURL: URL?, height: CGFloat?, width: CGFloat?, placeHolder: AnyView?, squared: Bool, resizable: Bool, aspectRatio: (CGFloat?, ContentMode)?, loading: AnyView?, errorView: ((String?) -> AnyView)?, onSize: ((CGSize) -> Void)?) {
        self._imageState = State(wrappedValue: imageState)
        self._error = State(wrappedValue: error)
        self._unImage = State(wrappedValue: unImage)
        self._imageURL = State(wrappedValue: imageURL)
        self.loading = loading
        self.errorView = errorView
        self.settings = ImageSettings(height: height, width: width, placeHolder: placeHolder, squared: squared, resizable: resizable, aspectRatio: aspectRatio, onSize: onSize)
    }
}

///MARK: - Public Modifiers
public extension NetworkImage {
    ///NetworkImage: Make the Image take the Shape of a square.
    func squaredImage() -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: settings.placeHolder, squared: true, resizable: settings.resizable, aspectRatio: settings.aspectRatio, loading: loading, errorView: errorView, onSize: settings.onSize)
    }
    ///NetworkImage: Sets the mode by which SwiftUI resizes an Image to fit it's space.
    func isResizable() -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: settings.placeHolder, squared: settings.squared, resizable: true, aspectRatio: settings.aspectRatio, loading: loading, errorView: errorView, onSize: settings.onSize)
    }
    ///NetworkImage: Constrains this View's dimesnions to the specified aspect rario.
    func aspect(_ ratio: CGFloat? = nil, contentMode: ContentMode) -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: settings.placeHolder, squared: settings.squared, resizable: settings.resizable, aspectRatio: (ratio, contentMode), loading: loading, errorView: errorView, onSize: settings.onSize)
    }
    ///NetworkImage: Positions this View within an invisible frame with the specified size.
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self  {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: height, width: width, placeHolder: settings.placeHolder, squared: settings.squared, resizable: settings.resizable, aspectRatio: settings.aspectRatio, loading: loading, errorView: errorView, onSize: settings.onSize)
    }
    ///NetworkImage: Adds a placeholder View if no Image can be displayed.
    func placeHolder(@ViewBuilder placeholder: () -> some View) -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: AnyView(placeholder()), squared: settings.squared, resizable: settings.resizable, aspectRatio: settings.aspectRatio, loading: loading, errorView: errorView, onSize: settings.onSize)
    }
    ///NetworkImage: Customize the loading View.
    func onLoading(@ViewBuilder loading: () -> some View) -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: settings.placeHolder, squared: settings.squared, resizable: settings.resizable, aspectRatio: settings.aspectRatio, loading: AnyView(loading()), errorView: errorView, onSize: settings.onSize)
    }
    func onError(@ViewBuilder errorView: @escaping (String?) -> some View) -> Self {
        let closure: ((String?) -> AnyView) = { erroryy in
            AnyView(errorView(erroryy))
        }
        return NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: settings.placeHolder, squared: settings.squared, resizable: settings.resizable, aspectRatio: settings.aspectRatio, loading: loading, errorView: closure, onSize: settings.onSize)
    }
    func imageSize(_ onSize: ((CGSize) -> Void)?) -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: settings.placeHolder, squared: settings.squared, resizable: settings.resizable, aspectRatio: settings.aspectRatio, loading: loading, errorView: errorView, onSize: onSize)
    }
}

enum ImageState {
    case idle, loading, error
}

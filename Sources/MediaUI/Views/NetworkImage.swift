//
//  File.swift
//  
//
//  Created by Joe Maghzal on 9/29/22.
//

import SwiftUI
import STools

///MediaUI: A NetworkImage is a View that displays an Image from the internet in a Downsampled style.
public struct NetworkImage: View {
//MARK: - Properties
    @State private var imageState = ImageState.loading
    @State private var error: String?
    @State private var unImage: UNImage?
    private var imageURL: URL?
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
            do {
                imageState = .loading
                let data = try await URLSession.shared.data(from: imageURL).0
                unImage = UNImage(data: data)
                imageState = .idle
            }catch {
                self.error = error.localizedDescription
                imageState = .error
            }
        }
    }
}

//MARK: - Public Initializers
public extension NetworkImage {
    ///MediaUI: Initialize a NetworkImage from a String.
    init(url: String?) {
        if let url {
            self.imageURL = URL(string: url)
        }
        self.loading = nil
        self.errorView = nil
    }
    ///MediaUI: Initialize a NetworkImage from an URL.
    init(url: URL?) {
        self.imageURL = url
        self.loading = nil
        self.errorView = nil
    }
}

//MARK: - Internal Initializers
internal extension NetworkImage {
    init(imageState: ImageState = ImageState.idle, error: String?, unImage: UNImage?, imageURL: URL?, height: CGFloat?, width: CGFloat?, placeHolder: AnyView?, squared: Bool, resizable: Bool, aspectRatio: (CGFloat?, ContentMode)?, loading: AnyView?, errorView: ((String?) -> AnyView)?) {
        self._imageState = State(wrappedValue: imageState)
        self._error = State(wrappedValue: error)
        self._unImage = State(wrappedValue: unImage)
        self.imageURL = imageURL
        self.loading = loading
        self.errorView = errorView
        self.settings = ImageSettings(height: height, width: width, placeHolder: placeHolder, squared: squared, resizable: resizable, aspectRatio: aspectRatio)
    }
}

///MARK: - Public Modifiers
public extension NetworkImage {
    ///NetworkImage: Make the Image take the Shape of a square.
    func squaredImage() -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: settings.placeHolder, squared: true, resizable: settings.resizable, aspectRatio: settings.aspectRatio, loading: loading, errorView: errorView)
    }
    ///NetworkImage: Sets the mode by which SwiftUI resizes an Image to fit it's space.
    func isResizable() -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: settings.placeHolder, squared: settings.squared, resizable: true, aspectRatio: settings.aspectRatio, loading: loading, errorView: errorView)
    }
    ///NetworkImage: Constrains this View's dimesnions to the specified aspect rario.
    func aspect(_ ratio: CGFloat? = nil, contentMode: ContentMode) -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: settings.placeHolder, squared: settings.squared, resizable: settings.resizable, aspectRatio: (ratio, contentMode), loading: loading, errorView: errorView)
    }
    ///NetworkImage: Positions this View within an invisible frame with the specified size.
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self  {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: height, width: width, placeHolder: settings.placeHolder, squared: settings.squared, resizable: settings.resizable, aspectRatio: settings.aspectRatio, loading: loading, errorView: errorView)
    }
    ///NetworkImage: Adds a placeholder View if no Image can be displayed.
    func placeHolder(@ViewBuilder placeholder: () -> some View) -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: AnyView(placeholder()), squared: settings.squared, resizable: settings.resizable, aspectRatio: settings.aspectRatio, loading: loading, errorView: errorView)
    }
    ///NetworkImage: Customize the loading View.
    func onLoading(@ViewBuilder loading: () -> some View) -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: settings.placeHolder, squared: settings.squared, resizable: settings.resizable, aspectRatio: settings.aspectRatio, loading: AnyView(loading()), errorView: errorView)
    }
    func onError(@ViewBuilder errorView: @escaping (String?) -> some View) -> Self {
        let closure: ((String?) -> AnyView) = { erroryy in
            AnyView(errorView(erroryy))
        }
        return NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: settings.height, width: settings.width, placeHolder: settings.placeHolder, squared: settings.squared, resizable: settings.resizable, aspectRatio: settings.aspectRatio, loading: loading, errorView: closure)
    }
}

enum ImageState {
    case idle, loading, error
}

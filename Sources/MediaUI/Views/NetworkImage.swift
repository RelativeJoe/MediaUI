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
public struct NetworkImage<Loading: View, ErrorView: View>: View {
//MARK: - Properties
    @State private var imageState = ImageState.loading
    private let imageURL: URL?
    private let loadingView: Loading?
    private let errorView: ((Error) -> ErrorView)?
    private let width: CGFloat?
    private let height: CGFloat?
//MARK: - View
    public var body: some View {
        switch imageState {
            case .idle(let unImage):
                DownsampledImage(image: unImage)
                    .frame(width: width, height: height)
            case .loading:
                Group {
                    if let loadingView {
                        loadingView
                    }else {
                        LoadingView()
                    }
                }.withTask {
                    await load()
                }
            case .error(let error):
                if let errorView {
                    errorView(error)
                }else {
                    Text(error.localizedDescription)
                }
        }
    }
}

//MARK: - Private Functions
private extension NetworkImage {
    func load() async {
        guard let imageURL else {
            imageState = .error(MediaError.invalidURL)
            return
        }
        if let image = ImageConfigurations.cache.image(for: imageURL) {
            imageState = .idle(image)
        }else {
            Task(priority: .background) {
                do {
                    imageState = .loading
                    let data = try await URLSession.shared.data(from: imageURL).0
                    guard let image = UNImage(data: data) else {
                        imageState = .error(MediaError.unexpected)
                        return
                    }
                    imageState = .idle(image)
                }catch {
                    imageState = .error(error)
                }
            }
        }
    }
}

//MARK: - Public Initializers
public extension NetworkImage where Loading == EmptyView, ErrorView == EmptyView {
///MediaUI: Initialize a NetworkImage from a String.
    init(url: String?) {
        self.imageURL = URL(string: url ?? "")
        self.loadingView = nil
        self.errorView = nil
        self.width = nil
        self.height = nil
    }
///MediaUI: Initialize a NetworkImage from an URL.
    init(url: URL?) {
        self.imageURL = url
        self.loadingView = nil
        self.errorView = nil
        self.width = nil
        self.height = nil
    }
}

//MARK: - Internal Initializers
internal extension NetworkImage {
    init(imageState: ImageState, imageURL: URL?, width: CGFloat?, height: CGFloat?, loadingView: Loading?, errorView: ((Error) -> ErrorView)?) {
        self._imageState = State(initialValue: imageState)
        self.imageURL = imageURL
        self.loadingView = loadingView
        self.errorView = errorView
        self.width = width
        self.height = height
    }
}

//MARK: - Public Modifiers
public extension NetworkImage {
///NetworkImage: Positions this View within an invisible frame with the specified size.
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self  {
        NetworkImage(imageState: imageState, imageURL: imageURL, width: width, height: height, loadingView: loadingView, errorView: errorView)
    }
///NetworkImage: Customize the loading View.
    func onLoading(@ViewBuilder loadingView: () -> Loading) -> NetworkImage<Loading, ErrorView> {
        NetworkImage(imageState: imageState, imageURL: imageURL, width: width, height: height, loadingView: loadingView(), errorView: errorView)
    }
///NetworkImage: Customize the error View.
    func onError(@ViewBuilder errorView: @escaping (Error) -> ErrorView) ->  NetworkImage<Loading, ErrorView> {
        NetworkImage(imageState: imageState, imageURL: imageURL, width: width, height: height, loadingView: loadingView, errorView: errorView)
    }
}

public enum ImageState {
    case idle(UNImage), loading, error(Error)
}

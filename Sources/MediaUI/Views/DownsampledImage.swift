//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/15/22.
//
import SwiftUI

///MediaUI: A DownsampledImage is a View that displays an Image in a Downsampled style.
public struct DownsampledImage<PlaceholderContent: View, ImageContent: View>: View {
//MARK: - Properties
    @Environment(\.displayScale) private var displayScale
    @State private var image: UNImage?
    @State private var imageSize: CGSize?
    private let rawImage: UNImage?
    private let data: Data?
    private let placeholder: PlaceholderContent
    private let width: CGFloat?
    private let height: CGFloat?
    private let content: (Image, CGSize) -> ImageContent
//MARK: - View
    public var body: some View {
        if let image, let imageSize {
            content(Image(unImage: image), imageSize)
                .modify(when: width != nil || height != nil) { view in
                    view
                        .frame(width: width, height: height)
                }
        }else {
            if width != nil || height != nil {
                placeholderContent(width: width, height: height)
            }else {
                GeometryReader { proxy in
                    placeholderContent(width: proxy.size.width, height: proxy.size.height)
                }
            }
        }
    }
    @ViewBuilder private func placeholderContent(width: CGFloat?, height: CGFloat?) -> some View {
        placeholder
            .task {
                await downsample()
            }
    }
//MARK: - Functions
    private func downsample() async {
        guard let data = data ?? Data(rawImage), let rawImage = rawImage ?? UNImage(data: data) else {return}
        let downsampler = ImageDownsampler(data)
        let sizeBuilder = ImageSizeBuilder(width: width, height: height)
        let size = sizeBuilder.build(for: rawImage)
        guard let cgImage = await downsampler.downsampled(for: size, scale: displayScale) else {return}
        let unImage = UNImage(cgImage, size: size)
        image = unImage
        imageSize = size
    }
}

//MARK: - Public Initializer
public extension DownsampledImage where PlaceholderContent == LoadingView, ImageContent == Image {
///MediaUI: Creates a DownsampledImage from Data.
    init(data: Data?) {
        self.init(data: data) { image, _ in
            image
                .resizable()
        }
    }
///MediaUI: Creates a DownsampledImage from an UNImage.
    init(image: UNImage?) {
        self.init(image: image) { image, _ in
            image
                .resizable()
        }
    }
///MediaUI: Creates a DownsampledImage from the specified named asset..
    init(_ assetName: String) {
        self.init(image: UNImage(named: assetName))
    }
}

//MARK: - Public Initializer
public extension DownsampledImage where PlaceholderContent == LoadingView {
    ///MediaUI: Creates a DownsampledImage from Data.
    init(data: Data?, @ViewBuilder content: @escaping (Image, CGSize) -> ImageContent) {
        self.data = data
        self.placeholder = ProgressView()
        self.width = nil
        self.height = nil
        self.rawImage = nil
        self.content = content
    }
    ///MediaUI: Creates a DownsampledImage from an UNImage.
    init(image: UNImage?, @ViewBuilder content: @escaping (Image, CGSize) -> ImageContent) {
        self.rawImage = image
        self.placeholder = ProgressView()
        self.width = nil
        self.height = nil
        self.data = nil
        self.content = content
    }
///MediaUI: Creates a DownsampledImage from the specified named asset..
    init(_ assetName: String, @ViewBuilder content: @escaping (Image, CGSize) -> ImageContent) {
        self.init(image: UNImage(named: assetName), content: content)
    }
}

//MARK: - Public Modifiers
public extension DownsampledImage {
///DownsampledImage: Adds a placeholder View if no Image can be displayed.
    func placeholder<NewPlaceholderContent: View>(@ViewBuilder placeholder: () -> NewPlaceholderContent) -> DownsampledImage<NewPlaceholderContent, ImageContent> {
        DownsampledImage<NewPlaceholderContent, ImageContent>(rawImage: rawImage, data: data, placeholder: placeholder(), width: width, height: height, content: content)
    }
///DownsampledImage: Provides the frame used to downsample the image.
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        DownsampledImage(rawImage: rawImage, data: data, placeholder: placeholder, width: width, height: height, content: content)
    }
}

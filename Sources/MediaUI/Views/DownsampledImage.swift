//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/15/22.
//
import SwiftUI
import STools

///MediaUI: A DownsampledImage is a View that displays an Image in a Downsampled style.
public struct DownsampledImage<PlaceholderContent: View, ImageContent: View>: View {
//MARK: - Properties
    @Environment(\.displayScale) private var displayScale
    @State private var image: UNImage?
    private var data: Data?
    private let placeholder: PlaceholderContent
    private let width: CGFloat?
    private let height: CGFloat?
    private let imageBuilder: (Image) -> ImageContent
//MARK: - View
    public var body: some View {
        if width != nil && height != nil {
            content(width: width, height: height)
        }else {
            GeometryReader { proxy in
                content(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }
    @ViewBuilder func content(width: CGFloat?, height: CGFloat?) -> some View {
        if let image {
            imageBuilder(Image(unImage: image))
                .frame(width: width, height: height)
        }else {
            placeholder
                .onAppear {
                    Task.detached(priority: .userInitiated) {
                        let downsampler = ImageDownsampler(data: data, image: image)
                        let sizeBuilder = ImageSizeBuilder(width: width, height: height)
                        image = await downsampler.downsampled(for: sizeBuilder, scale: displayScale)
                    }
                }
        }
    }
}

//MARK: - Public Initializer
public extension DownsampledImage where PlaceholderContent == LoadingView, ImageContent == Image {
///MediaUI: Initialize a DownsampledImage from Data.
    init(data: Data?) {
        self.data = data
        self.placeholder = LoadingView()
        self.width = nil
        self.height = nil
        self.imageBuilder = { image in
            image
                .resizable()
        }
    }
///MediaUI: Initialize a DownsampledImage from a UNImage.
    init(image: UNImage?) {
        self._image = State(initialValue: image)
        self.placeholder = LoadingView()
        self.width = nil
        self.height = nil
        self.data = nil
        self.imageBuilder = { image in
            image
                .resizable()
        }
    }
}

//MARK: - Public Modifiers
public extension DownsampledImage {
///DownsampledImage: Adds a placeholder View if no Image can be displayed.
    func placeholder<NewPlaceholderContent: View>(@ViewBuilder placeholder: () -> NewPlaceholderContent) -> DownsampledImage<NewPlaceholderContent, ImageContent> {
        DownsampledImage<NewPlaceholderContent, ImageContent>(data: data, placeholder: placeholder(), width: width, height: height, imageBuilder: imageBuilder)
    }
///DownsampledImage: Provides the frame used to downsample the image.
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        DownsampledImage(data: data, placeholder: placeholder, width: width, height: height, imageBuilder: imageBuilder)
    }
    func build<NewImageContent: View>(@ViewBuilder builder: @escaping (Image) -> NewImageContent) -> DownsampledImage<PlaceholderContent, NewImageContent> {
        DownsampledImage<PlaceholderContent, NewImageContent>(data: data, placeholder: placeholder, width: width, height: height, imageBuilder: builder)
    }
}

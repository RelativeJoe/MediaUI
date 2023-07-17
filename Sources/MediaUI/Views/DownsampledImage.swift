//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/15/22.
//
import SwiftUI
import STools

///MediaUI: A DownsampledImage is a View that displays an Image in a Downsampled style.
public struct DownsampledImage<Placeholder: View>: View {
//MARK: - Properties
    @Environment(\.displayScale) var displayScale
    @State var image: UNImage?
    private var data: Data?
    private let placeholder: Placeholder
    private let width: CGFloat?
    private let height: CGFloat?
//MARK: - View
    public var body: some View {
        if let image {
            Image(unImage: image)
                .resizable()
                .frame(width: width, height: height)
        }else {
            placeholder
                .onAppear {
                    Task.detached(priority: .userInitiated) {
                        let downsampler = ImageDownsampler(data: data, image: image)
                        image = await downsampler.downsampled(width: width, height: height, scale: displayScale)
                    }
                }
        }
    }
}

//MARK: - Public Initializer
public extension DownsampledImage where Placeholder == LoadingView  {
///MediaUI: Initialize a DownsampledImage from Data.
    init(data: Data?) {
        self.data = data
        self.placeholder = LoadingView()
        self.width = nil
        self.height = nil
    }
///MediaUI: Initialize a DownsampledImage from a UNImage.
    init(image: UNImage?) {
        self._image = State(initialValue: image)
        self.placeholder = LoadingView()
        self.width = nil
        self.height = nil
        self.data = nil
    }
}

//MARK: - Internal Initializer
internal extension DownsampledImage {
    init(data: Data?, placeholder: Placeholder, width: CGFloat?, height: CGFloat?) {
        self.data = data
        self.placeholder = placeholder
        self.width = width
        self.height = height
    }
}

//MARK: - Public Modifiers
public extension DownsampledImage {
///DownsampledImage: Adds a placeholder View if no Image can be displayed.
    func placeholder<NewPlaceholder: View>(@ViewBuilder placeholder: () -> NewPlaceholder) -> DownsampledImage<NewPlaceholder> {
        DownsampledImage<NewPlaceholder>(data: data, placeholder: placeholder(), width: width, height: height)
    }
///DownsampledImage: Provides the frame used to downsample the image.
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        DownsampledImage(data: data, placeholder: placeholder, width: width, height: height)
    }
}

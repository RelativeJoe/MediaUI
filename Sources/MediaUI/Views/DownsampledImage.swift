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
        }else {
            placeholder
                .onAppear {
                    Task.detached(priority: .background) {
                        let rawImage = image ?? UNImage(data: data ?? Data())
                        guard let rawImage = rawImage else {return}
                        image = rawImage.downsampledImage(width: width, height: height)
                    }
                }
        }
    }
}

//MARK: - Public Initializer
public extension DownsampledImage where Placeholder == Color  {
///MediaUI: Initialize a DownsampledImage from Data.
    init(data: Data?) {
        self.data = data
        self.placeholder = Color.clear
        self.width = nil
        self.height = nil
    }
///MediaUI: Initialize a DownsampledImage from a UNImage.
    init(image: UNImage?) {
        self._image = State(initialValue: image)
        self.placeholder = Color.clear
        self.width = nil
        self.height = nil
        self.data = nil
    }
}

//MARK: - Public Initializer
@available(iOS 16.0, macOS 13.0, *)
public extension DownsampledImage where Placeholder == Color {
///MediaUI: Initialize a DownsampledImage from Mediable.
    init(media: (any Mediable)?) {
        self.data = media?.data
        self.placeholder = Color.clear
        self.width = nil
        self.height = nil
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

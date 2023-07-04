//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/15/22.
//
import SwiftUI
import STools

///MediaUI: A DownsampledImage is a View that displays an Image in a Downsampled style.
public struct DownsampledImage: View {
//MARK: - Properties
    @State private var imageSize: CGSize?
    @State private var oldImage: UNImage?
    @State private var height: CGFloat?
    @State private var width: CGFloat?
    private var data: Data?
    private var dynamicSize = true
    private let placeHolder: AnyView?
    private let squared: Bool
    private let resizable: Bool
    private let aspectRatio: (CGFloat?, ContentMode)?
    private let onSize: ((CGSize) -> Void)?
//MARK: - View
    public var body: some View {
        content
            .clipped()
            .state(dynamicSize) { view in
                view
                    .onSizeChange { size in
                        height = size.height
                        width = size.width
                    }
            }.onTask(priority: .background) {
                guard let data else {return}
                oldImage = UNImage(data: data)
            }.change(of: imageSize) { newValue in
                guard let newValue else {return}
                onSize?(newValue)
            }
    }
    @ViewBuilder var content: some View {
        if let oldImage = oldImage {
            if let width = width, let height = height, let image = oldImage.downsampledImage(maxWidth: width, maxHeight: height) {
                let maxDimensions = image.maxDimensions(width: width, height: height)
                viewForImage(image)
                    .imageFrame(width: maxDimensions.width, height: maxDimensions.height, masterWidth: width, masterHeight: height, master: squared, size: $imageSize)
            }else if let width = width, let image = oldImage.downsampledImage(width: width) {
                viewForImage(image)
                    .imageFrame(width: width, height: image.fitHeight(for: width), masterWidth: width, masterHeight: height, master: squared, size: $imageSize)
            }else if let height = height, let image = oldImage.downsampledImage(height: height) {
                viewForImage(image)
                    .imageFrame(width: image.fitWidth(for: height), height: height, masterWidth: width, masterHeight: height, master: squared, size: $imageSize)
            }else {
                placeHolder ?? AnyView(Color.clear)
            }
        }else {
            placeHolder ?? AnyView(Color.clear)
        }
    }
}

//MARK: - Public Initializer
public extension DownsampledImage {
///MediaUI: Initialize a DownsampledImage from Data, & some optional settings.
    init(data: Data?, settings: ImageSettings = ImageSettings()) {
        self._oldImage = State(wrappedValue: nil)
        self._height = State(wrappedValue: settings.height)
        self._width = State(wrappedValue: settings.width)
        if settings.height != nil || settings.width != nil {
            self.dynamicSize = false
        }
        self.data = data
        self.squared = settings.squared
        self.aspectRatio = settings.aspectRatio
        self.resizable = settings.resizable
        self.placeHolder = settings.placeHolder
        self.onSize = settings.onSize
    }
///MediaUI: Initialize a DownsampledImage from a UNImage, & some optional settings.
    init(image: UNImage?, settings: ImageSettings = ImageSettings()) {
        self._oldImage = State(wrappedValue: image)
        self._height = State(wrappedValue: settings.height)
        self._width = State(wrappedValue: settings.width)
        self.data = nil
        self.squared = settings.squared
        self.aspectRatio = settings.aspectRatio
        self.resizable = settings.resizable
        self.placeHolder = settings.placeHolder
        if settings.height != nil || settings.width != nil {
            self.dynamicSize = false
        }
        self.onSize = settings.onSize
    }
}

//MARK: - Public Initializer
@available(iOS 16.0, macOS 13.0, *)
public extension DownsampledImage {
///MediaUI: Initialize a DownsampledImage from Mediable, & some optional settings.
    init(media: (any Mediable)?, settings: ImageSettings = ImageSettings()) {
        self._oldImage = State(initialValue: nil)
        self._height = State(initialValue: settings.height)
        self._width = State(initialValue: settings.width)
        self.data = media?.data
        self.squared = settings.squared
        self.aspectRatio = settings.aspectRatio
        self.resizable = settings.resizable
        self.placeHolder = settings.placeHolder
        if settings.height != nil || settings.width != nil {
            self.dynamicSize = false
        }
        self.onSize = settings.onSize
    }
}

//MARK: - Internal Initializer
internal extension DownsampledImage {
    init(data: Data?, image: UNImage?, height: CGFloat?, width: CGFloat?, squared: Bool, aspectRatio: (CGFloat?, ContentMode)?, resizable: Bool, content: AnyView?, onSize: ((CGSize) -> Void)?) {
        self._oldImage = State(initialValue: image)
        self._height = State(initialValue: height)
        self._width = State(initialValue: width)
        if height != nil || width != nil {
            self.dynamicSize = false
        }
        self.data = data
        self.squared = squared
        self.aspectRatio = aspectRatio
        self.placeHolder = content
        self.resizable = resizable
        self.onSize = onSize
    }
}

//MARK: - Private Functions
private extension DownsampledImage {
    @ViewBuilder func viewForImage(_ unImage: UNImage) -> some View {
        Image(unImage: unImage)
            .state(resizable) { image in
                image
                    .resizable()
            }.state(aspectRatio != nil) { view in
                view
                    .aspectRatio(aspectRatio?.0, contentMode: aspectRatio!.1)
            }
    }
}

//MARK: - Public Modifiers
public extension DownsampledImage {
///DownsampledImage: Make the Image take the Shape of a square.
    func squaredImage() -> Self {
        DownsampledImage(data: data, image: oldImage, height: height, width: width, squared: true, aspectRatio: (nil, .fill), resizable: resizable, content: placeHolder, onSize: onSize)
    }
///DownsampledImage: Sets the mode by which SwiftUI resizes an Image to fit it's space.
    func isResizable() -> Self {
        DownsampledImage(data: data, image: oldImage, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: true, content: placeHolder, onSize: onSize)
    }
///DownsampledImage: Constrains this View's dimesnions to the specified aspect rario.
    func aspect(_ ratio: CGFloat? = nil, contentMode: ContentMode) -> Self {
        DownsampledImage(data: data, image: oldImage, height: height, width: width, squared: squared, aspectRatio: (ratio, contentMode), resizable: resizable, content: placeHolder, onSize: onSize)
    }
///DownsampledImage: Positions this View within an invisible frame with the specified size.
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self  {
        DownsampledImage(data: data, image: oldImage, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, content: placeHolder, onSize: onSize)
    }
///DownsampledImage: Adds a placeholder View if no Image can be displayed.
    func placeHolder(@ViewBuilder placeholder: () -> some View) -> Self {
        DownsampledImage(data: data, image: oldImage, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, content: AnyView(placeholder()), onSize: onSize)
    }
    func imageSize(_ onSize: ((CGSize) -> Void)?) -> Self {
        DownsampledImage(data: data, image: oldImage, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, content: placeHolder, onSize: onSize)
    }
}

private extension View {
    @ViewBuilder func imageFrame(width: CGFloat, height: CGFloat, masterWidth: CGFloat? = nil, masterHeight: CGFloat? = nil, master: Bool, size: Binding<CGSize?>) -> some View {
        self
            .frame(width: master ? (masterWidth ?? width): width, height: master ? (masterHeight ?? height): height)
            .onAppear {
                size.wrappedValue = CGSize(width: master ? (masterWidth ?? width): width, height: master ? (masterHeight ?? height): height)
            }
    }
}

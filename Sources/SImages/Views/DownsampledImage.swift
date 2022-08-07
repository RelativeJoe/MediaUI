//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/15/22.
//
import SwiftUI
import STools

//MARK: - Public Initializer
public struct DownsampledImage<Content: View>: View {
    @Binding private var height: CGFloat?
    @Binding private var oldImage: UNImage?
    @Binding private var width: CGFloat?
    private let placeHolder: Content?
    private let squared: Bool
    private let resizable: Bool
    private let aspectRatio: (CGFloat?, ContentMode)?
    public var body: some View {
        if let oldImage = oldImage {
            if let width = width, let height = height, let image = oldImage.downsampledImage(maxWidth: width, maxHeight: height) {
                viewForImage(image)
                    .framey(width: image.maxDimensions(width: width, height: height).width, height: image.maxDimensions(width: width, height: height).height, masterWidth: self.width, masterHeight: self.height, master: squared)
            }else if let width = width, let image = oldImage.downsampledImage(width: width) {
                viewForImage(image)
                    .framey(width: width, height: image.fitHeight(for: width), masterWidth: self.width, masterHeight: self.height, master: squared)
            }else if let height = height, let image = oldImage.downsampledImage(height: height) {
                viewForImage(image)
                    .framey(width: image.fitWidth(for: height), height: height, masterWidth: self.width, masterHeight: self.height, master: squared)
            }else {
                placeHolder
            }
        }else {
            placeHolder
        }
    }
}

//MARK: - Public Initializer
public extension DownsampledImage {
    ///DownsampledImage: A DownsampledImage is a View that displays an Image in a Downsampled style.
    init(image: AnyBinding<UNImage>) {
        self._oldImage = image.value
        self._height = .constant(nil)
        self._width = .constant(nil)
        self.squared = false
        self.aspectRatio = nil
        self.resizable = false
        self.placeHolder = nil
    }
}

//MARK: - Private Initializer
private extension DownsampledImage {
    init(image: AnyBinding<UNImage>, height: AnyBinding<CGFloat> = .wrapped(nil), width: AnyBinding<CGFloat> = .wrapped(nil), squared: Bool = false, aspectRatio: (CGFloat?, ContentMode)?, resizable: Bool, @ViewBuilder content: () -> Content? = {nil}) {
        self._oldImage = image.value
        self._height = height.value
        self._width = width.value
        self.squared = squared
        self.aspectRatio = aspectRatio
        self.placeHolder = content()
        self.resizable = resizable
    }
}

//MARK: - Private Functions
private extension DownsampledImage {
    @ViewBuilder func viewForImage(_ unImage: UNImage) -> some View {
        Image(unImage: unImage)
            .stateModifier(.constant(resizable)) { image in
                image
                    .resizable()
            }.stateModifier(.constant(aspectRatio != nil)) { view in
                view
                    .aspectRatio(aspectRatio?.0, contentMode: aspectRatio!.1)
            }
    }
}

//MARK: - Public Modifiers
public extension DownsampledImage {
///DownsampledImage: Make the Image take the Shape of a square.
    func squaredImage() -> Self {
        return DownsampledImage(image: .binding($oldImage), height: .binding($height), width: .binding($width), squared: true, aspectRatio: aspectRatio, resizable: resizable) {
            placeHolder
        }
    }
///DownsampledImage: Sets the mode by which SwiftUI resizes an Image to fit it's space.
    func isResizable() -> Self {
        return DownsampledImage(image: .binding($oldImage), height: .binding($height), width: .binding($width), squared: squared, aspectRatio: aspectRatio, resizable: true) {
            placeHolder
        }
    }
///DownsampledImage: Constrains this View's dimesnions to the specified aspect rario.
    func aspect(_ ratio: CGFloat? = nil, contentMode: ContentMode) -> Self {
        return DownsampledImage(image: .binding($oldImage), height: .binding($height), width: .binding($width), squared: squared, aspectRatio: (ratio, contentMode), resizable: resizable) {
            placeHolder
        }
    }
///DownsampledImage: Positions this View within an invisible frame with the specified size.
    func frame(width: AnyBinding<CGFloat> = .wrapped(nil), height: AnyBinding<CGFloat> = .wrapped(nil)) -> Self  {
        return DownsampledImage(image: .binding($oldImage), height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable) {
            placeHolder
        }
    }
///DownsampledImage: Adds a placeholder View if no Image can be displayed.
    func placeHolder(@ViewBuilder placeholder: () -> Content) -> Self {
        return DownsampledImage(image: .binding($oldImage), height: .binding($height), width: .binding($width), squared: squared, aspectRatio: aspectRatio, resizable: resizable) {
            placeholder()
        }
    }
}

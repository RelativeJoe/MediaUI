//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/15/22.
//
import SwiftUI
import STools

public struct DownsampledImage<Content: View>: View {
    @Binding var height: CGFloat?
    @Binding var oldImage: UNImage?
    @Binding var width: CGFloat?
    let placeHolder: Content?
    let squared: Bool
    let resizable: AnyBinding<Bool>?
    let aspectRatio: (CGFloat?, ContentMode)?
    public init(image: AnyBinding<UNImage>) {
        self._oldImage = image.value
        self._height = .constant(nil)
        self._width = .constant(nil)
        self.squared = false
        self.aspectRatio = nil
        self.resizable = nil
        self.placeHolder = nil
    }
    init(image: AnyBinding<UNImage>, height: AnyBinding<CGFloat> = .wrapped(nil), width: AnyBinding<CGFloat> = .wrapped(nil), squared: Bool = false, aspectRatio: (CGFloat?, ContentMode)?, resizable: AnyBinding<Bool>?, @ViewBuilder content: () -> Content? = {EmptyView()}) {
        self._oldImage = image.value
        self._height = height.value
        self._width = width.value
        self.squared = squared
        self.aspectRatio = aspectRatio
        self.placeHolder = content()
        self.resizable = resizable
    }
    public var body: some View {
        if let oldImage {
            if let width, let height, let image = oldImage.downsampledImage(maxWidth: width, maxHeight: height) {
                viewForImage(image)
                    .framey(width: image.maxDimensions(width: width, height: height).width, height: image.maxDimensions(width: width, height: height).height, masterWidth: self.width, masterHeight: self.height, master: squared)
            }else if let width, let image = oldImage.downsampledImage(width: width) {
                viewForImage(image)
                    .framey(width: width, height: image.fitHeight(for: width), masterWidth: self.width, masterHeight: self.height, master: squared)
            }else if let height, let image = oldImage.downsampledImage(height: height) {
                viewForImage(image)
                    .framey(width: image.fitWidth(for: height), height: height, masterWidth: self.width, masterHeight: self.height, master: squared)
            }else {
                placeHolder
            }
        }else {
            placeHolder
        }
    }
    @ViewBuilder func viewForImage(_ unImage: UNImage) -> some View {
        let binding = Binding(get: {
            return resizable?.wrappedValue ?? false
        }, set: { newValue in
            resizable?.value.wrappedValue = newValue
        })
        Image(unImage: unImage)
            .stateModifier(binding) { image in
                image.resizable()
            }.stateModifier(.constant(aspectRatio != nil)) { view in
                view.aspectRatio(aspectRatio?.0, contentMode: aspectRatio!.1)
            }
    }
    public func squaredImage() -> DownsampledImage {
        return DownsampledImage(image: .binding($oldImage), height: .binding($height), width: .binding($width), squared: true, aspectRatio: aspectRatio, resizable: resizable) {
            placeHolder
        }
    }
    public func resizable(_ resize: AnyBinding<Bool>) -> DownsampledImage {
        return DownsampledImage(image: .binding($oldImage), height: .binding($height), width: .binding($width), squared: squared, aspectRatio: aspectRatio, resizable: resize) {
            placeHolder
        }
    }
    public func aspectRatio(_ ratio: CGFloat, contentMode: ContentMode) -> DownsampledImage {
        return DownsampledImage(image: .binding($oldImage), height: .binding($height), width: .binding($width), squared: squared, aspectRatio: (ratio, contentMode), resizable: resizable) {
            placeHolder
        }
    }
    public func frame(width: AnyBinding<CGFloat> = .wrapped(nil), height: AnyBinding<CGFloat> = .wrapped(nil)) -> DownsampledImage  {
        return DownsampledImage(image: .binding($oldImage), height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable) {
            placeHolder
        }
    }
    public func placeHolder(@ViewBuilder placeholder: () -> Content) -> DownsampledImage {
        return DownsampledImage(image: .binding($oldImage), height: .binding($height), width: .binding($width), squared: squared, aspectRatio: aspectRatio, resizable: resizable) {
            placeholder()
        }
    }
}

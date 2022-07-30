//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/17/22.
//
import SwiftUI
import PhotosUI
import STools

@available(iOS 16.0, macOS 13.0, *)
struct MediaImage<Content: View, Media: Mediabley>: View {
    @Binding var height: CGFloat?
    @Binding var mediable: Media
    @Binding var width: CGFloat?
    @State var presentable = PresentableMedia()
    let placeHolder: Content?
    let squared: Bool
    let resizable: AnyBinding<Bool>?
    let aspectRatio: (CGFloat?, ContentMode)?
    public init(mediable: AnyBinding<Media>) {
        self._mediable = mediable.unwrappedValue(defaultValue: Media.empty)
        self._height = .constant(nil)
        self._width = .constant(nil)
        self.squared = false
        self.aspectRatio = nil
        self.resizable = nil
        self.placeHolder = nil
    }
    init(mediable: AnyBinding<Media>, height: AnyBinding<CGFloat> = .wrapped(nil), width: AnyBinding<CGFloat> = .wrapped(nil), squared: Bool = false, aspectRatio: (CGFloat?, ContentMode)?, resizable: AnyBinding<Bool>?, @ViewBuilder content: () -> Content? = {EmptyView()}) {
        self._mediable = mediable.unwrappedValue(defaultValue: .empty)
        self._height = height.value
        self._width = width.value
        self.squared = squared
        self.aspectRatio = aspectRatio
        self.placeHolder = content()
        self.resizable = resizable
    }
    var body: some View {
        VStack {
            Button(action: {
                presentable.isPresented.toggle()
            }) {
                if let mediable, mediable.data != Data() {
                    image(for: AnyImage(mediable.data))
                }else {
                    switch presentable.mediaState {
                        case .failure(let error):
                            Text(error.localizedDescription)
                        case .loading:
                            ProgressView()
                        case .success(let anyImage):
                            image(for: anyImage)
                        default:
                            placeHolder
                    }
                }
            }
        }.photosPicker(isPresented: $presentable.isPresented, selection: $presentable.pickerItem, matching: .images)
        .onChange(of: presentable.pickerItem) { newValue in
            updateState(pickerItem: newValue)
        }
    }
//MARK: - Functions
    func image(for anyImage: AnyImage?) -> some View {
        Group {
            if let oldImage = anyImage?.unImage {
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
    }
    func updateState(pickerItem: PhotosPickerItem?) {
        presentable.mediaState = .loading
        guard let pickerItem else {return}
        Task {
            do {
                guard let image = try await pickerItem.loadTransferable(type: Data.self) else {
                    return
                }
                DispatchQueue.main.async { [self] in
                    withAnimation() {
                        self.mediable.data = image
                        self.presentable.mediaState = .success(AnyImage(image))
                    }
                }
            }catch {
                DispatchQueue.main.async { [self] in
                    withAnimation() {
                        self.presentable.mediaState = .failure(error)
                    }
                }
            }
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
    public func squaredImage() -> MediaImage {
        return MediaImage(mediable: .binding($mediable), height: .binding($height), width: .binding($width), squared: true, aspectRatio: aspectRatio, resizable: resizable) {
            placeHolder
        }
    }
    public func resizable(_ resize: AnyBinding<Bool>) -> MediaImage {
        return MediaImage(mediable: .binding($mediable), height: .binding($height), width: .binding($width), squared: squared, aspectRatio: aspectRatio, resizable: resize) {
            placeHolder
        }
    }
    public func aspectRatio(_ ratio: CGFloat, contentMode: ContentMode) -> MediaImage {
        return MediaImage(mediable: .binding($mediable), height: .binding($height), width: .binding($width), squared: squared, aspectRatio: (ratio, contentMode), resizable: resizable) {
            placeHolder
        }
    }
    public func frame(width: AnyBinding<CGFloat> = .wrapped(nil), height: AnyBinding<CGFloat> = .wrapped(nil)) -> MediaImage  {
        return MediaImage(mediable: .binding($mediable), height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable) {
            placeHolder
        }
    }
    public func placeHolder(@ViewBuilder placeholder: () -> Content) -> MediaImage {
        return MediaImage(mediable: .binding($mediable), height: .binding($height), width: .binding($width), squared: squared, aspectRatio: aspectRatio, resizable: resizable) {
            placeholder()
        }
    }
}


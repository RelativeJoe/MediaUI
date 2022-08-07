//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/17/22.
//
#if canImport(Charts)
import SwiftUI
import PhotosUI
import STools

///SImages: A MediaImage is a View that displays a default Image which can be tapped in order to present a PhotosPicker & dynamically display the picked Image in a Downsampled style.
@available(iOS 16.0, macOS 13.0, *)
public struct MediaImage<Content: View, Media: Mediabley>: View {
    @EnvironmentObject private var configurations: PhotosPickerConfigurations
    @Binding private var height: CGFloat?
    @Binding private var mediable: Media
    @Binding private var width: CGFloat?
    @State private var presentable = PresentableMedia()
    private let placeHolder: Content?
    private let squared: Bool
    private let resizable: Bool
    private let aspectRatio: (CGFloat?, ContentMode)?
    private let disabledPicker: Bool
    private let id: String
    public var body: some View {
        Button(action: {
            presentable.isPresented.toggle()
        }) {
            if let mediable = mediable, mediable.data != Data() {
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
        }.disabled(disabledPicker)
        .multiPhotosPicker(id: id, isPresented: $presentable.isPresented, maxSelectionCount: 1, matching: .images)
        .pickerItem { newValue in
            updateState(pickerItem: newValue)
        }
    }
}

//MARK: - Public Initializer
@available(iOS 16.0, macOS 13.0, *)
public extension MediaImage {
///SImages: Initialize a DownsampledImage from a Mediabley, or a Binding one.
    init(mediable: Binding<Media>) {
        self._mediable = mediable
        self._height = .constant(nil)
        self._width = .constant(nil)
        self.squared = false
        self.aspectRatio = nil
        self.resizable = false
        self.placeHolder = nil
        self.disabledPicker = false
        self.id = UUID().uuidString
    }
}

//MARK: - Private Initializer
@available(iOS 16.0, macOS 13.0, *)
private extension MediaImage {
    init(id: String, mediable: Binding<Media>, height: AnyBinding<CGFloat> = .wrapped(nil), width: AnyBinding<CGFloat> = .wrapped(nil), squared: Bool = false, aspectRatio: (CGFloat?, ContentMode)?, resizable: Bool, disabled: Bool, @ViewBuilder content: () -> Content? = {EmptyView()}) {
        self._mediable = mediable
        self._height = height.value
        self._width = width.value
        self.squared = squared
        self.aspectRatio = aspectRatio
        self.placeHolder = content()
        self.resizable = resizable
        self.disabledPicker = disabled
        self.id = id
    }
}

//MARK: - Private Functions
@available(iOS 16.0, macOS 13.0, *)
private extension MediaImage {
    @ViewBuilder func image(for anyImage: AnyImage?) -> some View {
        if let oldImage = anyImage?.unImage {
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
    func updateState(pickerItem: PhotosPickerItem?) {
        presentable.mediaState = .loading
        guard let pickerItem = pickerItem else {return}
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
@available(iOS 16.0, macOS 13.0, *)
public extension MediaImage {
///MediaImage: Make the Image take the Shape of a square.
    func squaredImage() -> Self {
        MediaImage(id: id, mediable: $mediable, height: .binding($height), width: .binding($width), squared: true, aspectRatio: aspectRatio, resizable: resizable, disabled: disabledPicker) {
            placeHolder
        }
    }
////MediaImage: Sets the mode by which SwiftUI resizes an Image to fit it's space.
    func isResizable() -> Self {
        MediaImage(id: id, mediable: $mediable, height: .binding($height), width: .binding($width), squared: squared, aspectRatio: aspectRatio, resizable: true, disabled: disabledPicker) {
            placeHolder
        }
    }
///MediaImage: Constrains this View's dimesnions to the specified aspect rario.
    func aspect(_ ratio: CGFloat? = nil, contentMode: ContentMode) -> Self {
        MediaImage(id: id, mediable: $mediable, height: .binding($height), width: .binding($width), squared: squared, aspectRatio: (ratio, contentMode), resizable: resizable, disabled: disabledPicker) {
            placeHolder
        }
    }
///MediaImage: Positions this View within an invisible frame with the specified size.
    func frame(width: AnyBinding<CGFloat> = .wrapped(nil), height: AnyBinding<CGFloat> = .wrapped(nil)) -> Self {
        MediaImage(id: id, mediable: $mediable, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, disabled: disabledPicker) {
            placeHolder
        }
    }
///MediaImage: Adds a placeholder View if no Image can be displayed.
    func placeHolder(@ViewBuilder placeholder: () -> Content) -> Self {
        MediaImage(id: id, mediable: $mediable, height: .binding($height), width: .binding($width), squared: squared, aspectRatio: aspectRatio, resizable: resizable, disabled: disabledPicker) {
            placeholder()
        }
    }
///MediaImage: Disables the PhotosPicker button.
    func disabledPicker(_ disabled: Bool = true) -> Self {
        MediaImage(id: id, mediable: $mediable, height: .binding($height), width: .binding($width), squared: squared, aspectRatio: aspectRatio, resizable: resizable, disabled: disabled) {
            placeHolder
        }
    }
///MediaImage: Set the PhotosPicker id of the view.
    func set(id: CustomStringConvertible) -> Self {
        MediaImage(id: id.description, mediable: $mediable, height: .binding($height), width: .binding($width), squared: squared, aspectRatio: aspectRatio, resizable: resizable, disabled: disabledPicker) {
            placeHolder
        }
    }
}
#endif

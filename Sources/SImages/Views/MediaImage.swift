//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/17/22.
//

import SwiftUI
import PhotosUI
import STools

///SImages: A MediaImage is a View that displays a default Image which can be tapped in order to present a PhotosPicker & dynamically display the picked Image in a Downsampled style.
@available(iOS 16.0, macOS 13.0, *)
public struct MediaImage<Media: Mediabley>: View {
    @EnvironmentObject private var configurations: PhotosPickerConfigurations
    @Binding private var mediable: Media
    @State private var presentable = PresentableMedia()
    private var width: CGFloat?
    private var height: CGFloat?
    private let placeHolder: AnyView?
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
                DownsampledImage(image: AnyImage(mediable.data).unImage, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, content: placeHolder)
            }else {
                switch presentable.mediaState {
                    case .failure(let error):
                        Text(error.localizedDescription)
                    case .loading:
                        ProgressView()
                    case .success(let anyImage):
                        DownsampledImage(image: anyImage.unImage, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, content: placeHolder)
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
        self.height = nil
        self.width = nil
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
    init(id: String, mediable: Binding<Media>, height: CGFloat?, width: CGFloat?, squared: Bool, aspectRatio: (CGFloat?, ContentMode)?, resizable: Bool, disabled: Bool, content: AnyView?) {
        self._mediable = mediable
        self.height = height
        self.width = width
        self.squared = squared
        self.aspectRatio = aspectRatio
        self.placeHolder = content
        self.resizable = resizable
        self.disabledPicker = disabled
        self.id = id
    }
}

//MARK: - Private Functions
@available(iOS 16.0, macOS 13.0, *)
private extension MediaImage {
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
            .stateModifier(resizable) { image in
                image
                    .resizable()
            }.stateModifier(aspectRatio != nil) { view in
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
        MediaImage(id: id, mediable: $mediable, height: height, width: width, squared: true, aspectRatio: aspectRatio, resizable: resizable, disabled: disabledPicker, content: placeHolder)
    }
////MediaImage: Sets the mode by which SwiftUI resizes an Image to fit it's space.
    func isResizable() -> Self {
        MediaImage(id: id, mediable: $mediable, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: true, disabled: disabledPicker, content: placeHolder)
    }
///MediaImage: Constrains this View's dimesnions to the specified aspect rario.
    func aspect(_ ratio: CGFloat? = nil, contentMode: ContentMode) -> Self {
        MediaImage(id: id, mediable: $mediable, height: height, width: width, squared: squared, aspectRatio: (ratio, contentMode), resizable: resizable, disabled: disabledPicker, content: placeHolder)
    }
///MediaImage: Positions this View within an invisible frame with the specified size.
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        MediaImage(id: id, mediable: $mediable, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, disabled: disabledPicker, content: placeHolder)
    }
///MediaImage: Adds a placeholder View if no Image can be displayed.
    func placeHolder(@ViewBuilder placeholder: () -> some View) -> Self {
        MediaImage(id: id, mediable: $mediable, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, disabled: disabledPicker, content: AnyView(placeholder()))
    }
///MediaImage: Disables the PhotosPicker button.
    func disabledPicker(_ disabled: Bool = true) -> Self {
        MediaImage(id: id, mediable: $mediable, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, disabled: disabled, content: placeHolder)
    }
///MediaImage: Set the PhotosPicker id of the view.
    func set(id: CustomStringConvertible) -> Self {
        MediaImage(id: id.description, mediable: $mediable, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, disabled: disabledPicker, content: placeHolder)
    }
}

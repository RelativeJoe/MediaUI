//
//  MediaPickerViewModifier.swift
//  
//
//  Created by Joe Maghzal on 06/03/2023.
//

import SwiftUI
import STools

@available(iOS 16.0, macOS 13.0, *)
struct MediaPickerViewModifier: ViewModifier {
    @MediaPicker(\.multiple) var picker
    @StateObject var pickerData = MediaPickerData.shared
    func body(content: Content) -> some View {
        content
            .state(pickerData.mode == .multiple) { view in
                view
                    .photosPicker(isPresented: $pickerData.isPresented, selection: $pickerData.multiSelection, photoLibrary: .shared())
            }.state(pickerData.mode == .single) { view in
                view
                    .photosPicker(isPresented: $pickerData.isPresented, selection: $pickerData.singleSelection, photoLibrary: .shared())
            }.onChange(of: pickerData.selectionFinished) { newValue in
                pickerData.reset()
            }
    }
}

@available(iOS 16.0, macOS 13.0, *)
public extension View {
    func attachPicker() -> some View {
        modifier(MediaPickerViewModifier())
    }
}

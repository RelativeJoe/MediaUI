//
//  File.swift
//  
//
//  Created by Joe Maghzal on 06/03/2023.
//

import SwiftUI

@available(iOS 16.0, *)
struct MediaPickerModifier: ViewModifier {
    @MediaPicker(\.multiple) var picker
    @StateObject var pickerData = MediaPickerData.shared
    func body(content: Content) -> some View {
        content
            .stateModifier(pickerData.mode == .multiple) { view in
                view
                    .photosPicker(isPresented: $pickerData.isPresented, selection: $pickerData.multiSelection, photoLibrary: .shared())
            }.stateModifier(pickerData.mode == .single) { view in
                view
                    .photosPicker(isPresented: $pickerData.isPresented, selection: $pickerData.singleSelection, photoLibrary: .shared())
            }.onChange(of: pickerData.selectionFinished) { newValue in
                pickerData.reset()
            }
    }
}

@available(iOS 16.0, *)
extension View {
    func attachPicker() -> some View {
        modifier(MediaPickerModifier())
    }
}

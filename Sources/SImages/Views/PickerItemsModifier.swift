//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/7/22.
//

import SwiftUI
import PhotosUI

#if canImport(Charts)
@available(iOS 16.0, *)
public extension View {
    @ViewBuilder func pickerItems(_ action: @escaping ([PhotosPickerItem]) -> Void) -> some View {
        self.modifier(PhotoPickerItemModifier(action: action))
    }
}

@available(iOS 16.0, *)
struct PhotoPickerItemModifier: ViewModifier {
    @EnvironmentObject var configurations: PhotosPickerConfigurations
//    @Environment(\.configurations) var configurations
    @Environment(\.photosPickerId) var id
    let action: ([PhotosPickerItem]) -> Void
    func body(content: Content) -> some View {
        content
            .onChange(of: configurations.pickerItems) { newValuey in
                guard let newValue = newValuey[PhotosPickerID.mediaSet.rawValue], !newValue.isEmpty else {return}
                action(newValue)
                configurations.pickerItems[id]?.removeAll()
            }
    }
}
#endif

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
internal struct PhotoPickerItemModifier: ViewModifier {
    @EnvironmentObject private var configurations: PhotosPickerConfigurations
    private let id: String
    private let action: (([PhotosPickerItem]) -> Void)?
    private let singleAction: ((PhotosPickerItem?) -> Void)?
    internal func body(content: Content) -> some View {
        content
            .onChange(of: configurations.pickerItems) { newValuey in
                guard let newValue = newValuey[id], !newValue.isEmpty else {return}
                singleAction?(newValue.first)
                action?(newValue)
                configurations.pickerItems[id]?.removeAll()
            }
    }
}

//MARK: - Private Initializer
@available(iOS 16.0, *)
internal extension PhotoPickerItemModifier {
    init(_ id: String, action: (([PhotosPickerItem]) -> Void)? = nil, singleAction: ((PhotosPickerItem?) -> Void)? = nil) {
        self.action = action
        self.singleAction = singleAction
        self.id = id
    }
}
#endif

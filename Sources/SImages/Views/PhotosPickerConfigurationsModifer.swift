//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/7/22.
//

import SwiftUI

#if canImport(Charts)//remove after iOS 16 goes public
@available(iOS 16.0, macOS 13.0, *)
internal struct PhotosPickerConfigurationsModifer: ViewModifier {
    @Environment(\.configurations) private var configurations
    internal func body(content: Content) -> some View {
        if configurations == nil {
            content
                .environment(\.configurations, PhotosPickerConfigurations())
                .environmentObject(PhotosPickerConfigurations())
        }else {
            content
        }
    }
}
#endif

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
struct PhotosPickerConfigurationsKey: EnvironmentKey {
    static let defaultValue: PhotosPickerConfigurations? = nil
}

@available(iOS 16.0, *)
struct PhotosPickerIDKey: EnvironmentKey {
    static let defaultValue = ""
}

@available(iOS 16.0, *)
struct PhotosPickerPresentingIDKey: EnvironmentKey {
    static let defaultValue = ""
}

@available(iOS 16.0, *)
extension EnvironmentValues {
    var configurations: PhotosPickerConfigurations? {
        get {
            self[PhotosPickerConfigurationsKey.self]
        }
        set {
            self[PhotosPickerConfigurationsKey.self] = newValue
        }
    }
    var photosPickerId: String {
        get {
            self[PhotosPickerIDKey.self]
        }
        set {
            self[PhotosPickerIDKey.self] = newValue
        }
    }
    var photosPickerPresentingId: String {
        get {
            self[PhotosPickerPresentingIDKey.self]
        }
        set {
            self[PhotosPickerPresentingIDKey.self] = newValue
        }
    }
}

@available(iOS 16.0, *)
public extension View {
    @ViewBuilder func photosPickerConfigurations() -> some View {
        self.modifier(PhotosPickerConfigurationsModifer())
    }
    @ViewBuilder func photosPickerId<Value: CustomStringConvertible>(_ id: Value, isPresented: Binding<Bool>) -> some View {
        environment(\.photosPickerId, id.description)
        if isPresented.wrappedValue {
            environment(\.photosPickerPresentingId, id.description)
        }
    }
}

@available(iOS 16.0, *)
struct PhotosPickerConfigurationsModifer: ViewModifier {
    @Environment(\.configurations) var configurations
    func body(content: Content) -> some View {
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


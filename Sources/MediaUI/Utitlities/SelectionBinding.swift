//
//  File.swift
//  
//
//  Created by Joe Maghzal on 06/03/2023.
//

import PhotosUI
import SwiftUI

public protocol SelectionBinding {
    associatedtype SelectionType
    var type: SelectionType.Type {get}
}

@available(iOS 16.0, macOS 13.0, *)
public struct SingleSelectionPickerBinding: SelectionBinding {
    public var type = PhotosPickerItem.self
    @MainActor public func presentPicker() throws {
        Task {
            try await MediaPickerData.shared.present(picker: .single)
        }
    }
    @MainActor public func pickedItem() async throws -> PhotosPickerItem {
        try await MediaPickerData.shared.pickedItem()
    }
}


@available(iOS 16.0, macOS 13.0, *)
public struct MultipleSelectionPickerBinding: SelectionBinding {
    public var type = [PhotosPickerItem].self
///MediaUI: Presents the attached media picker. To get the picked items, use MediaPicker's projected value ($picker)
    @MainActor public func presentPicker() throws {
        Task {
            try await MediaPickerData.shared.present(picker: .multiple)
        }
    }
///MediaUI: Presents the attached media picker then returns the picked items.
    @MainActor public func pickedItems() async throws-> [PhotosPickerItem] {
        try await MediaPickerData.shared.pickedItems()
    }
}

@available(iOS 16.0, macOS 13.0, *)
public struct PickerValues {
    public var single = SingleSelectionPickerBinding()
    public var multiple = MultipleSelectionPickerBinding()
}

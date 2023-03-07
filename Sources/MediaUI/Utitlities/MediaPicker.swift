//
//  File.swift
//  
//
//  Created by Joe Maghzal on 06/03/2023.
//

import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
@propertyWrapper public struct MediaPicker<Value: SelectionBinding>: DynamicProperty {
    @StateObject var pickerData = MediaPickerData.shared
    var binding: Value
    public init(_ keyPath: KeyPath<PickerValues, Value>) {
        binding = PickerValues()[keyPath: keyPath]
    }
    public var wrappedValue: Value {
        get {
            binding
        }
    }
    public var projectedValue: Value.SelectionType {
        get {
            if binding.type == PhotosPickerItem.self {
                return pickerData.singleSelection as! Value.SelectionType
            }
            return pickerData.multiSelection as! Value.SelectionType
        }
    }
}

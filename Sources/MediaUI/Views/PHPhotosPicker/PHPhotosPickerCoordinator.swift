//
//  PHPhotosPickerCoordinator.swift
//  
//
//  Created by Joe Maghzal on 04/07/2023.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import Combine

@available(iOS 14.0, macOS 13.0, *)
public final class PHPhotosPickerCoordinator {
//MARK: - Properties
    @Binding private var isPresented: Bool
    @Binding private var pickerItems: [PHPickerResult]
//MARK: - Initializer
    internal init(isPresented: Binding<Bool>, pickerItems: Binding<[PHPickerResult]>) {
        self._isPresented = isPresented
        self._pickerItems = pickerItems
    }
}

//MARK: - PHPickerViewControllerDelegate
@available(iOS 14.0, macOS 13.0, *)
extension PHPhotosPickerCoordinator: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        isPresented.toggle()
    }
}

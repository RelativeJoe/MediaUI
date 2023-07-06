//
//  File.swift
//  
//
//  Created by Joe Maghzal on 06/03/2023.
//

import SwiftUI
import PhotosUI
import Combine

@available(iOS 16.0, macOS 13.0, *)
@MainActor public class MediaPickerData: ObservableObject {
//MARK: - Properties
    static internal let shared = MediaPickerData()
    private var cancellables: AnyCancellable?
//MARK: - Publishers
    @Published internal var mode: PickerMode?
    @Published internal var isPresented = false
    @Published internal var multiSelection = [PhotosPickerItem]()
    @Published internal var singleSelection: PhotosPickerItem?
    //MARK: - Mappings
    internal var selectionFinished: Bool {
        return !multiSelection.isEmpty || singleSelection != nil
    }
//MARK: - Functions
    internal func present(picker mode: PickerMode) async throws {
        guard !isPresented else {
            throw MediaError.pickerAlreadyPresented
        }
        self.mode = mode
        try? await Task.sleep(nanoseconds: 1_000)
        isPresented.toggle()
    }
    internal func pickedItem() async throws -> PhotosPickerItem {
        try await present(picker: .single)
        return await withCheckedContinuation { continuation in
            cancellables = $singleSelection
                .compactMap({$0})
                .sink { singleSelection in
                    continuation.resume(returning: singleSelection)
                }
        }
    }
    internal func pickedItems() async throws -> [PhotosPickerItem] {
        try await present(picker: .multiple)
        return await withCheckedContinuation { continuation in
            cancellables = $multiSelection
                .drop(while: {$0.isEmpty})
                .sink { multiSelection in
                    continuation.resume(returning: multiSelection)
                }
        }
    }
    internal func reset() {
        mode = nil
        cancellables = nil
    }
}

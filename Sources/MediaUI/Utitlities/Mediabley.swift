//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/17/22.
//

import SwiftUI
import PhotosUI

///MediaUI: Conform your media model to Mediabley in order for it to be used alongside PhotosPicker.
@available(iOS 16.0, macOS 13.0, *)
public protocol Mediable: Identifiable, Hashable, Equatable {
    var id: UUID? {get set}
    var data: Data {get set}
    static var empty: Self {get}
}

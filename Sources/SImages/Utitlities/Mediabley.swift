//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/17/22.
//

import SwiftUI
import PhotosUI

@available(iOS 16.0, macOS 13.0, *)
public protocol Mediabley: Identifiable, Hashable, Equatable {
    var id: UUID {get set}
    var data: Data {get set}
    static var empty: Self {get}
}

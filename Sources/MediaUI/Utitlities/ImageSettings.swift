//
//  File.swift
//  
//
//  Created by Joe Maghzal on 12/31/22.
//

import SwiftUI

public struct ImageSettings {
    internal var height: CGFloat? = nil
    internal var width: CGFloat? = nil
    internal var placeHolder: AnyView? = nil
    internal var squared = false
    internal var resizable = false
    internal var aspectRatio: (CGFloat?, ContentMode)? = nil
}

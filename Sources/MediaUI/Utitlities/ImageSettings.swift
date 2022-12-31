//
//  File.swift
//  
//
//  Created by Joe Maghzal on 12/31/22.
//

import SwiftUI

public struct ImageSettings {
//MARK: - Properties
    internal var height: CGFloat? = nil
    internal var width: CGFloat? = nil
    internal var placeHolder: AnyView? = nil
    internal var squared = false
    internal var resizable = false
    internal var aspectRatio: (CGFloat?, ContentMode)? = nil
//MARK: - Initianlizers
    public init() {
        height = nil
        width = nil
        placeHolder = nil
        squared = false
        resizable = false
        aspectRatio = nil
    }
    internal init(height: CGFloat? = nil, width: CGFloat? = nil, placeHolder: AnyView? = nil, squared: Bool = false, resizable: Bool = false, aspectRatio: (CGFloat?, ContentMode)? = nil) {
        self.height = height
        self.width = width
        self.placeHolder = placeHolder
        self.squared = squared
        self.resizable = resizable
        self.aspectRatio = aspectRatio
    }
}

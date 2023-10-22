//
//  SwiftUIView.swift
//  
//
//  Created by Joe Maghzal on 22/10/2023.
//

import SwiftUI

#if canImport(UIKit)
public typealias UNImage = UIImage
public typealias UNColor = UIColor
public typealias UNView = UIView
#elseif canImport(AppKit)
public typealias UNImage = NSImage
public typealias UNColor = NSColor
public typealias UNView = NSView
#endif

public typealias LoadingView = ProgressView<EmptyView, EmptyView>

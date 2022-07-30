//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/17/22.
//

import SwiftUI
import STools

public struct AnyImage: View {
//MARK: - Properties
    public static var empty = AnyImage()
    public var data: Data?
    public var image: Image?
    public var unImage: UNImage?
//MARK: - Private Initializers
    private init() {
    }
    public var body: some View {
        image ?? Image("photo.fill")
    }
}

//MARK: - Public Initializers
public extension AnyImage {
    init(_ data: Data?) {
        guard let data else {return}
        self.data = data
        self.unImage = UNImage(data: data)
        if let unImage {
            self.image = Image(unImage: unImage)
        }else {
            self.image = nil
        }
    }
    init(_ image: Image?) {
        guard let image else {return}
        self.image = image
        self.unImage = image.unImage
        self.data = unImage?.asData(.high)
    }
    init(_ unImage: UNImage?) {
        guard let unImage else {return}
        self.unImage = unImage
        self.image = Image(unImage: unImage)
        self.data = unImage.asData(.high)
    }
}

//MARK: - Equatable
extension AnyImage: Equatable {
    public static func ==(lhs: AnyImage, rhs: AnyImage) -> Bool {
        return lhs.data == rhs.data
    }
}

//MARK: - Hashable
extension AnyImage: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(data ?? Data())
    }
}

//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/30/22.
//

import SwiftUI
///MediaUI: Respresentation of the state of an image.
public enum MediaState {
    case empty, loading, success(AnyImage), failure(Error)
    public var id: Int {
        switch self {
            case .empty:
                return 0
            case .loading:
                return 1
            case .success:
                return 2
            case .failure:
                return 3
        }
    }
}

//MARK: - Equatable
extension MediaState: Equatable {
    public static func ==(lhs: MediaState, rhs: MediaState) -> Bool {
        return lhs.id == rhs.id
    }
}

//MARK: - Hashable
extension MediaState: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

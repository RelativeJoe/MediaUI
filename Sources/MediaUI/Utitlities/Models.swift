//
//  File.swift
//  
//
//  Created by Joe Maghzal on 08/02/2023.
//

import Foundation

public enum MediaError: Error, Equatable, Hashable, Codable {
    case unexpected, pickerAlreadyPresented, itemTypeError, itemTypeMismatch, invalidURL
    var localizedDescription: String {
        switch self {
            case .unexpected:
                return "An unexpected error occured!"
            case .pickerAlreadyPresented:
                return "The Photos picker is already presented!"
            case .itemTypeError:
                return "Could not load the Item type!"
            case .itemTypeMismatch:
                return "The expected item type did not match the actual item type!"
            case .invalidURL:
                return "Invalid Image URL!"
        }
    }
}

public enum PickerMode {
    case single, multiple
}

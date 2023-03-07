//
//  File.swift
//  
//
//  Created by Joe Maghzal on 08/02/2023.
//

import Foundation

public enum MediaError: Error, Equatable, Hashable, Codable {
    case unexpected, pickerAlreadyPresented
    var localizedDescription: String {
        switch self {
            case .unexpected:
                return "An unexpected error occured!"
            case .pickerAlreadyPresented:
                return "The Photos picker is already presented!"
        }
    }
}

public enum PickerMode {
    case single, multiple
}

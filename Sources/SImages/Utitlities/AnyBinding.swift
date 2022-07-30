//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/29/22.
//

import Foundation
import SwiftUI

public struct AnyBinding<Value> {
    var value: Binding<Value?> {
        get {
            guard self.bindingValue.wrappedValue != nil else {
                return Binding.constant(wrappedValue)
            }
            return self.bindingValue
        }
        set {
            bindingValue = newValue
        }
    }
    func unwrappedValue(defaultValue: Value) -> Binding<Value> {
            guard let value = self.bindingValue.wrappedValue else {
                return Binding(get: {
                    return wrappedValue ?? defaultValue
                }, set: { newValue in
                    self.bindingValue.wrappedValue = newValue
                })
            }
            return Binding(get: {
                return value
            }, set: { newValue in
                self.bindingValue.wrappedValue = newValue
            })
        }
    private var bindingValue: Binding<Value?>
    let wrappedValue: Value?
    init(bindingValue: Binding<Value?>? = .constant(nil), wrappedValue: Value? = nil) {
        self.wrappedValue = wrappedValue
        self.bindingValue = bindingValue ?? .constant(nil)
    }
    init(bindingNonNilValue: Binding<Value>? = nil) {
        self.wrappedValue = nil
        let binding = Binding<Value?> {
            return bindingNonNilValue?.wrappedValue
        } set: { newValue in
            guard let newValue else {return}
            bindingNonNilValue?.wrappedValue = newValue
        }
        self.bindingValue = binding
    }
    static public func binding(_ bindingValue: Binding<Value?>?) -> AnyBinding {
        return AnyBinding(bindingValue: bindingValue)
    }
    static public func binding(_ bindingValue: Binding<Value>?) -> AnyBinding {
        return AnyBinding(bindingNonNilValue: bindingValue)
    }
    static public func wrapped(_ wrappedValue: Value?) -> AnyBinding {
        return AnyBinding(wrappedValue: wrappedValue)
    }
}

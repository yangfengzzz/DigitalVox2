//
//  ShaderMacroCollection.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

extension MacroName:Hashable {}

/// Shader macro collection.
internal class ShaderMacroCollection {
    internal var _value: [MacroName: (Int, MTLDataType)] = [:]

    /// Union of two macro collection.
    /// - Parameters:
    ///   - left: input macro collection
    ///   - right: input macro collection
    ///   - out: union output macro collection
    static func unionCollection(_ left:ShaderMacroCollection, _ right: ShaderMacroCollection, _ result: ShaderMacroCollection) {
        left._value.forEach { (key: MacroName, value: (Int, MTLDataType)) in
            result._value[key] = value
        }
        right._value.forEach { (key: MacroName, value: (Int, MTLDataType)) in
            result._value[key] = value
        }
    }
}

extension ShaderMacroCollection:Hashable {
    static func == (lhs: ShaderMacroCollection, rhs: ShaderMacroCollection) -> Bool {
            var lhs_hasher = Hasher()
            var rhs_hasher = Hasher()

            lhs.hash(into: &lhs_hasher)
            rhs.hash(into: &rhs_hasher)

            return lhs_hasher.finalize() == rhs_hasher.finalize()
    }
    
    func hash(into hasher: inout Hasher) {
        _value.forEach { (key: MacroName, value: (Int, MTLDataType)) in
            hasher.combine(key)
            hasher.combine(value.0)
        }
    }
}

//
//  ShaderMacro.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Foundation

/// Shader macro
class ShaderMacro {
    var name: MacroName

    internal var _index: Int
    internal var _value: Int

    internal init(_ name: MacroName, _ index: Int, _ value: Int) {
        self.name = name
        self._index = index
        self._value = value
    }
}

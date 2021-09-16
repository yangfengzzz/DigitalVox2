//
//  ShaderProperty.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/16.
//

import Foundation

/// Shader property.
class ShaderProperty {
    private static var _propertyNameCounter: Int = 0

    internal let _uniqueId: Int
    internal var _group: ShaderDataGroup? = nil

    /// Shader property name.
    let name: String

    internal init(_ name: String) {
        self.name = name
        _uniqueId = ShaderProperty._propertyNameCounter
        ShaderProperty._propertyNameCounter += 1
    }
}

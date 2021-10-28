//
//  Skin.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// Mesh skin data, equal glTF skins define
class Skin: EngineObject {
    /// inverse bind matrix array
    public var inverseBindMatrices: [Matrix] = []
    /// joints name array, element type: string
    public var joints: [String] = []
    /// root bone name
    public var skeleton: String = "none"
}

//
//  SimpleMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

/// Simple Material.
class SimpleMaterial: BaseMaterial {
    init(_ engine: Engine) {
        super.init(engine, Shader.find("simple")!)
    }
}

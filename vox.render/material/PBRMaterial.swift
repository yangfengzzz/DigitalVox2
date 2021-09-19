//
//  PBRMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/19.
//

import Metal

/// PBR Material.
class PBRMaterial: BaseMaterial {
    var _baseColor: Texture2D?
    var _normal: Texture2D?
    var _roughness: Texture2D?
    var matConst: MaterialConstant? = nil
    let functionConstants = MTLFunctionConstantValues()
    
    init(_ engine: Engine) {
        super.init(engine, Shader.find("pbr")!)
        
        var property = false
        functionConstants.setConstantValue(&property, type: .bool, index: 3)
        functionConstants.setConstantValue(&property, type: .bool, index: 4)
    }
    
    var baseColor:Texture2D? {
        get {
            _baseColor
        }
        set {
            _baseColor = newValue
            var property = _baseColor != nil
            functionConstants.setConstantValue(&property, type: .bool, index: 0)
        }
    }
    
    var normal:Texture2D? {
        get {
            _normal
        }
        set {
            _normal = newValue
            var property = _normal != nil
            functionConstants.setConstantValue(&property, type: .bool, index: 1)
        }
    }
    
    var roughness:Texture2D? {
        get {
            _roughness
        }
        set {
            _roughness = newValue
            var property = _roughness != nil
            functionConstants.setConstantValue(&property, type: .bool, index: 2)
        }
    }
    
}

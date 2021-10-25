//
//  ShaderMacroCollection.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

extension MacroName: Hashable {
}

/// Shader macro collection.
internal class ShaderMacroCollection {
    internal var _value: [MacroName: (Int, MTLDataType)] = [:]

    /// Union of two macro collection.
    /// - Parameters:
    ///   - left: input macro collection
    ///   - right: input macro collection
    ///   - out: union output macro collection
    static func unionCollection(_ left: ShaderMacroCollection, _ right: ShaderMacroCollection, _ result: ShaderMacroCollection) {
        left._value.forEach { (key: MacroName, value: (Int, MTLDataType)) in
            result._value[key] = value
        }
        right._value.forEach { (key: MacroName, value: (Int, MTLDataType)) in
            result._value[key] = value
        }
    }

    static var defaultValue: [MacroName: (Int, MTLDataType)] = [
        HAS_UV: (0, .bool),
        HAS_NORMAL: (0, .bool),
        HAS_TANGENT: (0, .bool),
        HAS_VERTEXCOLOR: (0, .bool),

        // Blend Shape
        HAS_BLENDSHAPE: (0, .bool),
        HAS_BLENDSHAPE_NORMAL: (0, .bool),
        HAS_BLENDSHAPE_TANGENT: (0, .bool),

        // Skin
        HAS_SKIN: (0, .bool),
        HAS_JOINT_TEXTURE: (0, .bool),
        JOINTS_COUNT: (0, .int),

        // Material
        NEED_ALPHA_CUTOFF: (0, .bool),
        NEED_WORLDPOS: (0, .bool),
        NEED_TILINGOFFSET: (0, .bool),
        HAS_DIFFUSE_TEXTURE: (0, .bool),
        HAS_SPECULAR_TEXTURE: (0, .bool),
        HAS_EMISSIVE_TEXTURE: (0, .bool),
        HAS_NORMAL_TEXTURE: (0, .bool),
        OMIT_NORMAL: (0, .bool),
        HAS_BASE_TEXTURE: (0, .bool),
        HAS_BASE_COLORMAP: (0, .bool),
        HAS_EMISSIVEMAP: (0, .bool),
        HAS_OCCLUSIONMAP: (0, .bool),
        HAS_SPECULARGLOSSINESSMAP: (0, .bool),
        HAS_METALROUGHNESSMAP: (0, .bool),
        IS_METALLIC_WORKFLOW: (0, .bool),

        // Light
        DIRECT_LIGHT_COUNT: (0, .int),
        POINT_LIGHT_COUNT: (0, .int),
        SPOT_LIGHT_COUNT: (0, .int),

        // Enviroment
        HAS_SH: (0, .bool),
        HAS_SPECULAR_ENV: (0, .bool),

        // Particle Render
        HAS_PARTICLE_TEXTURE: (0, .bool),
        NEED_ROTATE_TO_VELOCITY: (0, .bool),
        NEED_USE_ORIGIN_COLOR: (0, .bool),
        NEED_SCALE_BY_LIFE_TIME: (0, .bool),
        NEED_FADE_IN: (0, .bool),
        NEED_FADE_OUT: (0, .bool),
        IS_2D: (0, .bool),

        // Shadow
        NEED_GENERATE_SHADOW_MAP: (0, .bool),
        SHADOW_MAP_COUNT: (0, .int),
    ]
}

extension ShaderMacroCollection: Hashable {
    static func ==(lhs: ShaderMacroCollection, rhs: ShaderMacroCollection) -> Bool {
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

//
//  BaseMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

class BaseMaterial: Material {
    private static var _alphaCutoffProp = Shader.getPropertyByName("u_alphaCutoff")

    private var _renderFace: RenderFace = RenderFace.Back
    private var _isTransparent: Bool = false
    private var _blendMode: BlendMode!

    /// Is this material transparent.
    /// - Remark:
    /// If material is transparent, transparent blend mode will be affected by `blendMode`, default is `BlendMode.Normal`.
    var isTransparent: Bool {
        get {
            _isTransparent
        }
        set {
            if (newValue == _isTransparent) {
                return
            }
            _isTransparent = newValue

            let depthState = renderState.depthState
            let targetBlendState = renderState.blendState.targetBlendState

            if (newValue) {
                targetBlendState.enabled = true
                depthState.writeEnabled = false
                renderQueueType = RenderQueueType.Transparent
            } else {
                targetBlendState.enabled = false
                depthState.writeEnabled = true
                renderQueueType = (shaderData.getFloat(BaseMaterial._alphaCutoffProp) != nil)
                        ? RenderQueueType.AlphaTest
                        : RenderQueueType.Opaque
            }
        }
    }

    /// Alpha cutoff value.
    /// - Remark:
    /// Fragments with alpha channel lower than cutoff value will be discarded.
    /// `0` means no fragment will be discarded.
    var alphaCutoff: Float {
        get {
            shaderData.getFloat(BaseMaterial._alphaCutoffProp)!
        }
        set {
            shaderData.setFloat(BaseMaterial._alphaCutoffProp, newValue)

            if (newValue > 0) {
                shaderData.enableMacro(NEED_ALPHA_CUTOFF)
                renderQueueType = _isTransparent ? RenderQueueType.Transparent : RenderQueueType.AlphaTest
            } else {
                shaderData.disableMacro(NEED_ALPHA_CUTOFF)
                renderQueueType = _isTransparent ? RenderQueueType.Transparent : RenderQueueType.Opaque
            }
        }
    }

    /// Set which face for render.
    var renderFace: RenderFace {
        get {
            _renderFace
        }
        set {
            if (newValue == _renderFace) {
                return
            }
            _renderFace = newValue

            switch (newValue) {
            case RenderFace.Front:
                renderState.rasterState.cullMode = .back
                break
            case RenderFace.Back:
                renderState.rasterState.cullMode = .front
                break
            case RenderFace.Double:
                renderState.rasterState.cullMode = .none
                break
            }
        }
    }

    /// Alpha blend mode.
    /// - Remark:
    /// Only take effect when `isTransparent` is `true`.
    var blendMode: BlendMode {
        get {
            _blendMode
        }
        set {
            if (newValue == _blendMode) {
                return
            }
            _blendMode = newValue

            let target = renderState.blendState.targetBlendState

            switch (newValue) {
            case BlendMode.Normal:
                target.sourceColorBlendFactor = .sourceAlpha
                target.destinationColorBlendFactor = .oneMinusSourceAlpha
                target.sourceAlphaBlendFactor = .one
                target.destinationAlphaBlendFactor = .oneMinusSourceAlpha
                target.alphaBlendOperation = .add
                target.colorBlendOperation = .add
                break
            case BlendMode.Additive:
                target.sourceColorBlendFactor = .sourceAlpha
                target.destinationColorBlendFactor = .one
                target.sourceAlphaBlendFactor = .one
                target.destinationAlphaBlendFactor = .oneMinusSourceAlpha
                target.alphaBlendOperation = .add
                target.colorBlendOperation = .add
                break
            }
        }
    }

    /// Create a BaseMaterial instance.
    /// - Parameters:
    ///   - engine: Engine to which the material belongs
    ///   - shader: Shader used by the material
    override init(_ engine: Engine, _ shader: Shader) {
        super.init(engine, shader)
        blendMode = BlendMode.Normal
        shaderData.setFloat(BaseMaterial._alphaCutoffProp, 0)
    }
}

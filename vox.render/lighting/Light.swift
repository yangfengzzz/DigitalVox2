//
//  Light.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Foundation

/// Light base class.
class Light: Component {
    /// Each type of light source is at most 10, beyond which it will not take effect.
    static var _maxLight: Int = 10

    private var _viewMat: Matrix = Matrix()
    private var _inverseViewMat: Matrix = Matrix()

    /// View matrix.
    var viewMatrix: Matrix {
        get {
            Matrix.invert(a: entity.transform.worldMatrix, out: _viewMat)
            return _viewMat
        }
    }

    /// Inverse view matrix.
    var inverseViewMatrix: Matrix {
        get {
            Matrix.invert(a: viewMatrix, out: _inverseViewMat)
            return _inverseViewMat
        }
    }

    //MARK:- Shadow
    internal var shadowMapPass: ShadowMapPass?
    internal var shadow: LightShadow?
    private var _enableShadow = false
    var enableShadow: Bool {
        get {
            _enableShadow
        }
        set {
            _enableShadow = enabled

            if (_enableShadow) {
                if shadow == nil {
                    shadow = LightShadow(self, engine, 512, 512)
                }
                shadow!.initShadowProjectionMatrix(self)
            }
        }
    }
}

//
//  RenderContext.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Foundation

/// Rendering context.
class RenderContext {
    internal var _camera: Camera!
    internal var _viewProjectMatrix: Matrix = Matrix()

    internal func _setContext(_ camera: Camera) {
        _camera = camera
        Matrix.multiply(left: camera.projectionMatrix, right: camera.viewMatrix, out: _viewProjectMatrix)
    }
}

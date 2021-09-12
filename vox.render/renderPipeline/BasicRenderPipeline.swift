//
//  BasicRenderPipeline.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/12.
//

import Foundation

/// Basic render pipeline.
class BasicRenderPipeline {
    private var _camera: Camera?

    /// Create a basic render pipeline.
    /// - Parameter camera: Camera
    init(_ camera: Camera) {
        _camera = camera;
    }

    /// Destroy internal resources.
    func destroy() {
        _camera = nil;
    }

    /// Perform scene rendering.
    func render() {
        let camera = _camera;
        camera!.engine._componentsManager.callRender(_camera!);
    }
}

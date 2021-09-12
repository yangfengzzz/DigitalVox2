//
//  GPUPrimitive.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/11.
//

import Foundation

/// WebGPU platform primitive.
class GPUPrimitive {
    var _primitive: Mesh;

    init(_ rhi: MetalGPURenderer, _ primitive: Mesh) {
        self._primitive = primitive;
    }

}

extension GPUPrimitive: IPlatformPrimitive {
    /// Draw the primitive.
    func draw(_ shaderProgram: AnyClass, _ subMesh: SubMesh) {
    }

    func destroy() {
    }
}

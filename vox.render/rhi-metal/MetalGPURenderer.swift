//
//  MetalRenderer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/11.
//

import Foundation

/**
 * Metal renderer.
 */
class MetalGPURenderer {
    func reinit(_ canvas: Canvas) {
        
    }
}

extension MetalGPURenderer: IHardwareRenderer {
    func createPlatformPrimitive(primitive: Mesh) -> IPlatformPrimitive {
        GPUPrimitive(self, primitive);
    }

    func drawPrimitive(primitive: Mesh, subPrimitive: SubMesh, shaderProgram: AnyClass) {
        primitive._draw(shaderProgram, subPrimitive);
    }
}

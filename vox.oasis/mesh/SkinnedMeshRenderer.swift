//
//  SkinnedMeshRenderer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Metal

class SkinnedMeshRenderer: MeshRenderer {
    private static var _jointMatrixProperty = Shader.getPropertyByName("u_jointMatrix")
    private var _jointMatrixPaletteBuffer: MTLBuffer?
    
    var jointMatrixPaletteBuffer: MTLBuffer? {
        get {
            _jointMatrixPaletteBuffer
        }
        set {
            _jointMatrixPaletteBuffer = newValue
            if let paletteBuffer = _jointMatrixPaletteBuffer {
                shaderData.enableMacro(HAS_SKIN)
                shaderData.setBuffer(SkinnedMeshRenderer._jointMatrixProperty, paletteBuffer)
            }
        }
    }
    
    func updateJoint(_ modelMatrix:[matrix_float4x4]) {
        guard let paletteBuffer = jointMatrixPaletteBuffer else {
            return
        }
        var palettePointer = paletteBuffer.contents().bindMemory(to: float4x4.self, capacity: modelMatrix.count)
        palettePointer.initialize(repeating: .identity(), count: modelMatrix.count)
        
        for i in 0..<modelMatrix.count {
            palettePointer.pointee = modelMatrix[i]
            palettePointer = palettePointer.advanced(by: 1)
        }
    }
}

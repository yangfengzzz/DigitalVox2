//
//  SkinnedMeshRenderer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Metal

class SkinnedMeshRenderer: MeshRenderer {
    private static var _jointMatrixProperty = Shader.getPropertyByName("u_jointMatrix")

    private var _skeleton: Skeleton?


    var skeleton: Skeleton? {
        get {
            _skeleton
        }
        set {
            _skeleton = newValue
            if let paletteBuffer = skeleton?.jointMatrixPaletteBuffer {
                shaderData.enableMacro(HAS_SKIN)
                shaderData.setBuffer(SkinnedMeshRenderer._jointMatrixProperty, paletteBuffer)
            }
        }
    }

    override func update(_ deltaTime: Float) {
        super.update(deltaTime)
        if _skeleton != nil {
            let animator: Animator = entity.getComponent()
            animator.update(deltaTime)
            skeleton!.updatePose(animationClip: animator.currentAnimation!,
                    at: animator.currentTime)
        }
    }
}

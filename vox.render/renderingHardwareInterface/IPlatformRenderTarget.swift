//
//  IPlatformRenderTarget.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Foundation

/// Off-screen rendering target specification.
protocol IPlatformRenderTarget {
    /// Set which face of the cube texture to render to.
    /// - Parameter faceIndex: Cube texture face
    func setRenderTargetFace(_ faceIndex: TextureCubeFace)

    /// Blit FBO.
    func blitRenderTarget()

    /// Destroy render target.
    func destroy()
}

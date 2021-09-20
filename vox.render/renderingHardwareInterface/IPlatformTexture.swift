//
//  IPlatformTexture.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

/// Texture interface specification.
protocol IPlatformTexture {
    /// Wrapping mode for texture coordinate S.
    var wrapModeU: MTLSamplerAddressMode { get set }

    /// Wrapping mode for texture coordinate T.
    var wrapModeV: MTLSamplerAddressMode { get set }

    /// Filter mode for texture.
    var filterMode: MTLSamplerMipFilter { get set }

    /// Anisotropic level for texture.
    var anisoLevel: Int { get set }

    /// Destroy texture.
    func destroy()

    /// Generate multi-level textures based on the 0th level data.
    func generateMipmaps()
}

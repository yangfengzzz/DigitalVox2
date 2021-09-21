//
//  MetalTextureCubeMap.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/21.
//

import MetalKit

/// Cube texture in Metal platform.
class MetalTextureCubeMap: MetalTexture {
    let descriptor: MTLTextureDescriptor

    init(_ rhi: MetalRenderer, _ textureCube: TextureCubeMap) {
        if textureCube._mipmap! {
            descriptor = MTLTextureDescriptor.textureCubeDescriptor(pixelFormat: textureCube.format,
                    size: textureCube.width, mipmapped: true)
            descriptor.mipmapLevelCount = textureCube.mipmapCount
        } else {
            descriptor = MTLTextureDescriptor.textureCubeDescriptor(pixelFormat: textureCube.format,
                    size: textureCube.width, mipmapped: false)
        }
        descriptor.textureType = .typeCube

        super.init(rhi, textureCube)

        _mtlTexture = rhi.device.makeTexture(descriptor: descriptor)
    }
}

extension MetalTextureCubeMap: IPlatformTextureCubeMap {
    func setPixelBuffer<T>(_ face: TextureCubeFace, _ colorBuffer: [T], _ mipLevel: Int?,
                           _ x: Int?, _ y: Int?, _ width: Int?, _ height: Int?) {
        let mipLevel = mipLevel != nil ? mipLevel! : 0
        let mipSize = max(1, _texture.width >> mipLevel)

        let x = x != nil ? x! : 0
        let y = y != nil ? y! : 0
        let width = width != nil ? width! : mipSize - x
        let height = height != nil ? height! : mipSize - y

        _mtlTexture.replace(region: MTLRegionMake2D(x, y, width, height),
                mipmapLevel: mipLevel, slice: face.rawValue, withBytes: colorBuffer,
                bytesPerRow: width * MemoryLayout<Float>.stride,
                bytesPerImage: width * height * MemoryLayout<Float>.stride)
    }

    func setImageSource(_ face: TextureCubeFace, _ imageSource: MTLTexture) {
        _mtlTexture = imageSource.makeTextureView(pixelFormat: descriptor.pixelFormat)
    }

    func getPixelBuffer<T>(_ face: TextureCubeFace, _ x: Int, _ y: Int,
                           _ width: Int, _ height: Int, _ mipLevel: Int, _ out: inout [T]) {
        _mtlTexture.getBytes(&out, bytesPerRow: width * MemoryLayout<Float>.stride,
                bytesPerImage: width * height * MemoryLayout<Float>.stride,
                from: MTLRegionMake2D(x, y, width, height), mipmapLevel: mipLevel, slice: face.rawValue)
    }
}

//
//  MetalTexture2D.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/21.
//

import MetalKit

class MetalTexture2D: MetalTexture {
    let descriptor: MTLTextureDescriptor

    init(rhi: MetalRenderer, texture2D: Texture2D) {
        if texture2D.mipmapCount > 0 {
            descriptor = MTLTextureDescriptor.texture2DDescriptor(
                    pixelFormat: texture2D.format, width: texture2D.width,
                    height: texture2D.height, mipmapped: true)
            descriptor.mipmapLevelCount = texture2D.mipmapCount
        } else {
            descriptor = MTLTextureDescriptor.texture2DDescriptor(
                    pixelFormat: texture2D.format, width: texture2D.width,
                    height: texture2D.height, mipmapped: false)
            descriptor.mipmapLevelCount = 0
        }
        
        super.init(rhi, texture2D)

        _mtlTexture = rhi.device.makeTexture(descriptor: descriptor)
    }
}

extension MetalTexture2D: IPlatformTexture2D {
    func setPixelBuffer(_ colorBuffer: [Float], _ mipLevel: Int?, _ x: Int?, _ y: Int?,
                        _ width: Int?, _ height: Int?) {
        let mipLevel = mipLevel != nil ? mipLevel! : 0
        let mipWidth = max(1, _texture.width >> mipLevel)
        let mipHeight = max(1, _texture.height >> mipLevel)

        let x = x != nil ? x! : 0
        let y = y != nil ? y! : 0
        let width = width != nil ? width! : mipWidth - x
        let height = height != nil ? height! : mipHeight - y

        _mtlTexture.replace(region: MTLRegionMake2D(x, y, width, height),
                mipmapLevel: mipLevel, withBytes: colorBuffer,
                bytesPerRow: width * MemoryLayout<Float>.stride)
    }

    func setImageSource(_ imageSource: MTLBuffer, _ x: Int?, _ y: Int?) {
        _mtlTexture = imageSource.makeTexture(descriptor: descriptor, offset: 0,
                bytesPerRow: _texture.width * MemoryLayout<Float>.stride)
    }

    func setImageSource(_ imageSource: MTLTexture) {
        _mtlTexture = imageSource.makeTextureView(pixelFormat: descriptor.pixelFormat)
    }

    func getPixelBuffer(_ x: Int, _ y: Int, _ width: Int, _ height: Int, _ mipLevel: Int, _ out: inout [Float]) {
        _mtlTexture.getBytes(&out, bytesPerRow: width * MemoryLayout<Float>.stride,
                from: MTLRegionMake2D(x, y, width, height), mipmapLevel: mipLevel)
    }
}

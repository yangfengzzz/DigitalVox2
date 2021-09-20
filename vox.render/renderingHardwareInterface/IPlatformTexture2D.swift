//
//  IPlatformTexture2D.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

/// 2D texture interface specification.
protocol IPlatformTexture2D: IPlatformTexture {
    /// Setting pixels data through color buffer data, designated area and texture mipmapping level,
    /// it's also applicable to compressed formats.
    /// - Parameters:
    ///   - colorBuffer: Color buffer data
    ///   - mipLevel: Texture mipmapping level
    ///   - x: X coordinate of area start
    ///   - y: Y coordinate of area start
    ///   - width: Data width. if it's empty, width is the width corresponding to mipLevel minus x ,
    /// width corresponding to mipLevel is Math.max(1, this.width >> mipLevel)
    ///   - height: Data height. if it's empty, height is the height corresponding to mipLevel minus y ,
    /// height corresponding to mipLevel is Math.max(1, this.height >> mipLevel)
    func setPixelBuffer(_ colorBuffer: [Float], _ mipLevel: Int?,
                        _ x: Float?, _ y: Float?,
                        _ width: Int?, _ height: Int?
    )

    /// Setting pixels data through TexImageSource, designated area and texture mipmapping level.
    /// - Parameters:
    ///   - imageSource: The source of texture
    ///   - mipLevel: Texture mipmapping level
    ///   - flipY: Whether to flip the Y axis
    ///   - premultiplyAlpha: Whether to premultiply the transparent channel
    ///   - x: X coordinate of area start
    ///   - y: Y coordinate of area start
    func setImageSource(_ imageSource: MTLBuffer, _ mipLevel: Int?,
                        _ flipY: Bool?, _ premultiplyAlpha: Bool?,
                        _ x: Float?, _ y: Float?
    )

    /// Get the pixel color buffer according to the specified area.
    /// - Parameters:
    ///   - x: X coordinate of area start
    ///   - y: Y coordinate of area start
    ///   - width: Area width
    ///   - height: Area height
    ///   - out: Color buffer
    func getPixelBuffer(_ x: Float, _ y: Float, _ width: Int, _ height: Int, _ out: inout [Float])
}

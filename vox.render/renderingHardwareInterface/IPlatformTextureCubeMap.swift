//
//  IPlatformTextureCubeMap.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

/// Cube texture interface specification.
protocol IPlatformTextureCubeMap: IPlatformTexture {
    /// Setting pixels data through cube face,color buffer data, designated area and texture mipmapping level,
    /// it's also applicable to compressed formats.
    /// - Parameters:
    ///   - face: Cube face
    ///   - colorBuffer: Color buffer data
    ///   - mipLevel: Texture mipmapping level
    ///   - x: X coordinate of area start
    ///   - y: Y coordinate of area start
    ///   - width: Data width.if it's empty, width is the width corresponding to mipLevel minus x ,
    ///    width corresponding to mipLevel is Math.max(1, this.width >> mipLevel)
    ///   - height: Data height.if it's empty, height is the height corresponding to mipLevel minus y ,
    ///   height corresponding to mipLevel is Math.max(1, this.height >> mipLevel)
    func setPixelBuffer<T>(_ face: TextureCubeFace, _ colorBuffer: [T],
                           _ mipLevel: Int?, _ x: Int?, _ y: Int?, _ width: Int?, _ height: Int?
    )

    /// Setting pixels data through cube face, TexImageSource, designated area and texture mipmapping level.
    /// - Parameters:
    ///   - face: Cube face
    ///   - imageSource: The source of texture
    func setImageSource(_ face: TextureCubeFace, _ imageSource: MTLTexture)

    /// Get the pixel color buffer according to the specified cube face and area.
    /// - Parameters:
    ///   - face: You can choose which cube face to read
    ///   - x: X coordinate of area start
    ///   - y: Y coordinate of area start
    ///   - width: Area width
    ///   - height: Area height
    ///   - out: Color buffer
    func getPixelBuffer<T>(_ face: TextureCubeFace,
                           _ x: Int, _ y: Int, _ width: Int, _ height: Int,
                           _ mipLevel: Int, _ out: inout [T]
    )
}

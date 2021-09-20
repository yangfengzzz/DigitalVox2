//
//  IPlatformRenderColorTexture.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Foundation

/// Rendering color texture interface specification.
protocol IPlatformRenderColorTexture: IPlatformTexture {
    /// Get the pixel color buffer according to the specified cube face and area.
    /// - Parameters:
    ///   - face: You can choose which cube face to read if it's cube texture
    ///   - x: X coordinate of area start
    ///   - y: Y coordinate of area start
    ///   - width: Area width
    ///   - height: Area height
    ///   - out: Color buffer
    func getPixelBuffer(_ face: TextureCubeFace?,
                        _ x: Int, _ y: Int, _ width: Int, _ height: Int,
                        _ out: inout [Float]
    )
}

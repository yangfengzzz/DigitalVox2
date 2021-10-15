//
//  RasterState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Metal

/// Raster state.
class RasterState {
    /// Specifies whether or not front- and/or back-facing polygons can be culled. */
    var cullMode: MTLCullMode = .back
    /// The multiplier by which an implementation-specific value is multiplied with to create a constant depth offset. */
    var depthBias: Float = 0
    /// The scale factor for the variable depth offset for each polygon. */
    var slopeScaledDepthBias: Float = 0

    internal var _cullFaceEnable: Bool = true
}

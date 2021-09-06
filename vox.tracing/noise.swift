//
//  noise.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

// Compute the revised Perlin noise function with returned values in the range
// [0,1]. Wrap provides a wrapping noise but must be power of two (wraps at 256
// anyway).
@inlinable
func perlin_noise(p: Float, wrap: Int = 0) -> Float {
    fatalError()
}

@inlinable
func perlin_noise(p: vec2f, wrap: vec2i = [0, 0]) -> Float {
    fatalError()
}

@inlinable
func perlin_noise(p: vec3f, wrap: vec3i = [0, 0, 0]) -> Float {
    fatalError()
}

@inlinable
func perlin_noise(p: vec4f, wrap: vec4i = [0, 0, 0, 0]) -> Float {
    fatalError()
}

// Fractal noise variations. Good values are obtained with
// octaves=6 (number of noise calls),
// lacunarity=~2.0 (spacing between successive octaves: 2.0 for warping),
// gain=0.5 (relative weighting applied to each successive octave),
// offset=1.0 (used to invert the ridges).
@inlinable
func perlin_ridge(p: vec3f, lacunarity: Float = 2,
                  gain: Float = 0.5, octaves: Int = 6, offset: Float = 1,
                  wrap: vec3i = zero3i) -> Float {
    fatalError()
}

@inlinable
func perlin_fbm(p: vec3f, lacunarity: Float = 2, gain: Float = 0.5,
                octaves: Int = 6, wrap: vec3i = zero3i) -> Float {
    fatalError()
}

@inlinable
func perlin_turbulence(p: vec3f, lacunarity: Float = 2,
                       gain: Float = 0.5, octaves: Int = 6, wrap: vec3i = zero3i) -> Float {
    fatalError()
}

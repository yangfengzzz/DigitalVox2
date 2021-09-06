//
//  noise.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

public let __perlin_permutation: [Int] = [
    124, 56, 113, 233, 69, 219, 244, 236, 246, 92, 26, 82, 218, 176, 78, 143, 238,
    145, 119, 38, 132, 112, 51, 7, 27, 81, 158, 241, 98, 37, 91, 230, 198, 205,
    178, 149, 152, 140, 190, 193, 234, 157, 6, 239, 249, 16, 155, 75, 162, 90,
    114, 43, 55, 28, 232, 183, 31, 12, 177, 74, 148, 186, 169, 20, 116, 45, 103,
    242, 135, 66, 163, 8, 221, 63, 102, 121, 39, 58, 201, 35, 217, 120, 144, 3,
    47, 203, 153, 213, 105, 210, 197, 79, 160, 34, 76, 248, 187, 180, 89, 17, 181,
    252, 60, 24, 21, 71, 164, 0, 138, 33, 188, 195, 223, 128, 65, 229, 247, 189,
    129, 88, 204, 42, 54, 32, 165, 118, 80, 96, 150, 199, 130, 64, 141, 156, 94,
    222, 255, 216, 194, 182, 25, 139, 111, 83, 108, 226, 227, 122, 220, 29, 52,
    207, 5, 174, 77, 133, 191, 67, 200, 4, 192, 250, 161, 172, 59, 117, 127, 136,
    225, 106, 251, 10, 154, 240, 171, 179, 126, 100, 19, 70, 2, 97, 159, 73, 104,
    53, 184, 137, 101, 72, 22, 185, 211, 243, 49, 175, 170, 93, 57, 62, 30, 131,
    115, 110, 46, 208, 11, 231, 13, 50, 254, 125, 237, 87, 206, 84, 86, 196, 167,
    41, 1, 151, 212, 224, 99, 147, 23, 40, 134, 95, 253, 123, 85, 235, 107, 142,
    44, 215, 146, 9, 48, 173, 168, 214, 68, 18, 15, 61, 202, 245, 36, 228, 109,
    209, 166, 14,
    // repeat
    124, 56, 113, 233, 69, 219, 244, 236, 246, 92, 26, 82, 218, 176, 78, 143, 238,
    145, 119, 38, 132, 112, 51, 7, 27, 81, 158, 241, 98, 37, 91, 230, 198, 205,
    178, 149, 152, 140, 190, 193, 234, 157, 6, 239, 249, 16, 155, 75, 162, 90,
    114, 43, 55, 28, 232, 183, 31, 12, 177, 74, 148, 186, 169, 20, 116, 45, 103,
    242, 135, 66, 163, 8, 221, 63, 102, 121, 39, 58, 201, 35, 217, 120, 144, 3,
    47, 203, 153, 213, 105, 210, 197, 79, 160, 34, 76, 248, 187, 180, 89, 17, 181,
    252, 60, 24, 21, 71, 164, 0, 138, 33, 188, 195, 223, 128, 65, 229, 247, 189,
    129, 88, 204, 42, 54, 32, 165, 118, 80, 96, 150, 199, 130, 64, 141, 156, 94,
    222, 255, 216, 194, 182, 25, 139, 111, 83, 108, 226, 227, 122, 220, 29, 52,
    207, 5, 174, 77, 133, 191, 67, 200, 4, 192, 250, 161, 172, 59, 117, 127, 136,
    225, 106, 251, 10, 154, 240, 171, 179, 126, 100, 19, 70, 2, 97, 159, 73, 104,
    53, 184, 137, 101, 72, 22, 185, 211, 243, 49, 175, 170, 93, 57, 62, 30, 131,
    115, 110, 46, 208, 11, 231, 13, 50, 254, 125, 237, 87, 206, 84, 86, 196, 167,
    41, 1, 151, 212, 224, 99, 147, 23, 40, 134, 95, 253, 123, 85, 235, 107, 142,
    44, 215, 146, 9, 48, 173, 168, 214, 68, 18, 15, 61, 202, 245, 36, 228, 109,
    209, 166, 14,
]

// Compute the revised Perlin noise function with returned values in the range
// [0,1]. Wrap provides a wrapping noise but must be power of two (wraps at 256
// anyway).
@inlinable
func perlin_noise(_ p: Float, _ w: Int = 0) -> Float {
    let ease = { (a: Float) -> Float in
        ((a * 6 - 15) * a + 10) * a * a * a
    }
    let ifloor = { (a: Float) -> Int in
        let ai = Int(a)
        return (a < Float(ai)) ? ai - 1 : ai
    }
    let m = (w - 1) & 255
    let grad = { (i: Int, f: Float) -> Float in
        let _p = __perlin_permutation
        let hash = _p[i & m]
        let h = hash & 15
        var grad = 1.0 + Float(h & 7) // Gradient value 1.0, 2.0, ..., 8.0
        if ((h & 8) != 0) {
            grad = -grad
        }  // and a random sign for the gradient
        return (grad * f) // Multiply the gradient with the distance
    }

    let i = ifloor(p)
    let f = p - Float(i)

    let u = ease(f)

    let n0 = grad(i + 0, f + 0)
    let n1 = grad(i + 1, f - 1)

    return interpolate_line(n0, n1, u) * 0.5 + 0.5
}

@inlinable
func perlin_noise(_ p: vec2f, _ w: vec2i = [0, 0]) -> Float {
    let ease = { (a: Float) -> Float in
        ((a * 6 - 15) * a + 10) * a * a * a
    }
    let ifloor = {
        (a: Float) -> Int in
        let ai = Int(a)
        return (a < Float(ai)) ? ai - 1 : ai
    }
    let m = vec2i((w.x - 1) & 255, (w.y - 1) & 255)
    let grad = { (i: vec2i, f: vec2f) -> Float in
        let _p = __perlin_permutation
        let hash = _p[_p[i.x & m.x] + i.y & m.y]
        let h = hash & 7           // Convert low 3 bits of hash code
        let u = h < 4 ? f.x : f.y  // into 8 simple gradient directions,
        let v = h < 4 ? f.y : f.x  // and compute the dot product with (f.x,f.y).
        return ((h & 1) != 0 ? -u : u) + ((h & 2) != 0 ? -2 * v : 2 * v)
    }

    let i = vec2i(ifloor(p.x), ifloor(p.y))
    let f = vec2f(p.x - Float(i.x), p.y - Float(i.y))
    let u = vec2f(ease(f.x), ease(f.y))

    let n00 = grad([i.x + 0, i.y + 0], [f.x + 0, f.y + 0])
    let n01 = grad([i.x + 0, i.y + 1], [f.x + 0, f.y - 1])
    let n10 = grad([i.x + 1, i.y + 0], [f.x - 1, f.y + 0])
    let n11 = grad([i.x + 1, i.y + 1], [f.x - 1, f.y - 1])

    let n0 = interpolate_line(n00, n01, u.y)
    let n1 = interpolate_line(n10, n11, u.y)

    return interpolate_line(n0, n1, u.x) * 0.5 + 0.5
}

@inlinable
func perlin_noise(_ p: vec3f, _ w: vec3i = [0, 0, 0]) -> Float {
    let ease = { (a: Float) -> Float in
        ((a * 6 - 15) * a + 10) * a * a * a
    }
    let ifloor = { (a: Float) -> Int in
        let ai = Int(a)
        return (a < Float(ai)) ? ai - 1 : ai
    }
    let m = vec3i((w.x - 1) & 255, (w.y - 1) & 255, (w.z - 1) & 255)
    let grad = { (i: vec3i, f: vec3f) -> Float in
        let _p = __perlin_permutation
        let hash = _p[_p[_p[i.x & m.x] + i.y & m.y] + i.z & m.z]
        // Convert low 4 bits of hash code into 12 simple
        // gradient directions, and compute dot product.
        let h = hash & 15
        let u = h < 8 ? f.x : f.y
        let v = h < 4 ? f.y : h == 12 || h == 14 ? f.x : f.z
        return ((h & 1) != 0 ? -u : u) + ((h & 2) != 0 ? -v : v)
    }

    let i = vec3i(ifloor(p.x), ifloor(p.y), ifloor(p.z))
    let f = vec3f(p.x - Float(i.x), p.y - Float(i.y), p.z - Float(i.z))
    let u = vec3f(ease(f.x), ease(f.y), ease(f.z))

    let n000 = grad([i.x + 0, i.y + 0, i.z + 0], [f.x + 0, f.y + 0, f.z + 0])
    let n001 = grad([i.x + 0, i.y + 0, i.z + 1], [f.x + 0, f.y + 0, f.z - 1])
    let n010 = grad([i.x + 0, i.y + 1, i.z + 0], [f.x + 0, f.y - 1, f.z + 0])
    let n011 = grad([i.x + 0, i.y + 1, i.z + 1], [f.x + 0, f.y - 1, f.z - 1])
    let n100 = grad([i.x + 1, i.y + 0, i.z + 0], [f.x - 1, f.y + 0, f.z + 0])
    let n101 = grad([i.x + 1, i.y + 0, i.z + 1], [f.x - 1, f.y + 0, f.z - 1])
    let n110 = grad([i.x + 1, i.y + 1, i.z + 0], [f.x - 1, f.y - 1, f.z + 0])
    let n111 = grad([i.x + 1, i.y + 1, i.z + 1], [f.x - 1, f.y - 1, f.z - 1])

    let n00 = interpolate_line(n000, n001, u.z)
    let n01 = interpolate_line(n010, n011, u.z)
    let n10 = interpolate_line(n100, n101, u.z)
    let n11 = interpolate_line(n110, n111, u.z)

    let n0 = interpolate_line(n00, n01, u.y)
    let n1 = interpolate_line(n10, n11, u.y)

    return interpolate_line(n0, n1, u.x) * 0.5 + 0.5
}

@inlinable
func perlin_noise(_ p: vec4f, _ w: vec4i = [0, 0, 0, 0]) -> Float {
    let ease = { (a: Float) -> Float in
        ((a * 6 - 15) * a + 10) * a * a * a
    }
    let ifloor = { (a: Float) -> Int in
        let ai = Int(a)
        return (a < Float(ai)) ? ai - 1 : ai
    }
    let m = vec4i((w.x - 1) & 255, (w.y - 1) & 255, (w.z - 1) & 255, (w.w - 1) & 255)
    let grad = { (i: vec4i, f: vec4f) -> Float in
        let _p = __perlin_permutation
        let hash = _p[_p[_p[_p[i.x & m.x] + i.y & m.y] + i.z & m.y] + i.w & m.w]
        // Convert low 5 bits of hash code into 32 simple
        // gradient directions, and compute dot product.
        let h = hash & 31
        let u = h < 24 ? f.x : f.y
        let v = h < 16 ? f.y : f.z
        let w = h < 8 ? f.z : f.w
        return ((h & 1) != 0 ? -u : u) + ((h & 2) != 0 ? -v : v) +
                ((h & 4) != 0 ? -w : w)
    }

    let i = vec4i(ifloor(p.x), ifloor(p.y), ifloor(p.z), ifloor(p.w))
    let f = vec4f(p.x - Float(i.x), p.y - Float(i.y), p.z - Float(i.z), p.w - Float(i.w))
    let u = vec4f(ease(f.x), ease(f.y), ease(f.z), ease(f.z))

    let n0000 = grad([i.x + 0, i.y + 0, i.z + 0, i.w + 0],
            [f.x + 0, f.y + 0, f.z + 0, f.z + 0])
    let n0001 = grad([i.x + 0, i.y + 0, i.z + 0, i.w + 1],
            [f.x + 0, f.y + 0, f.z + 0, f.z - 1])
    let n0010 = grad([i.x + 0, i.y + 0, i.z + 1, i.w + 0],
            [f.x + 0, f.y + 0, f.z - 1, f.z + 0])
    let n0011 = grad([i.x + 0, i.y + 0, i.z + 1, i.w + 1],
            [f.x + 0, f.y + 0, f.z - 1, f.z - 1])
    let n0100 = grad([i.x + 0, i.y + 1, i.z + 0, i.w + 0],
            [f.x + 0, f.y - 1, f.z + 0, f.z + 0])
    let n0101 = grad([i.x + 0, i.y + 1, i.z + 0, i.w + 1],
            [f.x + 0, f.y - 1, f.z + 0, f.z - 1])
    let n0110 = grad([i.x + 0, i.y + 1, i.z + 1, i.w + 0],
            [f.x + 0, f.y - 1, f.z - 1, f.z + 0])
    let n0111 = grad([i.x + 0, i.y + 1, i.z + 1, i.w + 1],
            [f.x + 0, f.y - 1, f.z - 1, f.z - 1])
    let n1000 = grad([i.x + 1, i.y + 0, i.z + 0, i.w + 0],
            [f.x - 1, f.y + 0, f.z + 0, f.z + 0])
    let n1001 = grad([i.x + 1, i.y + 0, i.z + 0, i.w + 1],
            [f.x - 1, f.y + 0, f.z + 0, f.z - 1])
    let n1010 = grad([i.x + 1, i.y + 0, i.z + 1, i.w + 0],
            [f.x - 1, f.y + 0, f.z - 1, f.z + 0])
    let n1011 = grad([i.x + 1, i.y + 0, i.z + 1, i.w + 1],
            [f.x - 1, f.y + 0, f.z - 1, f.z - 1])
    let n1100 = grad([i.x + 1, i.y + 1, i.z + 0, i.w + 0],
            [f.x - 1, f.y - 1, f.z + 0, f.z + 0])
    let n1101 = grad([i.x + 1, i.y + 1, i.z + 0, i.w + 1],
            [f.x - 1, f.y - 1, f.z + 0, f.z - 1])
    let n1110 = grad([i.x + 1, i.y + 1, i.z + 1, i.w + 0],
            [f.x - 1, f.y - 1, f.z - 1, f.z + 0])
    let n1111 = grad([i.x + 1, i.y + 1, i.z + 1, i.w + 1],
            [f.x - 1, f.y - 1, f.z - 1, f.z - 1])

    let n000 = interpolate_line(n0000, n0001, u.w)
    let n001 = interpolate_line(n0010, n0011, u.w)
    let n010 = interpolate_line(n0100, n0101, u.w)
    let n011 = interpolate_line(n0110, n0111, u.w)
    let n100 = interpolate_line(n1000, n1001, u.w)
    let n101 = interpolate_line(n1010, n1011, u.w)
    let n110 = interpolate_line(n1100, n1101, u.w)
    let n111 = interpolate_line(n1110, n1111, u.w)

    let n00 = interpolate_line(n000, n001, u.z)
    let n01 = interpolate_line(n010, n011, u.z)
    let n10 = interpolate_line(n100, n101, u.z)
    let n11 = interpolate_line(n110, n111, u.z)

    let n0 = interpolate_line(n00, n01, u.y)
    let n1 = interpolate_line(n10, n11, u.y)

    return interpolate_line(n0, n1, u.x) * 0.5 + 0.5
}

// Fractal noise variations. Good values are obtained with
// octaves=6 (number of noise calls),
// lacunarity=~2.0 (spacing between successive octaves: 2.0 for warping),
// gain=0.5 (relative weighting applied to each successive octave),
// offset=1.0 (used to invert the ridges).
@inlinable
func perlin_ridge(_ p: vec3f, _ lacunarity: Float = 2,
                  _ gain: Float = 0.5, _ octaves: Int = 6, _ offset: Float = 1,
                  _ wrap: vec3i = zero3i) -> Float {
    var frequency: Float = 1.0
    var prev: Float = 1.0
    var amplitude: Float = 0.5
    var sum: Float = 0.0
    for _ in 0..<octaves {
        var r = offset - abs(perlin_noise(p * frequency, wrap) * 2 - 1)
        r = r * r
        sum += r * amplitude * prev
        prev = r
        frequency *= lacunarity
        amplitude *= gain
    }
    return sum
}

@inlinable
func perlin_fbm(_ p: vec3f, _ lacunarity: Float = 2, _ gain: Float = 0.5,
                _ octaves: Int = 6, _ wrap: vec3i = zero3i) -> Float {
    var frequency: Float = 1.0
    var amplitude: Float = 1.0
    var sum: Float = 0.0
    for _ in 0..<octaves {
        sum += perlin_noise(p * frequency, wrap) * amplitude
        frequency *= lacunarity
        amplitude *= gain
    }
    return sum
}

@inlinable
func perlin_turbulence(_ p: vec3f, _ lacunarity: Float = 2,
                       _ gain: Float = 0.5, _ octaves: Int = 6, _ wrap: vec3i = zero3i) -> Float {
    var frequency: Float = 1.0
    var amplitude: Float = 1.0
    var sum: Float = 0.0
    for _ in 0..<octaves {
        sum += abs(perlin_noise(p * frequency, wrap) * 2 - 1) * amplitude
        frequency *= lacunarity
        amplitude *= gain
    }
    return sum
}

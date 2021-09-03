//
//  shape.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/3.
//

import Foundation

// -----------------------------------------------------------------------------
// EXAMPLE SHAPES
// -----------------------------------------------------------------------------

// Make a tessellated rectangle. Useful in other subdivisions.
func make_quads(_ steps: vec2i, _ scale: vec2f, _ uvscale: vec2f) -> shape_data {
    var shape = shape_data()

    shape.positions = .init(repeating: vec3f(), count: (steps.x + 1) * (steps.y + 1))
    shape.normals = .init(repeating: vec3f(), count: (steps.x + 1) * (steps.y + 1))
    shape.texcoords = .init(repeating: vec2f(), count: (steps.x + 1) * (steps.y + 1))
    for j in 0...steps.y {
        for i in 0...steps.x {
            let uv = vec2f(Float(i) / Float(steps.x), Float(j) / Float(steps.y))
            shape.positions[j * (steps.x + 1) + i] = [
                (2 * uv.x - 1) * scale.x, (2 * uv.y - 1) * scale.y, 0]
            shape.normals[j * (steps.x + 1) + i] = [0, 0, 1]
            shape.texcoords[j * (steps.x + 1) + i] = vec2f(uv.x, 1 - uv.y) * uvscale
        }
    }

    shape.quads = .init(repeating: vec4i(), count: steps.x * steps.y)
    for j in 0..<steps.y {
        for i in 0..<steps.x {
            shape.quads[j * steps.x + i] = [j * (steps.x + 1) + i,
                                            j * (steps.x + 1) + i + 1,
                                            (j + 1) * (steps.x + 1) + i + 1,
                                            (j + 1) * (steps.x + 1) + i]
        }
    }

    return shape
}

// Merge shape elements
func merge_shape_inplace(_ shape: inout shape_data, _ merge: shape_data) {
    let offset = shape.positions.count
    for p in merge.points {
        shape.points.append(p + offset)
    }
    for l in merge.lines {
        shape.lines.append([l.x + offset, l.y + offset])
    }
    for t in merge.triangles {
        shape.triangles.append([t.x + offset, t.y + offset, t.z + offset])
    }
    for q in merge.quads {
        shape.quads.append([q.x + offset, q.y + offset, q.z + offset, q.w + offset])
    }
    shape.positions.append(contentsOf: merge.positions)
    shape.tangents.append(contentsOf: merge.tangents)
    shape.texcoords.append(contentsOf: merge.texcoords)
    shape.colors.append(contentsOf: merge.colors)
    shape.radius.append(contentsOf: merge.radius)
}

// Make a plane.
func make_rect(_ steps: vec2i = [1, 1], _ scale: vec2f = [1, 1],
               _ uvscale: vec2f = [1, 1]) -> shape_data {
    make_quads(steps, scale, uvscale)
}

func make_bulged_rect(_ steps: vec2i = [1, 1],
                      _ scale: vec2f = [1, 1], _ uvscale: vec2f = [1, 1],
                      _ height: Float = 0.3) -> shape_data {
    var height = height
    var shape = make_rect(steps, scale, uvscale)
    if (height != 0) {
        height = min(height, min(scale))
        let radius = (1 + height * height) / (2 * height)
        let center = vec3f(0, 0, -radius + height)
        for i in 0..<shape.positions.count {
            let pn = normalize(shape.positions[i] - center)
            shape.positions[i] = center + pn * radius
            shape.normals[i] = pn
        }
    }
    return shape
}

// Make a plane in the xz plane.
func make_recty(_ steps: vec2i = [1, 1], _ scale: vec2f = [1, 1],
                _ uvscale: vec2f = [1, 1]) -> shape_data {
    var shape = make_rect(steps, scale, uvscale)
    shape.positions = shape.positions.map { position -> vec3f in
        var position = position
        position = [position.x, position.z, -position.y]
        return position
    }
    shape.normals = shape.normals.map({ normal -> vec3f in
        var normal = normal
        normal = [normal.x, normal.z, normal.y]
        return normal
    })

    return shape
}

func make_bulged_recty(_ steps: vec2i = [1, 1],
                       _ scale: vec2f = [1, 1], _ uvscale: vec2f = [1, 1],
                       _ height: Float = 0.3) -> shape_data {
    var shape = make_bulged_rect(steps, scale, uvscale, height)
    shape.positions = shape.positions.map { position -> vec3f in
        var position = position
        position = [position.x, position.z, -position.y]
        return position
    }
    shape.normals = shape.normals.map({ normal -> vec3f in
        var normal = normal
        normal = [normal.x, normal.z, normal.y]
        return normal
    })
    return shape
}

// Make a box.
func make_box(_ steps: vec3i = [1, 1, 1],
              _ scale: vec3f = [1, 1, 1], _ uvscale: vec3f = [1, 1, 1]) -> shape_data {
    var shape = shape_data()
    var qshape = shape_data()
    // + z
    qshape = make_rect(
            [steps.x, steps.y], [scale.x, scale.y], [uvscale.x, uvscale.y])
    qshape.positions = qshape.positions.map({ p in
        var p = p
        p = [p.x, p.y, scale.z]
        return p
    })
    qshape.normals = qshape.normals.map({ n in
        var n = n
        n = [0, 0, 1]
        return n
    })
    merge_shape_inplace(&shape, qshape)
    // - z
    qshape = make_rect([steps.x, steps.y], [scale.x, scale.y], [uvscale.x, uvscale.y])
    qshape.positions = qshape.positions.map({ p in
        var p = p
        p = [-p.x, p.y, -scale.z]
        return p
    })
    qshape.normals = qshape.normals.map({ n in
        var n = n
        n = [0, 0, -1]
        return n
    })
    merge_shape_inplace(&shape, qshape)
    // + x
    qshape = make_rect([steps.z, steps.y], [scale.z, scale.y], [uvscale.z, uvscale.y])
    qshape.positions = qshape.positions.map({ p in
        var p = p
        p = [scale.x, p.y, -p.x]
        return p
    })
    qshape.normals = qshape.normals.map({ n in
        var n = n
        n = [1, 0, 0]
        return n
    })
    merge_shape_inplace(&shape, qshape)
    // - x
    qshape = make_rect([steps.z, steps.y], [scale.z, scale.y], [uvscale.z, uvscale.y])
    qshape.positions = qshape.positions.map({ p in
        var p = p
        p = [-scale.x, p.y, p.x]
        return p
    })
    qshape.normals = qshape.normals.map({ n in
        var n = n
        n = [-1, 0, 0]
        return n
    })
    merge_shape_inplace(&shape, qshape)
    // + y
    qshape = make_rect([steps.x, steps.z], [scale.x, scale.z], [uvscale.x, uvscale.z])
    for i in 0..<qshape.positions.count {
        qshape.positions[i] = [qshape.positions[i].x, scale.y, -qshape.positions[i].y]
        qshape.normals[i] = [0, 1, 0]
    }
    merge_shape_inplace(&shape, qshape)
    // - y
    qshape = make_rect([steps.x, steps.z], [scale.x, scale.z], [uvscale.x, uvscale.z])
    for i in 0..<qshape.positions.count {
        qshape.positions[i] = [qshape.positions[i].x, -scale.y, qshape.positions[i].y]
        qshape.normals[i] = [0, -1, 0]
    }
    merge_shape_inplace(&shape, qshape)
    return shape

}

func make_rounded_box(_ steps: vec3i = [1, 1, 1],
                      _ scale: vec3f = [1, 1, 1], _ uvscale: vec3f = [1, 1, 1],
                      _ radius: Float = 0.3) -> shape_data {
    var shape = make_box(steps, scale, uvscale)
    if (radius != 0) {
        let radius = min(radius, min(scale))
        let c = scale - radius
        for i in 0..<shape.positions.count {
            let pc = vec3f(abs(shape.positions[i].x), abs(shape.positions[i].y),
                    abs(shape.positions[i].z))
            let ps = vec3f(shape.positions[i].x < 0 ? -1.0 : 1.0,
                    shape.positions[i].y < 0 ? -1.0 : 1.0,
                    shape.positions[i].z < 0 ? -1.0 : 1.0)
            if (pc.x >= c.x && pc.y >= c.y && pc.z >= c.z) {
                let pn = normalize(pc - c)
                shape.positions[i] = c + radius * pn
                shape.normals[i] = pn
            } else if (pc.x >= c.x && pc.y >= c.y) {
                let pn = normalize((pc - c) * vec3f(1, 1, 0))
                shape.positions[i] = [c.x + radius * pn.x, c.y + radius * pn.y, pc.z]
                shape.normals[i] = pn
            } else if (pc.x >= c.x && pc.z >= c.z) {
                let pn = normalize((pc - c) * vec3f(1, 0, 1))
                shape.positions[i] = [c.x + radius * pn.x, pc.y, c.z + radius * pn.z]
                shape.normals[i] = pn
            } else if (pc.y >= c.y && pc.z >= c.z) {
                let pn = normalize((pc - c) * vec3f(0, 1, 1))
                shape.positions[i] = [pc.x, c.y + radius * pn.y, c.z + radius * pn.z]
                shape.normals[i] = pn
            } else {
                continue
            }
            shape.positions[i] *= ps
            shape.normals[i] *= ps
        }
    }
    return shape
}

// Make a quad stack
func make_rect_stack(_ steps: vec3i = [1, 1, 1],
                     _ scale: vec3f = [1, 1, 1], _ uvscale: vec2f = [1, 1]) -> shape_data {
    var shape = shape_data()
    var qshape = shape_data()
    for i in 0...steps.z {
        qshape = make_rect([steps.x, steps.y], [scale.x, scale.y], uvscale)
        qshape.positions = qshape.positions.map({ p in
            var p = p
            p.z = (-1 + 2 * Float(i) / Float(steps.z)) * scale.z
            return p
        })
        merge_shape_inplace(&shape, qshape)
    }
    return shape
}

// Make a floor.
func make_floor(_ steps: vec2i = [1, 1],
                _ scale: vec2f = [10, 10], _ uvscale: vec2f = [10, 10]) -> shape_data {
    var shape = make_rect(steps, scale, uvscale)
    shape.positions = shape.positions.map({ position in
        var position = position
        position = [position.x, position.z, -position.y]
        return position
    })
    shape.normals = shape.normals.map({ normal in
        var normal = normal
        normal = [normal.x, normal.z, normal.y]
        return normal
    })
    return shape
}

func make_bent_floor(_ steps: vec2i = [1, 1],
                     _ scale: vec2f = [10, 10], _ uvscale: vec2f = [10, 10],
                     _ radius: Float = 0.5) -> shape_data {
    var shape = make_floor(steps, scale, uvscale)
    if (radius != 0) {
        let radius = min(radius, scale.y)
        let start = (scale.y - radius) / 2
        let end = start + radius
        for i in 0..<shape.positions.count {
            if (shape.positions[i].z < -end) {
                shape.positions[i] = [
                    shape.positions[i].x, -shape.positions[i].z - end + radius, -end]
                shape.normals[i] = [0, 0, 1]
            } else if (shape.positions[i].z < -start &&
                    shape.positions[i].z >= -end) {
                let phi: Float = (Float.pi / 2) * (-shape.positions[i].z - start) / radius
                shape.positions[i] = [shape.positions[i].x, -cos(phi) * radius + radius,
                                      -sin(phi) * radius - start]
                shape.normals[i] = [0, cos(phi), sin(phi)]
            } else {
            }
        }
    }
    return shape
}

// Make a sphere.
func make_sphere(_ steps: Int = 32, _ scale: Float = 1, _ uvscale: Float = 1) -> shape_data {
    var shape = make_box([steps, steps, steps], [scale, scale, scale],
            [uvscale, uvscale, uvscale])
    shape.positions = shape.positions.map({ p in
        var p = p
        p = normalize(p) * scale
        return p
    })
    shape.normals = shape.positions
    shape.normals = shape.normals.map({ n in
        var n = n
        n = normalize(n)
        return n
    })
    return shape
}

// Make a sphere.
func make_uvsphere(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                   _ uvscale: vec2f = [1, 1]) -> shape_data {
    var shape = make_rect([1, 1], [1, 1])
    for i in 0..<shape.positions.count {
        let uv = shape.texcoords[i]
        let a = vec2f(2 * Float.pi * uv.x, Float.pi * (1 - uv.y))
        shape.positions[i] = vec3f(cos(a.x) * sin(a.y), sin(a.x) * sin(a.y), cos(a.y)) * scale
        shape.normals[i] = normalize(shape.positions[i])
        shape.texcoords[i] = uv * uvscale
    }
    return shape
}

func make_uvspherey(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                    _ uvscale: vec2f = [1, 1]) -> shape_data {
    var shape = make_uvsphere(steps, scale, uvscale)
    shape.positions = shape.positions.map({ position in
        [position.x, position.z, position.y]
    })
    shape.normals = shape.normals.map({ normal in
        [normal.x, normal.z, normal.y]
    })
    shape.texcoords = shape.texcoords.map({ texcoord in
        [texcoord.x, 1 - texcoord.y]
    })
    shape.quads = shape.quads.map({ quad in
        [quad.x, quad.w, quad.z, quad.y]
    })
    return shape
}

// Make a sphere with slipped caps.
func make_capped_uvsphere(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                          _ uvscale: vec2f = [1, 1], _ cap: Float = 0.3) -> shape_data {
    var shape = make_uvsphere(steps, scale, uvscale)
    if (cap != 0) {
        let cap = min(cap, scale / 2)
        let zflip = (scale - cap)
        for i in 0..<shape.positions.count {
            if (shape.positions[i].z > zflip) {
                shape.positions[i].z = 2 * zflip - shape.positions[i].z
                shape.normals[i].x = -shape.normals[i].x
                shape.normals[i].y = -shape.normals[i].y
            } else if (shape.positions[i].z < -zflip) {
                shape.positions[i].z = 2 * (-zflip) - shape.positions[i].z
                shape.normals[i].x = -shape.normals[i].x
                shape.normals[i].y = -shape.normals[i].y
            }
        }
    }
    return shape
}

func make_capped_uvspherey(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                           _ uvscale: vec2f = [1, 1], _ cap: Float = 0.3) -> shape_data {
    var shape = make_capped_uvsphere(steps, scale, uvscale, cap)
    shape.positions = shape.positions.map({ position in
        [position.x, position.z, position.y]
    })
    shape.normals = shape.normals.map({ normal in
        [normal.x, normal.z, normal.y]
    })
    shape.texcoords = shape.texcoords.map({ texcoord in
        [texcoord.x, 1 - texcoord.y]
    })
    shape.quads = shape.quads.map({ quad in
        [quad.x, quad.w, quad.z, quad.y]
    })
    return shape
}

// Make a disk
func make_disk(_ steps: Int = 32, _ scale: Float = 1, _ uvscale: Float = 1) -> shape_data {
    var shape = make_rect([steps, steps], [1, 1], [uvscale, uvscale])
    shape.positions = shape.positions.map({ position in
        // Analytical Methods for Squaring the Disc, by C. Fong
        // https://arxiv.org/abs/1509.06344
        let xy = vec2f(position.x, position.y)
        let uv = vec2f(xy.x * sqrt(1 - xy.y * xy.y / 2), xy.y * sqrt(1 - xy.x * xy.x / 2))
        return vec3f(uv.x, uv.y, 0) * scale
    })
    return shape
}

// Make a bulged disk
func make_bulged_disk(
        _ steps: Int = 32, _ scale: Float = 1, _ uvscale: Float = 1, _ height: Float = 0.3) -> shape_data {
    var shape = make_disk(steps, scale, uvscale)
    if (height != 0) {
        let height = min(height, scale)
        let radius = (1 + height * height) / (2 * height)
        let center = vec3f(0, 0, -radius + height)
        for i in 0..<shape.positions.count {
            let pn = normalize(shape.positions[i] - center)
            shape.positions[i] = center + pn * radius
            shape.normals[i] = pn
        }
    }
    return shape
}

// Make a uv disk
func make_uvdisk(_ steps: vec2i = [32, 32], _ scale: Float = 1,
                 _ uvscale: vec2f = [1, 1]) -> shape_data {
    var shape = make_rect(steps, [1, 1], [1, 1])
    for i in 0..<shape.positions.count {
        let uv = shape.texcoords[i]
        let phi = 2 * Float.pi * uv.x
        shape.positions[i] = vec3f(cos(phi) * uv.y, sin(phi) * uv.y, 0) * scale
        shape.normals[i] = [0, 0, 1]
        shape.texcoords[i] = uv * uvscale
    }
    return shape
}

// Make a uv cylinder
func make_uvcylinder(_ steps: vec3i = [32, 32, 32],
                     _ scale: vec2f = [1, 1], _ uvscale: vec3f = [1, 1, 1]) -> shape_data {
    var shape = shape_data()
    var qshape = shape_data()
    // side
    qshape = make_rect([steps.x, steps.y], [1, 1], [1, 1])
    for i in 0..<qshape.positions.count {
        let uv = qshape.texcoords[i]
        let phi = 2 * Float.pi * uv.x
        qshape.positions[i] = [cos(phi) * scale.x, sin(phi) * scale.x, (2 * uv.y - 1) * scale.y]
        qshape.normals[i] = [cos(phi), sin(phi), 0]
        qshape.texcoords[i] = uv * vec2f(uvscale.x, uvscale.y)
    }
    qshape.quads = qshape.quads.map({ quad in
        [quad.x, quad.w, quad.z, quad.y]
    })
    merge_shape_inplace(&shape, qshape)
    // top
    qshape = make_rect([steps.x, steps.z], [1, 1], [1, 1])
    for i in 0..<qshape.positions.count {
        let uv = qshape.texcoords[i]
        let phi = 2 * Float.pi * uv.x
        qshape.positions[i] = [cos(phi) * uv.y * scale.x, sin(phi) * uv.y * scale.x, 0]
        qshape.normals[i] = [0, 0, 1]
        qshape.texcoords[i] = uv * vec2f(uvscale.x, uvscale.z)
        qshape.positions[i].z = scale.y
    }
    merge_shape_inplace(&shape, qshape)
    // bottom
    qshape = make_rect([steps.x, steps.z], [1, 1], [1, 1])
    for i in 0..<qshape.positions.count {
        let uv = qshape.texcoords[i]
        let phi = 2 * Float.pi * uv.x
        qshape.positions[i] = [cos(phi) * uv.y * scale.x, sin(phi) * uv.y * scale.x, 0]
        qshape.normals[i] = [0, 0, 1]
        qshape.texcoords[i] = uv * vec2f(uvscale.x, uvscale.z)
        qshape.positions[i].z = -scale.y
        qshape.normals[i] = -qshape.normals[i]
    }
    qshape.quads = qshape.quads.map({ qquad in
        [qquad.z, qquad.y, qquad.x]
    })
    merge_shape_inplace(&shape, qshape)
    return shape
}

// Make a rounded uv cylinder
func make_rounded_uvcylinder(_ steps: vec3i = [32, 32, 32],
                             _ scale: vec2f = [1, 1], _ uvscale: vec3f = [1, 1, 1],
                             _ radius: Float = 0.3) -> shape_data {
    var shape = make_uvcylinder(steps, scale, uvscale)
    if (radius != 0) {
        let radius = min(radius, min(scale))
        let c = scale - radius
        for i in 0..<shape.positions.count {
            let phi = atan2(shape.positions[i].y, shape.positions[i].x)
            let r = length(vec2f(shape.positions[i].x, shape.positions[i].y))
            let z = shape.positions[i].z
            let pc = vec2f(r, abs(z))
            let ps: Float = (z < 0) ? -1.0 : 1.0
            if (pc.x >= c.x && pc.y >= c.y) {
                let pn = normalize(pc - c)
                shape.positions[i] = [cos(phi) * (c.x + radius * pn.x), sin(phi) * (c.x + radius * pn.x), ps * (c.y + radius * pn.y)]
                shape.normals[i] = [cos(phi) * pn.x, sin(phi) * pn.x, ps * pn.y]
            } else {
                continue
            }
        }
    }
    return shape
}

// Make a facevarying rect
func make_fvrect(_ steps: vec2i = [1, 1],
                 _ scale: vec2f = [1, 1], _ uvscale: vec2f = [1, 1]) -> fvshape_data {
    let rect = make_rect(steps, scale, uvscale)
    var shape = fvshape_data()
    shape.positions = rect.positions
    shape.normals = rect.normals
    shape.texcoords = rect.texcoords
    shape.quadspos = rect.quads
    shape.quadsnorm = rect.quads
    shape.quadstexcoord = rect.quads
    return shape
}

// Make a facevarying box
func make_fvbox(_ steps: vec3i = [1, 1, 1],
                _ scale: vec3f = [1, 1, 1], _ uvscale: vec3f = [1, 1, 1]) -> fvshape_data {
    var shape = fvshape_data()
    make_fvbox(&shape.quadspos, &shape.quadsnorm, &shape.quadstexcoord,
            &shape.positions, &shape.normals, &shape.texcoords, steps, scale, uvscale)
    return shape
}

// Make a facevarying sphere
func make_fvsphere(_ steps: Int = 32, _ scale: Float = 1, _ uvscale: Float = 1) -> fvshape_data {
    var shape = fvshape_data()
    make_fvsphere(&shape.quadspos, &shape.quadsnorm, &shape.quadstexcoord,
            &shape.positions, &shape.normals, &shape.texcoords, steps, scale, uvscale)
    return shape
}

// Generate lines set along a quad. Returns lines, pos, norm, texcoord, radius.
func make_lines(_ steps: vec2i = [4, 65536],
                _ scale: vec2f = [1, 1], _ uvscale: vec2f = [1, 1],
                _ rad: vec2f = [0.001, 0.001]) -> shape_data {
    var shape = shape_data()
    shape.positions = .init(repeating: vec3f(), count: (steps.x + 1) * steps.y)
    shape.normals = .init(repeating: vec3f(), count: (steps.x + 1) * steps.y)
    shape.texcoords = .init(repeating: vec2f(), count: (steps.x + 1) * steps.y)
    shape.radius = .init(repeating: 0, count: (steps.x + 1) * steps.y)
    if (steps.y > 1) {
        for j in 0..<steps.y {
            for i in 0...steps.x {
                let uv = vec2f(Float(i) / Float(steps.x), Float(j) / Float(steps.y - 1))
                shape.positions[j * (steps.x + 1) + i] = [(uv.x - 0.5) * scale.x, (uv.y - 0.5) * scale.y, 0]
                shape.normals[j * (steps.x + 1) + i] = [1, 0, 0]
                shape.texcoords[j * (steps.x + 1) + i] = uv * uvscale
                shape.radius[j * (steps.x + 1) + i] = interpolate_line(rad.x, rad.y, uv.x)
            }
        }
    } else {
        for i in 0...steps.x {
            let uv = vec2f(Float(i) / Float(steps.x), 0)
            shape.positions[i] = [(uv.x - 0.5) * scale.x, 0, 0]
            shape.normals[i] = [1, 0, 0]
            shape.texcoords[i] = uv * uvscale
            shape.radius[i] = interpolate_line(rad.x, rad.y, uv.x)
        }
    }

    shape.lines = .init(repeating: vec2i(), count: steps.x * steps.y)
    for j in 0..<steps.y {
        for i in 0..<steps.x {
            shape.lines[j * steps.x + i] = [j * (steps.x + 1) + i, j * (steps.x + 1) + i + 1]
        }
    }

    return shape
}

// Make a point primitive. Returns points, pos, norm, texcoord, radius.
func make_point(_ radius: Float = 0.001) -> shape_data {
    var shape = shape_data()
    shape.points = [0]
    shape.positions = [[0, 0, 0]]
    shape.normals = [[0, 0, 1]]
    shape.texcoords = [[0, 0]]
    shape.radius = [radius]
    return shape
}

// Make a point set on a grid. Returns points, pos, norm, texcoord, radius.
func make_points(_ num: Int = 65536, _ uvscale: Float = 1, _ radius: Float = 0.001) -> shape_data {
    var shape = shape_data()
    shape.points = .init(repeating: 0, count: num)
    for i in 0..<num {
        shape.points[i] = i
    }
    shape.positions.append(contentsOf: [vec3f](repeating: vec3f(), count: num))
    shape.normals.append(contentsOf: [vec3f](repeating: vec3f(0, 0, 1), count: num))
    shape.texcoords.append(contentsOf: [vec2f](repeating: vec2f(), count: num))
    shape.radius.append(contentsOf: [Float](repeating: radius, count: num))
    for i in 0..<shape.texcoords.count {
        shape.texcoords[i] = [Float(i) / Float(num), 0]
    }
    return shape
}

func make_points(_ steps: vec2i = [256, 256],
                 _ size: vec2f = [1, 1], _ uvscale: vec2f = [1, 1],
                 _ radius: vec2f = [0.001, 0.001]) -> shape_data {
    var shape = make_rect(steps, size, uvscale)
    shape.quads = []
    shape.points = .init(repeating: 0, count: shape.positions.count)
    for i in 0..<shape.positions.count {
        shape.points[i] = i
    }
    shape.radius = .init(repeating: 0.0, count: shape.positions.count)
    for i in 0..<shape.texcoords.count {
        shape.radius[i] = interpolate_line(radius.x, radius.y, shape.texcoords[i].y / uvscale.y)
    }
    return shape
}

// Make random points in a cube. Returns points, pos, norm, texcoord, radius.
func make_random_points(_ num: Int = 65536, _ size: vec3f = [1, 1, 1],
                        _ uvscale: Float = 1, _ radius: Float = 0.001, _ seed: UInt64 = 17) -> shape_data {
    fatalError()
}

// Predefined meshes
func make_monkey(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    fatalError()
}

func make_quad(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    fatalError()
}

func make_quady(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    fatalError()
}

func make_cube(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    fatalError()
}

func make_fvcube(_ scale: Float = 1, _ subdivisions: Int = 0) -> fvshape_data {
    fatalError()
}

func make_geosphere(_ scale: Float = 1, _  subdivisions: Int = 0) -> shape_data {
    fatalError()
}

// Make a hair ball around a shape.
// length: minimum and maximum length
// rad: minimum and maximum radius from base to tip
// noise: noise added to hair (strength/scale)
// clump: clump added to hair (strength/number)
// rotation: rotation added to hair (angle/strength)
func make_hair(_ shape: shape_data, _ steps: vec2i = [8, 65536],
               _ length: vec2f = [0.1, 0.1], _ radius: vec2f = [0.001, 0.001],
               _ noise: vec2f = [0, 10], _ clump: vec2f = [0, 128],
               _ rotation: vec2f = [0, 0], _ seed: Int = 7) -> shape_data {
    fatalError()
}

// Grow hairs around a shape
func make_hair2(_ shape: shape_data, _  steps: vec2i = [8, 65536],
                _ length: vec2f = [0.1, 0.1], _ radius: vec2f = [0.001, 0.001],
                _ noise: Float = 0, _ gravity: Float = 0.001, _ seed: Int = 7) -> shape_data {
    fatalError()
}

// Convert points to small spheres and lines to small cylinders. This is
// intended for making very small primitives for display in interactive
// applications, so the spheres are low res.
func points_to_spheres(_ vertices: [vec3f], _ steps: Int = 2, _ scale: Float = 0.01) -> shape_data {
    fatalError()
}

func polyline_to_cylinders(_ vertices: [vec3f], _ steps: Int = 4, _ scale: Float = 0.01) -> shape_data {
    fatalError()
}

func lines_to_cylinders(_ vertices: [vec3f], _ steps: Int = 4, _ scale: Float = 0.01) -> shape_data {
    fatalError()
}

func lines_to_cylinders(_ lines: [vec2i], _ positions: [vec3f],
                        _ steps: Int = 4, _ scale: Float = 0.01) -> shape_data {
    fatalError()
}

// Make a heightfield mesh.
func make_heightfield(_ size: vec2i, _ height: [Float]) -> shape_data {
    fatalError()
}

func make_heightfield(_ size: vec2i, _ color: [vec4f]) -> shape_data {
    fatalError()
}

// -----------------------------------------------------------------------------
// COMPUTATION OF PER_VERTEX PROPERTIES
// -----------------------------------------------------------------------------
// Compute per-vertex normals/tangents for lines/triangles/quads.
func lines_tangents(_ lines: [vec2i], _ positions: [vec3f]) -> [vec3f] {
    fatalError()
}

func triangles_normals(_ triangles: [vec3i], _ positions: [vec3f]) -> [vec3f] {
    fatalError()
}

func quads_normals(_ quads: [vec4i], _ positions: [vec3f]) -> [vec3f] {
    fatalError()
}

// Update normals and tangents
func lines_tangents(_ tangents: inout [vec3f], _ lines: [vec2i], _ positions: [vec3f]) {
    fatalError()
}

func triangles_normals(_ normals: inout [vec3f], _ triangles: [vec3i], _ positions: [vec3f]) {
    fatalError()
}

func quads_normals(_ normals: inout [vec3f], _ quads: [vec4i], _ positions: [vec3f]) {
    fatalError()
}

// Compute per-vertex tangent space for triangle meshes.
// Tangent space is defined by a four component vector.
// The first three components are the tangent with respect to the u texcoord.
// The fourth component is the sign of the tangent wrt the v texcoord.
// Tangent frame is useful in normal mapping.
func triangle_tangent_spaces(_ triangles: [vec3i], _ positions: [vec3f],
                             _ normals: [vec3f], _ texcoords: [vec2f]) -> [vec4f] {
    fatalError()
}

// Apply skinning to vertex position and normals.
func skin_vertices(_ positions: [vec3f], _ normals: [vec3f], _ weights: [vec4f],
                   _ joints: [vec4i], _ xforms: [frame3f]) -> ([vec3f], [vec3f]) {
    fatalError()
}

// Apply skinning as specified in Khronos glTF.
func skin_matrices(_ positions: [vec3f], _ normals: [vec3f], _ weights: [vec4f],
                   _ joints: [vec4i], _ xforms: [mat4f]) -> ([vec3f], [vec3f]) {
    fatalError()
}

// Update skinning
func skin_vertices(_ skinned_positions: inout [vec3f], _ skinned_normals: inout [vec3f], _ positions: [vec3f],
                   _ normals: [vec3f], _ weights: [vec4f],
                   _ joints: [vec4i], _ xforms: [frame3f]) {
    fatalError()
}

func skin_matrices(_ skinned_positions: inout [vec3f],
                   _ skinned_normals: inout [vec3f], _ positions: [vec3f],
                   _ normals: [vec3f], _ weights: [vec4f],
                   _ joints: [vec4i], _ xforms: [mat4f]) {
    fatalError()
}

// -----------------------------------------------------------------------------
// COMPUTATION OF VERTEX PROPERTIES
// -----------------------------------------------------------------------------
// Flip vertex normals
func flip_normals(_ normals: [vec3f]) -> [vec3f] {
    fatalError()
}

// Flip face orientation
func flip_triangles(_ triangles: [vec3i]) -> [vec3i] {
    fatalError()
}

func flip_quads(_ quads: [vec4i]) -> [vec4i] {
    fatalError()
}

// Align vertex positions. Alignment is 0: none, 1: min, 2: max, 3: center.
func align_vertices(_ positions: [vec3f], _ alignment: vec3i) -> [vec3f] {
    fatalError()
}

// -----------------------------------------------------------------------------
// SHAPE ELEMENT CONVERSION AND GROUPING
// -----------------------------------------------------------------------------
// Convert quads to triangles
func quads_to_triangles(_ quads: [vec4i]) -> [vec3i] {
    fatalError()
}

// Convert triangles to quads by creating degenerate quads
func triangles_to_quads(_ triangles: [vec3i]) -> [vec4i] {
    fatalError()
}

// Convert beziers to lines using 3 lines for each bezier.
func bezier_to_lines(_ lines: [vec2i]) -> [vec4i] {
    fatalError()
}

// Convert face-varying data to single primitives. Returns the quads indices
// and filled vectors for pos, norm and texcoord.
func split_facevarying(_ split_quads: inout [vec4i], _ split_positions: inout [vec3f], _ split_normals: inout [vec3f],
                       _ split_texcoords: inout [vec2f], _ quadspos: [vec4i],
                       _ quadsnorm: [vec4i], _ quadstexcoord: [vec4i],
                       _ positions: [vec3f], _ normals: [vec3f],
                       _ texcoords: [vec2f]) {
    fatalError()
}

// Weld vertices within a threshold.
func weld_vertices(_ positions: [vec3f], _ threshold: Float) -> ([vec3f], [Int]) {
    fatalError()
}

func weld_triangles(_ triangles: [vec3i], _ positions: [vec3f], _ threshold: Float) -> ([vec3i], [vec3f]) {
    fatalError()
}

func weld_quads(_ quads: [vec4i], _ positions: [vec3f], _ threshold: Float) -> ([vec4i], [vec3f]) {
    fatalError()
}

// Merge shape elements
func merge_lines(_ lines: inout [vec2i], _ positions: inout [vec3f],
                 _ tangents: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                 _ merge_lines: [vec2i], _ merge_positions: [vec3f],
                 _ merge_tangents: [vec3f],
                 _ merge_texturecoords: [vec2f],
                 _ merge_radius: [Float]) {
    fatalError()
}

func merge_triangles(_ triangles: inout [vec3i], _ positions: inout [vec3f],
                     _ normals: inout [vec3f], _ texcoords: inout[vec2f],
                     _ merge_triangles: [vec2i], _ merge_positions: [vec3f],
                     _ merge_normals: [vec3f], _ merge_texturecoords: [vec2f]) {
    fatalError()
}

func merge_quads(_ quads: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                 _ merge_quads: [vec4i], _ merge_positions: [vec3f],
                 _ merge_normals: [vec3f], _ merge_texturecoords: [vec2f]) {
    fatalError()
}

// -----------------------------------------------------------------------------
// SHAPE SUBDIVISION
// -----------------------------------------------------------------------------
// Subdivide lines by splitting each line in half.
func subdivide_lines(_ lines: [vec2i], _ vertex: [Float]) -> ([vec2i], [Float]) {
    fatalError()
}

func subdivide_lines(_ lines: [vec2i], _ vertex: [vec2f]) -> ([vec2i], [vec2f]) {
    fatalError()
}

func subdivide_lines(_ lines: [vec2i], _ vertex: [vec3f]) -> ([vec2i], [vec3f]) {
    fatalError()
}

func subdivide_lines(_ lines: [vec2i], _ vertex: [vec4f]) -> ([vec2i], [vec4f]) {
    fatalError()
}

// Subdivide triangle by splitting each triangle in four, creating new
// vertices for each edge.
func subdivide_triangles(_ triangles: [vec3i], _ vertex: [Float]) -> ([vec3i], [Float]) {
    fatalError()
}

func subdivide_triangles(_ triangles: [vec3i], _ vertex: [vec2f]) -> ([vec3i], [vec2f]) {
    fatalError()
}

func subdivide_triangles(_ triangles: [vec3i], _ vertex: [vec3f]) -> ([vec3i], [vec3f]) {
    fatalError()
}

func subdivide_triangles(_ triangles: [vec3i], _ vertex: [vec4f]) -> ([vec3i], [vec4f]) {
    fatalError()
}

// Subdivide quads by splitting each quads in four, creating new
// vertices for each edge and for each face.
func subdivide_quads(_ quads: [vec4i], _ vertex: [Float]) -> ([vec4i], [Float]) {
    fatalError()
}

func subdivide_quads(_ quads: [vec4i], _ vertex: [vec2f]) -> ([vec4i], [vec2f]) {
    fatalError()
}

func subdivide_quads(_ quads: [vec4i], _ vertex: [vec3f]) -> ([vec4i], [vec3f]) {
    fatalError()
}

func subdivide_quads(_ quads: [vec4i], _ vertex: [vec4f]) -> ([vec4i], [vec4f]) {
    fatalError()
}

// Subdivide beziers by splitting each segment in two.
func subdivide_beziers(_ beziers: [vec4i], _ vertex: [Float]) -> ([vec4i], [Float]) {
    fatalError()
}

func subdivide_beziers(_ beziers: [vec4i], _ vertex: [vec2f]) -> ([vec4i], [vec2f]) {
    fatalError()
}

func subdivide_beziers(_ beziers: [vec4i], _ vertex: [vec3f]) -> ([vec4i], [vec3f]) {
    fatalError()
}

func subdivide_beziers(_ beziers: [vec4i], _ vertex: [vec4f]) -> ([vec4i], [vec4f]) {
    fatalError()
}

// Subdivide quads using Catmull-Clark subdivision rules.
func subdivide_catmullclark(_ quads: [vec4i], _ vertex: [Float],
                            _ lock_boundary: Bool = false) -> ([vec4i], [Float]) {
    fatalError()
}

func subdivide_catmullclark(_ quads: [vec4i], _ vertex: [vec2f],
                            _ lock_boundary: Bool = false) -> ([vec4i], [vec2f]) {
    fatalError()
}

func subdivide_catmullclark(_ quads: [vec4i], _ vertex: [vec3f],
                            _ lock_boundary: Bool = false) -> ([vec4i], [vec3f]) {
    fatalError()
}

func subdivide_catmullclark(_ quads: [vec4i], _ vertex: [vec4f],
                            _ lock_boundary: Bool = false) -> ([vec4i], [vec4f]) {
    fatalError()
}

// Subdivide lines by splitting each line in half.
@inlinable func subdivide_lines<T>(_ lines: [vec2i], _ vertices: [T], _ level: Int) -> ([vec2i], [T]) {
    fatalError()
}

// Subdivide triangle by splitting each triangle in four, creating new
// vertices for each edge.
@inlinable func subdivide_triangles<T>(_ triangles: [vec3i], _ vertices: [T], _ level: Int) -> ([vec3i], [T]) {
    fatalError()
}

// Subdivide quads by splitting each quads in four, creating new
// vertices for each edge and for each face.
@inlinable func subdivide_quads<T>(_ quads: [vec4i], _ vertices: [T], _ level: Int) -> ([vec4i], [T]) {
    fatalError()
}

// Subdivide beziers by splitting each segment in two.
@inlinable func subdivide_beziers<T>(_ beziers: [vec4i], _ vertices: [T], _ level: Int) -> ([vec4i], [T]) {
    fatalError()
}

// Subdivide quads using Carmull-Clark subdivision rules.
@inlinable func subdivide_catmullclark<T>(_ quads: [vec4i], _ vertices: [T], _ level: Int,
                                          _ lock_boundary: Bool = false) -> ([vec4i], [T]) {
    fatalError()
}

// -----------------------------------------------------------------------------
// SHAPE SAMPLING
// -----------------------------------------------------------------------------
// Pick a point in a point set uniformly.
func sample_points(_ npoints: Int, _ re: Float) -> Int {
    fatalError()
}

func sample_points(_ cdf: [Float], _ re: Float) -> Int {
    fatalError()
}

func sample_points_cdf(_ npoints: Int) -> [Float] {
    fatalError()
}

func sample_points_cdf(_ cdf: inout [Float], _ npoints: Int) {
    fatalError()
}

// Pick a point on lines uniformly.
func sample_lines(_ cdf: [Float], _ re: Float, _ ru: Float) -> (Int, Float) {
    fatalError()
}

func sample_lines_cdf(_ lines: [vec2i], _ positions: [vec3f]) -> [Float] {
    fatalError()
}

func sample_lines_cdf(_ cdf: inout [Float], _ lines: [vec2i], _ positions: [vec3f]) {
    fatalError()
}

// Pick a point on a triangle mesh uniformly.
func sample_triangles(_ cdf: [Float], _ re: Float, _ ruv: vec2f) -> (Int, vec2f) {
    fatalError()
}

func sample_triangles_cdf(_ triangles: [vec3i], _  positions: [vec3f]) -> [Float] {
    fatalError()
}

func sample_triangles_cdf(_ cdf: inout [Float], _ triangles: [vec3i], _ positions: [vec3f]) {
    fatalError()
}

// Pick a point on a quad mesh uniformly.
func sample_quads(_ cdf: [Float], _ re: Float, _ ruv: vec2f) -> (Int, vec2f) {
    fatalError()
}

func sample_quads_cdf(_ quads: [vec4i], _ positions: [vec3f]) -> [Float] {
    fatalError()
}

func sample_quads_cdf(_ cdf: inout [Float], _ quads: [vec4i], _ positions: [vec3f]) {
    fatalError()
}

// Samples a set of points over a triangle/quad mesh uniformly. Returns pos,
// norm and texcoord of the sampled points.
func sample_triangles(_ sampled_positions: inout [vec3f], _ sampled_normals: inout [vec3f], _ sampled_texcoords: inout [vec2f],
                      _ triangles: [vec3i], _ positions: [vec3f], _ normals: [vec3f],
                      _ texcoords: [vec2f], _ npoints: Int, _ seed: Int = 7) {
    fatalError()
}

func sample_quads(_ sampled_positions: inout [vec3f], _ sampled_normals: inout [vec3f], _ sampled_texcoords: inout [vec2f],
                  _ quads: [vec4i], _ positions: [vec3f], _ normals: [vec3f],
                  _ texcoords: [vec2f], _ npoints: Int, _ seed: Int = 7) {
    fatalError()
}

// -----------------------------------------------------------------------------
// SHAPE EXAMPLES
// -----------------------------------------------------------------------------
// Make a quad.
func make_rect(_ quads: inout [vec4i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
               _ scale: vec2f, _ uvscale: vec2f) {
    fatalError()
}

func make_bulged_rect(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                      _ scale: vec2f, _ uvscale: vec2f, _ height: Float) {
    fatalError()
}

// Make a quad.
func make_recty(_ quads: inout [vec4i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                _ scale: vec2f, _ uvscale: vec2f) {
    fatalError()
}

func make_bulged_recty(_ quads: inout [vec4i], _ positions: inout [vec3f],
                       _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                       _ scale: vec2f, _ uvscale: vec2f, _ height: Float) {
    fatalError()
}

// Make a cube.
func make_box(_ quads: inout [vec4i], _ positions: inout [vec3f],
              _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
              _ scale: vec3f, uvscale: vec3f) {
    fatalError()
}

func make_rounded_box(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                      _ scale: vec3f, _ uvscale: vec3f, _ radius: Float) {
    fatalError()
}

func make_rect_stack(_ quads: inout [vec4i], _ positions: inout [vec3f],
                     _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                     _ scale: vec3f, _ uvscale: vec2f) {
    fatalError()
}

func make_floor(_ quads: inout [vec4i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                _ scale: vec2f, _ uvscale: vec2f) {
    fatalError()
}

func make_bent_floor(_ quads: inout [vec4i], _ positions: inout [vec3f],
                     _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                     _ scale: vec2f, _ uvscale: vec2f, _ radius: Float) {
    fatalError()
}

// Generate a sphere
func make_sphere(_ quads: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: Int, _ scale: Float,
                 _ uvscale: Float) {
    fatalError()
}

// Generate a uvsphere
func make_uvsphere(_ quads: inout [vec4i], _ positions: inout [vec3f],
                   _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                   _ scale: Float, uvscale: vec2f) {
    fatalError()
}

func make_capped_uvsphere(_ quads: inout [vec4i], _ positions: inout [vec3f],
                          _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                          _ scale: Float, uvscale: vec2f, cap: Float) {
    fatalError()
}

func make_uvspherey(_ quads: inout [vec4i], _ positions: inout [vec3f],
                    _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                    _ scale: Float, _ uvscale: vec2f) {
    fatalError()
}

func make_capped_uvspherey(_ quads: inout [vec4i], _ positions: inout [vec3f],
                           _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                           _ scale: Float, _ uvscale: vec2f, _ cap: Float) {
    fatalError()
}

// Generate a disk
func make_disk(_ quads: inout [vec4i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: Int, _ scale: Float,
               _ uvscale: Float) {
    fatalError()
}

func make_bulged_disk(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: Int, _ scale: Float,
                      _ uvscale: Float, _ height: Float) {
    fatalError()
}

// Generate a uvdisk
func make_uvdisk(_ quads: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                 _ scale: Float, _ uvscale: vec2f) {
    fatalError()
}

// Generate a uvcylinder
func make_uvcylinder(_ quads: inout [vec4i], _ positions: inout [vec3f],
                     _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                     _ scale: vec2f, _ uvscale: vec3f) {
    fatalError()
}

// Generate a uvcylinder
func make_rounded_uvcylinder(_ quads: inout [vec4i], _ positions: inout [vec3f],
                             _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                             _ scale: vec2f, _ uvscale: vec3f, _ radius: Float) {
    fatalError()
}

// Generate lines set along a quad.
func make_lines(_ lines: inout [vec2i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                _ steps: vec2i, _ size: vec2f, _ uvscale: vec2f,
                _ rad: vec2f) {
    fatalError()
}

// Generate a point at the origin.
func make_point(_ points: inout [Int], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                _ point_radius: Float) {
    fatalError()
}

// Generate a point set with points placed at the origin with texcoords
// varying along u.
func make_points(_ points: inout [Int], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                 _ num: Int, _ uvscale: Float, _ point_radius: Float) {
    fatalError()
}

// Generate a point set along a quad.
func make_points(_ points: inout [Int], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                 _ steps: vec2i, _ size: vec2f, _ uvscale: vec2f,
                 _ rad: vec2f) {
    fatalError()
}

// Generate a point set.
func make_random_points(_ points: inout [Int], _ positions: inout [vec3f],
                        _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                        _ num: Int, size: vec3f, _ uvscale: Float, _ point_radius: Float,
                        _ seed: UInt64) {
    fatalError()
}

// Make a bezier circle. Returns bezier, pos.
func make_bezier_circle(_ beziers: inout [vec4i], _ positions: inout [vec3f], _ size: Float) {
    fatalError()
}

// Make fvquad
func make_fvrect(_ quadspos: inout [vec4i], _ quadsnorm: inout [vec4i],
                 _ quadstexcoord: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec2i,
                 _ size: vec2f, _ uvscale: vec2f) {
    fatalError()
}

func make_fvbox(_ quadspos: inout [vec4i], _ quadsnorm: inout [vec4i],
                _ quadstexcoord: inout [vec4i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: vec3i,
                _ size: vec3f, _ uvscale: vec3f) {
    fatalError()
}

func make_fvsphere(_ quadspos: inout [vec4i], _ quadsnorm: inout [vec4i],
                   _ quadstexcoord: inout [vec4i], _ positions: inout [vec3f],
                   _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ steps: Int, _ size: Float,
                   _ uvscale: Float) {
    fatalError()
}

// Predefined meshes
func make_monkey(_ quads: inout [vec4i], _ positions: inout [vec3f], _ scale: Float,
                 _ subdivisions: Int) {
    fatalError()
}

func make_quad(_ quads: inout [vec4i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ scale: Float,
               _ subdivisions: Int) {
    fatalError()
}

func make_quady(_ quads: inout [vec4i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ scale: Float,
                _ subdivisions: Int) {
    fatalError()
}

func make_cube(_ quads: inout [vec4i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ scale: Float,
               _ subdivisions: Int) {
    fatalError()
}

func make_fvcube(_ quadspos: inout [vec4i], _ quadsnorm: inout [vec4i],
                 _ quads: inout [vec4i], _ positions: inout [vec3f],
                 _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ scale: Float,
                 _ subdivisions: Int) {
    fatalError()
}

func make_geosphere(_ triangles: inout [vec3i], _ positions: inout [vec3f],
                    _ normals: inout [vec3f], _ scale: Float, _ subdivisions: Int) {
    fatalError()
}

// Convert points to small spheres and lines to small cylinders. This is
// intended for making very small primitives for display in interactive
// applications, so the spheres are low res and without texcoords and normals.
func points_to_spheres(_ quads: inout [vec4i], _ positions: inout [vec3f],
                       _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                       _ vertices: [vec3f], _ steps: Int = 2, _ scale: Float = 0.01) {
    fatalError()
}

func polyline_to_cylinders(_ quads: inout [vec4i], _ positions: inout [vec3f],
                           _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                           _ vertices: [vec3f], _ steps: Int = 4, _ scale: Float = 0.01) {
    fatalError()
}

func lines_to_cylinders(_ quads: inout [vec4i], _ positions: inout [vec3f],
                        _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                        _ vertices: [vec3f], _ steps: Int = 4, _ scale: Float = 0.01) {
    fatalError()
}

func lines_to_cylinders(_ quads: inout [vec4i], _ positions: inout [vec3f],
                        _ normals: inout [vec3f], _ texcoords: inout [vec2f],
                        _ lines: [vec2i], _ vertices: [vec3f], _ steps: Int = 4,
                        _ scale: Float = 0.01) {
    fatalError()
}

// Make a hair ball around a shape
func make_hair(_ lines: inout [vec2i], _ positions: inout [vec3f],
               _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
               _ striangles: [vec3i], _ squads: [vec4i],
               _ spos: [vec3f], _ snorm: [vec3f],
               _ stexcoord: [vec2f], _ steps: vec2i, _  len: vec2f,
               _ rad: vec2f, _ noise: vec2f, _ clump: vec2f,
               _ rotation: vec2f, _ seed: Int) {
    fatalError()
}

// Grow hairs around a shape
func make_hair2(_ lines: inout [vec2i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ radius: inout [Float],
                _ striangles: [vec3i], _ squads: [vec4i],
                _ spos: [vec3f], _  snorm: [vec3f],
                _ stexcoord: [vec2f], _  steps: vec2i, _  len: vec2f,
                _ rad: vec2f, _  noise: Float, _  gravity: Float, _  seed: Int) {
    fatalError()
}

// Thickens a shape by copy9ing the shape content, rescaling it and flipping
// its normals. Note that this is very much not robust and only useful for
// trivial cases.
func make_shell(_ quads: inout [vec4i], _ positions: inout [vec3f],
                _ normals: inout [vec3f], _ texcoords: inout [vec2f], _ thickness: Float) {
    fatalError()
}

// Make a heightfield mesh.
func make_heightfield(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _  texcoords: inout [vec2f], _  size: vec2i,
                      _ height: [Float]) {
    fatalError()
}

func make_heightfield(_ quads: inout [vec4i], _ positions: inout [vec3f],
                      _ normals: inout [vec3f], _  texcoords: inout [vec2f], _  size: vec2i,
                      _ color: [vec4f]) {
    fatalError()
}

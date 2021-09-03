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
    var shape = shape_data()
    if (subdivisions == 0) {
        shape.quads = suzanne_quads
        shape.positions = suzanne_positions
    } else {
        (shape.quads, shape.positions) = subdivide_quads(
                suzanne_quads, suzanne_positions, subdivisions)
    }
    if (scale != 1) {
        shape.positions = shape.positions.map { p in
            p * scale
        }
    }
    return shape
}

func make_quad(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    let quad_positions: [vec3f] = [
        [-1, -1, 0], [1, -1, 0], [1, 1, 0], [-1, 1, 0]]
    let quad_normals: [vec3f] = [
        [0, 0, 1], [0, 0, 1], [0, 0, 1], [0, 0, 1]]
    let quad_texcoords: [vec2f] = [
        [0, 1], [1, 1], [1, 0], [0, 0]]
    let quad_quads: [vec4i] = [[0, 1, 2, 3]]
    var shape = shape_data()
    if (subdivisions == 0) {
        shape.quads = quad_quads
        shape.positions = quad_positions
        shape.normals = quad_normals
        shape.texcoords = quad_texcoords
    } else {
        (shape.quads, shape.positions) = subdivide_quads(
                quad_quads, quad_positions, subdivisions)
        (shape.quads, shape.normals) = subdivide_quads(
                quad_quads, quad_normals, subdivisions)
        (shape.quads, shape.texcoords) = subdivide_quads(
                quad_quads, quad_texcoords, subdivisions)
    }
    if (scale != 1) {
        shape.positions = shape.positions.map({ p in
            p * scale
        })
    }
    return shape
}

func make_quady(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    let quady_positions: [vec3f] = [
        [-1, 0, -1], [-1, 0, +1], [1, 0, 1], [1, 0, -1]]
    let quady_normals: [vec3f] = [
        [0, 1, 0], [0, 1, 0], [0, 1, 0], [0, 1, 0]]
    let quady_texcoords: [vec2f] = [
        [0, 0], [1, 0], [1, 1], [0, 1]]
    let quady_quads: [vec4i] = [[0, 1, 2, 3]]
    var shape = shape_data()
    if (subdivisions == 0) {
        shape.quads = quady_quads
        shape.positions = quady_positions
        shape.normals = quady_normals
        shape.texcoords = quady_texcoords
    } else {
        (shape.quads, shape.positions) = subdivide_quads(
                quady_quads, quady_positions, subdivisions)
        (shape.quads, shape.normals) = subdivide_quads(
                quady_quads, quady_normals, subdivisions)
        (shape.quads, shape.texcoords) = subdivide_quads(
                quady_quads, quady_texcoords, subdivisions)
    }
    if (scale != 1) {
        shape.positions = shape.positions.map({ p in
            p * scale
        })
    }
    return shape
}

func make_cube(_ scale: Float = 1, _ subdivisions: Int = 0) -> shape_data {
    let cube_positions: [vec3f] = [
        [-1, -1, +1], [+1, -1, +1],
        [1, +1, +1], [-1, +1, +1], [+1, -1, -1], [-1, -1, -1], [-1, +1, -1],
        [1, +1, -1], [+1, -1, +1], [+1, -1, -1], [+1, +1, -1], [+1, +1, +1],
        [-1, -1, -1], [-1, -1, +1], [-1, +1, +1], [-1, +1, -1], [-1, +1, +1],
        [1, +1, +1], [+1, +1, -1], [-1, +1, -1], [+1, -1, +1], [-1, -1, +1],
        [-1, -1, -1], [+1, -1, -1]]
    let cube_normals: [vec3f] = [
        [0, 0, +1], [0, 0, +1],
        [0, 0, +1], [0, 0, +1], [0, 0, -1], [0, 0, -1], [0, 0, -1], [0, 0, -1],
        [1, 0, 0], [+1, 0, 0], [+1, 0, 0], [+1, 0, 0], [-1, 0, 0], [-1, 0, 0],
        [-1, 0, 0], [-1, 0, 0], [0, +1, 0], [0, +1, 0], [0, +1, 0], [0, +1, 0],
        [0, -1, 0], [0, -1, 0], [0, -1, 0], [0, -1, 0]]
    let cube_texcoords: [vec2f] = [
        [0, 1], [1, 1], [1, 0],
        [0, 0], [0, 1], [1, 1], [1, 0], [0, 0], [0, 1], [1, 1], [1, 0], [0, 0],
        [0, 1], [1, 1], [1, 0], [0, 0], [0, 1], [1, 1], [1, 0], [0, 0], [0, 1],
        [1, 1], [1, 0], [0, 0]]
    let cube_quads: [vec4i] = [
        [0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11], [12, 13, 14, 15], [16, 17, 18, 19], [20, 21, 22, 23]]

    var shape = shape_data()
    if (subdivisions == 0) {
        shape.quads = cube_quads
        shape.positions = cube_positions
        shape.normals = cube_normals
        shape.texcoords = cube_texcoords
    } else {
        (shape.quads, shape.positions) = subdivide_quads(
                cube_quads, cube_positions, subdivisions)
        (shape.quads, shape.normals) = subdivide_quads(
                cube_quads, cube_normals, subdivisions)
        (shape.quads, shape.texcoords) = subdivide_quads(
                cube_quads, cube_texcoords, subdivisions)
    }
    if (scale != 1) {
        shape.positions = shape.positions.map({ p in
            p * scale
        })
    }
    return shape
}

func make_fvcube(_ scale: Float = 1, _ subdivisions: Int = 0) -> fvshape_data {
    let fvcube_positions: [vec3f] = [
        [-1, -1, +1], [+1, -1, +1],
        [1, +1, +1], [-1, +1, +1], [+1, -1, -1], [-1, -1, -1], [-1, +1, -1],
        [1, +1, -1]]
    let fvcube_normals: [vec3f] = [
        [0, 0, +1], [0, 0, +1],
        [0, 0, +1], [0, 0, +1], [0, 0, -1], [0, 0, -1], [0, 0, -1], [0, 0, -1],
        [1, 0, 0], [+1, 0, 0], [+1, 0, 0], [+1, 0, 0], [-1, 0, 0], [-1, 0, 0],
        [-1, 0, 0], [-1, 0, 0], [0, +1, 0], [0, +1, 0], [0, +1, 0], [0, +1, 0],
        [0, -1, 0], [0, -1, 0], [0, -1, 0], [0, -1, 0]]
    let fvcube_texcoords: [vec2f] = [
        [0, 1], [1, 1], [1, 0],
        [0, 0], [0, 1], [1, 1], [1, 0], [0, 0], [0, 1], [1, 1], [1, 0], [0, 0],
        [0, 1], [1, 1], [1, 0], [0, 0], [0, 1], [1, 1], [1, 0], [0, 0], [0, 1],
        [1, 1], [1, 0], [0, 0]]
    let fvcube_quadspos: [vec4i] = [
        [0, 1, 2, 3], [4, 5, 6, 7],
        [1, 4, 7, 2], [5, 0, 3, 6], [3, 2, 7, 6], [1, 0, 5, 4]]
    let fvcube_quadsnorm: [vec4i] = [
        [0, 1, 2, 3], [4, 5, 6, 7],
        [8, 9, 10, 11], [12, 13, 14, 15], [16, 17, 18, 19], [20, 21, 22, 23]]
    let fvcube_quadstexcoord: [vec4i] = [
        [0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11],
        [12, 13, 14, 15], [16, 17, 18, 19], [20, 21, 22, 23]]

    var shape = fvshape_data()
    if (subdivisions == 0) {
        shape.quadspos = fvcube_quadspos
        shape.quadsnorm = fvcube_quadsnorm
        shape.quadstexcoord = fvcube_quadstexcoord
        shape.positions = fvcube_positions
        shape.normals = fvcube_normals
        shape.texcoords = fvcube_texcoords
    } else {
        (shape.quadspos, shape.positions) = subdivide_quads(
                fvcube_quadspos, fvcube_positions, subdivisions)
        (shape.quadsnorm, shape.normals) = subdivide_quads(
                fvcube_quadsnorm, fvcube_normals, subdivisions)
        (shape.quadstexcoord, shape.texcoords) = subdivide_quads(
                fvcube_quadstexcoord, fvcube_texcoords, subdivisions)
    }
    if (scale != 1) {
        shape.positions = shape.positions.map({ p in
            p * scale
        })
    }
    return shape
}

func make_geosphere(_ scale: Float = 1, _  subdivisions: Int = 0) -> shape_data {
    // https://stackoverflow.com/questions/17705621/algorithm-for-a-geodesic-sphere
    let X: Float = 0.525731112119133606
    let Z: Float = 0.850650808352039932
    let geosphere_positions: [vec3f] = [
        [-X, 0.0, Z], [X, 0.0, Z],
        [-X, 0.0, -Z], [X, 0.0, -Z], [0.0, Z, X], [0.0, Z, -X], [0.0, -Z, X],
        [0.0, -Z, -X], [Z, X, 0.0], [-Z, X, 0.0], [Z, -X, 0.0], [-Z, -X, 0.0]]
    let geosphere_triangles: [vec3i] = [
        [0, 1, 4], [0, 4, 9],
        [9, 4, 5], [4, 8, 5], [4, 1, 8], [8, 1, 10], [8, 10, 3], [5, 8, 3],
        [5, 3, 2], [2, 3, 7], [7, 3, 10], [7, 10, 6], [7, 6, 11], [11, 6, 0],
        [0, 6, 1], [6, 10, 1], [9, 11, 0], [9, 2, 11], [9, 5, 2], [7, 11, 2]]

    var shape = shape_data()
    if (subdivisions == 0) {
        shape.triangles = geosphere_triangles
        shape.positions = geosphere_positions
        shape.normals = geosphere_positions
    } else {
        (shape.triangles, shape.positions) = subdivide_triangles(
                geosphere_triangles, geosphere_positions, subdivisions)
        shape.positions = shape.positions.map({ position in
            normalize(position)
        })
        shape.normals = shape.positions
    }
    if (scale != 1) {
        shape.positions = shape.positions.map({ p in
            p * scale
        })
    }
    return shape
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
    var shape = make_recty([size.x - 1, size.y - 1], vec2f(Float(size.x), Float(size.y)) / Float(max(size)), [1, 1])
    for j in 0..<size.y {
        for i in 0..<size.x {
            shape.positions[j * size.x + i].y = height[j * size.x + i]
        }
    }
    shape.normals = quads_normals(shape.quads, shape.positions)
    return shape
}

func make_heightfield(_ size: vec2i, _ color: [vec4f]) -> shape_data {
    var shape = make_recty([size.x - 1, size.y - 1],
            vec2f(Float(size.x), Float(size.y)) / Float(max(size)), [1, 1])
    for j in 0..<size.y {
        for i in 0..<size.x {
            shape.positions[j * size.x + i].y = mean(xyz(color[j * size.x + i]))
        }
    }
    shape.normals = quads_normals(shape.quads, shape.positions)
    return shape
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

// -----------------------------------------------------------------------------
// SHAPE DATA
// -----------------------------------------------------------------------------

let suzanne_positions: [vec3f] = [
    [0.4375, 0.1640625, 0.765625],
    [-0.4375, 0.1640625, 0.765625], [0.5, 0.09375, 0.6875],
    [-0.5, 0.09375, 0.6875], [0.546875, 0.0546875, 0.578125],
    [-0.546875, 0.0546875, 0.578125], [0.3515625, -0.0234375, 0.6171875],
    [-0.3515625, -0.0234375, 0.6171875], [0.3515625, 0.03125, 0.71875],
    [-0.3515625, 0.03125, 0.71875], [0.3515625, 0.1328125, 0.78125],
    [-0.3515625, 0.1328125, 0.78125], [0.2734375, 0.1640625, 0.796875],
    [-0.2734375, 0.1640625, 0.796875], [0.203125, 0.09375, 0.7421875],
    [-0.203125, 0.09375, 0.7421875], [0.15625, 0.0546875, 0.6484375],
    [-0.15625, 0.0546875, 0.6484375], [0.078125, 0.2421875, 0.65625],
    [-0.078125, 0.2421875, 0.65625], [0.140625, 0.2421875, 0.7421875],
    [-0.140625, 0.2421875, 0.7421875], [0.2421875, 0.2421875, 0.796875],
    [-0.2421875, 0.2421875, 0.796875], [0.2734375, 0.328125, 0.796875],
    [-0.2734375, 0.328125, 0.796875], [0.203125, 0.390625, 0.7421875],
    [-0.203125, 0.390625, 0.7421875], [0.15625, 0.4375, 0.6484375],
    [-0.15625, 0.4375, 0.6484375], [0.3515625, 0.515625, 0.6171875],
    [-0.3515625, 0.515625, 0.6171875], [0.3515625, 0.453125, 0.71875],
    [-0.3515625, 0.453125, 0.71875], [0.3515625, 0.359375, 0.78125],
    [-0.3515625, 0.359375, 0.78125], [0.4375, 0.328125, 0.765625],
    [-0.4375, 0.328125, 0.765625], [0.5, 0.390625, 0.6875],
    [-0.5, 0.390625, 0.6875], [0.546875, 0.4375, 0.578125],
    [-0.546875, 0.4375, 0.578125], [0.625, 0.2421875, 0.5625],
    [-0.625, 0.2421875, 0.5625], [0.5625, 0.2421875, 0.671875],
    [-0.5625, 0.2421875, 0.671875], [0.46875, 0.2421875, 0.7578125],
    [-0.46875, 0.2421875, 0.7578125], [0.4765625, 0.2421875, 0.7734375],
    [-0.4765625, 0.2421875, 0.7734375], [0.4453125, 0.3359375, 0.78125],
    [-0.4453125, 0.3359375, 0.78125], [0.3515625, 0.375, 0.8046875],
    [-0.3515625, 0.375, 0.8046875], [0.265625, 0.3359375, 0.8203125],
    [-0.265625, 0.3359375, 0.8203125], [0.2265625, 0.2421875, 0.8203125],
    [-0.2265625, 0.2421875, 0.8203125], [0.265625, 0.15625, 0.8203125],
    [-0.265625, 0.15625, 0.8203125], [0.3515625, 0.2421875, 0.828125],
    [-0.3515625, 0.2421875, 0.828125], [0.3515625, 0.1171875, 0.8046875],
    [-0.3515625, 0.1171875, 0.8046875], [0.4453125, 0.15625, 0.78125],
    [-0.4453125, 0.15625, 0.78125], [0.0, 0.4296875, 0.7421875],
    [0.0, 0.3515625, 0.8203125], [0.0, -0.6796875, 0.734375],
    [0.0, -0.3203125, 0.78125], [0.0, -0.1875, 0.796875],
    [0.0, -0.7734375, 0.71875], [0.0, 0.40625, 0.6015625],
    [0.0, 0.5703125, 0.5703125], [0.0, 0.8984375, -0.546875],
    [0.0, 0.5625, -0.8515625], [0.0, 0.0703125, -0.828125],
    [0.0, -0.3828125, -0.3515625], [0.203125, -0.1875, 0.5625],
    [-0.203125, -0.1875, 0.5625], [0.3125, -0.4375, 0.5703125],
    [-0.3125, -0.4375, 0.5703125], [0.3515625, -0.6953125, 0.5703125],
    [-0.3515625, -0.6953125, 0.5703125], [0.3671875, -0.890625, 0.53125],
    [-0.3671875, -0.890625, 0.53125], [0.328125, -0.9453125, 0.5234375],
    [-0.328125, -0.9453125, 0.5234375], [0.1796875, -0.96875, 0.5546875],
    [-0.1796875, -0.96875, 0.5546875], [0.0, -0.984375, 0.578125],
    [0.4375, -0.140625, 0.53125], [-0.4375, -0.140625, 0.53125],
    [0.6328125, -0.0390625, 0.5390625], [-0.6328125, -0.0390625, 0.5390625],
    [0.828125, 0.1484375, 0.4453125], [-0.828125, 0.1484375, 0.4453125],
    [0.859375, 0.4296875, 0.59375], [-0.859375, 0.4296875, 0.59375],
    [0.7109375, 0.484375, 0.625], [-0.7109375, 0.484375, 0.625],
    [0.4921875, 0.6015625, 0.6875], [-0.4921875, 0.6015625, 0.6875],
    [0.3203125, 0.7578125, 0.734375], [-0.3203125, 0.7578125, 0.734375],
    [0.15625, 0.71875, 0.7578125], [-0.15625, 0.71875, 0.7578125],
    [0.0625, 0.4921875, 0.75], [-0.0625, 0.4921875, 0.75],
    [0.1640625, 0.4140625, 0.7734375], [-0.1640625, 0.4140625, 0.7734375],
    [0.125, 0.3046875, 0.765625], [-0.125, 0.3046875, 0.765625],
    [0.203125, 0.09375, 0.7421875], [-0.203125, 0.09375, 0.7421875],
    [0.375, 0.015625, 0.703125], [-0.375, 0.015625, 0.703125],
    [0.4921875, 0.0625, 0.671875], [-0.4921875, 0.0625, 0.671875],
    [0.625, 0.1875, 0.6484375], [-0.625, 0.1875, 0.6484375],
    [0.640625, 0.296875, 0.6484375], [-0.640625, 0.296875, 0.6484375],
    [0.6015625, 0.375, 0.6640625], [-0.6015625, 0.375, 0.6640625],
    [0.4296875, 0.4375, 0.71875], [-0.4296875, 0.4375, 0.71875],
    [0.25, 0.46875, 0.7578125], [-0.25, 0.46875, 0.7578125],
    [0.0, -0.765625, 0.734375], [0.109375, -0.71875, 0.734375],
    [-0.109375, -0.71875, 0.734375], [0.1171875, -0.8359375, 0.7109375],
    [-0.1171875, -0.8359375, 0.7109375], [0.0625, -0.8828125, 0.6953125],
    [-0.0625, -0.8828125, 0.6953125], [0.0, -0.890625, 0.6875],
    [0.0, -0.1953125, 0.75], [0.0, -0.140625, 0.7421875],
    [0.1015625, -0.1484375, 0.7421875], [-0.1015625, -0.1484375, 0.7421875],
    [0.125, -0.2265625, 0.75], [-0.125, -0.2265625, 0.75],
    [0.0859375, -0.2890625, 0.7421875], [-0.0859375, -0.2890625, 0.7421875],
    [0.3984375, -0.046875, 0.671875], [-0.3984375, -0.046875, 0.671875],
    [0.6171875, 0.0546875, 0.625], [-0.6171875, 0.0546875, 0.625],
    [0.7265625, 0.203125, 0.6015625], [-0.7265625, 0.203125, 0.6015625],
    [0.7421875, 0.375, 0.65625], [-0.7421875, 0.375, 0.65625],
    [0.6875, 0.4140625, 0.7265625], [-0.6875, 0.4140625, 0.7265625],
    [0.4375, 0.546875, 0.796875], [-0.4375, 0.546875, 0.796875],
    [0.3125, 0.640625, 0.8359375], [-0.3125, 0.640625, 0.8359375],
    [0.203125, 0.6171875, 0.8515625], [-0.203125, 0.6171875, 0.8515625],
    [0.1015625, 0.4296875, 0.84375], [-0.1015625, 0.4296875, 0.84375],
    [0.125, -0.1015625, 0.8125], [-0.125, -0.1015625, 0.8125],
    [0.2109375, -0.4453125, 0.7109375], [-0.2109375, -0.4453125, 0.7109375],
    [0.25, -0.703125, 0.6875], [-0.25, -0.703125, 0.6875],
    [0.265625, -0.8203125, 0.6640625], [-0.265625, -0.8203125, 0.6640625],
    [0.234375, -0.9140625, 0.6328125], [-0.234375, -0.9140625, 0.6328125],
    [0.1640625, -0.9296875, 0.6328125], [-0.1640625, -0.9296875, 0.6328125],
    [0.0, -0.9453125, 0.640625], [0.0, 0.046875, 0.7265625],
    [0.0, 0.2109375, 0.765625], [0.328125, 0.4765625, 0.7421875],
    [-0.328125, 0.4765625, 0.7421875], [0.1640625, 0.140625, 0.75],
    [-0.1640625, 0.140625, 0.75], [0.1328125, 0.2109375, 0.7578125],
    [-0.1328125, 0.2109375, 0.7578125], [0.1171875, -0.6875, 0.734375],
    [-0.1171875, -0.6875, 0.734375], [0.078125, -0.4453125, 0.75],
    [-0.078125, -0.4453125, 0.75], [0.0, -0.4453125, 0.75],
    [0.0, -0.328125, 0.7421875], [0.09375, -0.2734375, 0.78125],
    [-0.09375, -0.2734375, 0.78125], [0.1328125, -0.2265625, 0.796875],
    [-0.1328125, -0.2265625, 0.796875], [0.109375, -0.1328125, 0.78125],
    [-0.109375, -0.1328125, 0.78125], [0.0390625, -0.125, 0.78125],
    [-0.0390625, -0.125, 0.78125], [0.0, -0.203125, 0.828125],
    [0.046875, -0.1484375, 0.8125], [-0.046875, -0.1484375, 0.8125],
    [0.09375, -0.15625, 0.8125], [-0.09375, -0.15625, 0.8125],
    [0.109375, -0.2265625, 0.828125], [-0.109375, -0.2265625, 0.828125],
    [0.078125, -0.25, 0.8046875], [-0.078125, -0.25, 0.8046875],
    [0.0, -0.2890625, 0.8046875], [0.2578125, -0.3125, 0.5546875],
    [-0.2578125, -0.3125, 0.5546875], [0.1640625, -0.2421875, 0.7109375],
    [-0.1640625, -0.2421875, 0.7109375], [0.1796875, -0.3125, 0.7109375],
    [-0.1796875, -0.3125, 0.7109375], [0.234375, -0.25, 0.5546875],
    [-0.234375, -0.25, 0.5546875], [0.0, -0.875, 0.6875],
    [0.046875, -0.8671875, 0.6875], [-0.046875, -0.8671875, 0.6875],
    [0.09375, -0.8203125, 0.7109375], [-0.09375, -0.8203125, 0.7109375],
    [0.09375, -0.7421875, 0.7265625], [-0.09375, -0.7421875, 0.7265625],
    [0.0, -0.78125, 0.65625], [0.09375, -0.75, 0.6640625],
    [-0.09375, -0.75, 0.6640625], [0.09375, -0.8125, 0.640625],
    [-0.09375, -0.8125, 0.640625], [0.046875, -0.8515625, 0.6328125],
    [-0.046875, -0.8515625, 0.6328125], [0.0, -0.859375, 0.6328125],
    [0.171875, 0.21875, 0.78125], [-0.171875, 0.21875, 0.78125],
    [0.1875, 0.15625, 0.7734375], [-0.1875, 0.15625, 0.7734375],
    [0.3359375, 0.4296875, 0.7578125], [-0.3359375, 0.4296875, 0.7578125],
    [0.2734375, 0.421875, 0.7734375], [-0.2734375, 0.421875, 0.7734375],
    [0.421875, 0.3984375, 0.7734375], [-0.421875, 0.3984375, 0.7734375],
    [0.5625, 0.3515625, 0.6953125], [-0.5625, 0.3515625, 0.6953125],
    [0.5859375, 0.2890625, 0.6875], [-0.5859375, 0.2890625, 0.6875],
    [0.578125, 0.1953125, 0.6796875], [-0.578125, 0.1953125, 0.6796875],
    [0.4765625, 0.1015625, 0.71875], [-0.4765625, 0.1015625, 0.71875],
    [0.375, 0.0625, 0.7421875], [-0.375, 0.0625, 0.7421875],
    [0.2265625, 0.109375, 0.78125], [-0.2265625, 0.109375, 0.78125],
    [0.1796875, 0.296875, 0.78125], [-0.1796875, 0.296875, 0.78125],
    [0.2109375, 0.375, 0.78125], [-0.2109375, 0.375, 0.78125],
    [0.234375, 0.359375, 0.7578125], [-0.234375, 0.359375, 0.7578125],
    [0.1953125, 0.296875, 0.7578125], [-0.1953125, 0.296875, 0.7578125],
    [0.2421875, 0.125, 0.7578125], [-0.2421875, 0.125, 0.7578125],
    [0.375, 0.0859375, 0.7265625], [-0.375, 0.0859375, 0.7265625],
    [0.4609375, 0.1171875, 0.703125], [-0.4609375, 0.1171875, 0.703125],
    [0.546875, 0.2109375, 0.671875], [-0.546875, 0.2109375, 0.671875],
    [0.5546875, 0.28125, 0.671875], [-0.5546875, 0.28125, 0.671875],
    [0.53125, 0.3359375, 0.6796875], [-0.53125, 0.3359375, 0.6796875],
    [0.4140625, 0.390625, 0.75], [-0.4140625, 0.390625, 0.75],
    [0.28125, 0.3984375, 0.765625], [-0.28125, 0.3984375, 0.765625],
    [0.3359375, 0.40625, 0.75], [-0.3359375, 0.40625, 0.75],
    [0.203125, 0.171875, 0.75], [-0.203125, 0.171875, 0.75],
    [0.1953125, 0.2265625, 0.75], [-0.1953125, 0.2265625, 0.75],
    [0.109375, 0.4609375, 0.609375], [-0.109375, 0.4609375, 0.609375],
    [0.1953125, 0.6640625, 0.6171875], [-0.1953125, 0.6640625, 0.6171875],
    [0.3359375, 0.6875, 0.59375], [-0.3359375, 0.6875, 0.59375],
    [0.484375, 0.5546875, 0.5546875], [-0.484375, 0.5546875, 0.5546875],
    [0.6796875, 0.453125, 0.4921875], [-0.6796875, 0.453125, 0.4921875],
    [0.796875, 0.40625, 0.4609375], [-0.796875, 0.40625, 0.4609375],
    [0.7734375, 0.1640625, 0.375], [-0.7734375, 0.1640625, 0.375],
    [0.6015625, 0.0, 0.4140625], [-0.6015625, 0.0, 0.4140625],
    [0.4375, -0.09375, 0.46875], [-0.4375, -0.09375, 0.46875],
    [0.0, 0.8984375, 0.2890625], [0.0, 0.984375, -0.078125],
    [0.0, -0.1953125, -0.671875], [0.0, -0.4609375, 0.1875],
    [0.0, -0.9765625, 0.4609375], [0.0, -0.8046875, 0.34375],
    [0.0, -0.5703125, 0.3203125], [0.0, -0.484375, 0.28125],
    [0.8515625, 0.234375, 0.0546875], [-0.8515625, 0.234375, 0.0546875],
    [0.859375, 0.3203125, -0.046875], [-0.859375, 0.3203125, -0.046875],
    [0.7734375, 0.265625, -0.4375], [-0.7734375, 0.265625, -0.4375],
    [0.4609375, 0.4375, -0.703125], [-0.4609375, 0.4375, -0.703125],
    [0.734375, -0.046875, 0.0703125], [-0.734375, -0.046875, 0.0703125],
    [0.59375, -0.125, -0.1640625], [-0.59375, -0.125, -0.1640625],
    [0.640625, -0.0078125, -0.4296875], [-0.640625, -0.0078125, -0.4296875],
    [0.3359375, 0.0546875, -0.6640625], [-0.3359375, 0.0546875, -0.6640625],
    [0.234375, -0.3515625, 0.40625], [-0.234375, -0.3515625, 0.40625],
    [0.1796875, -0.4140625, 0.2578125], [-0.1796875, -0.4140625, 0.2578125],
    [0.2890625, -0.7109375, 0.3828125], [-0.2890625, -0.7109375, 0.3828125],
    [0.25, -0.5, 0.390625], [-0.25, -0.5, 0.390625],
    [0.328125, -0.9140625, 0.3984375], [-0.328125, -0.9140625, 0.3984375],
    [0.140625, -0.7578125, 0.3671875], [-0.140625, -0.7578125, 0.3671875],
    [0.125, -0.5390625, 0.359375], [-0.125, -0.5390625, 0.359375],
    [0.1640625, -0.9453125, 0.4375], [-0.1640625, -0.9453125, 0.4375],
    [0.21875, -0.28125, 0.4296875], [-0.21875, -0.28125, 0.4296875],
    [0.2109375, -0.2265625, 0.46875], [-0.2109375, -0.2265625, 0.46875],
    [0.203125, -0.171875, 0.5], [-0.203125, -0.171875, 0.5],
    [0.2109375, -0.390625, 0.1640625], [-0.2109375, -0.390625, 0.1640625],
    [0.296875, -0.3125, -0.265625], [-0.296875, -0.3125, -0.265625],
    [0.34375, -0.1484375, -0.5390625], [-0.34375, -0.1484375, -0.5390625],
    [0.453125, 0.8671875, -0.3828125], [-0.453125, 0.8671875, -0.3828125],
    [0.453125, 0.9296875, -0.0703125], [-0.453125, 0.9296875, -0.0703125],
    [0.453125, 0.8515625, 0.234375], [-0.453125, 0.8515625, 0.234375],
    [0.4609375, 0.5234375, 0.4296875], [-0.4609375, 0.5234375, 0.4296875],
    [0.7265625, 0.40625, 0.3359375], [-0.7265625, 0.40625, 0.3359375],
    [0.6328125, 0.453125, 0.28125], [-0.6328125, 0.453125, 0.28125],
    [0.640625, 0.703125, 0.0546875], [-0.640625, 0.703125, 0.0546875],
    [0.796875, 0.5625, 0.125], [-0.796875, 0.5625, 0.125],
    [0.796875, 0.6171875, -0.1171875], [-0.796875, 0.6171875, -0.1171875],
    [0.640625, 0.75, -0.1953125], [-0.640625, 0.75, -0.1953125],
    [0.640625, 0.6796875, -0.4453125], [-0.640625, 0.6796875, -0.4453125],
    [0.796875, 0.5390625, -0.359375], [-0.796875, 0.5390625, -0.359375],
    [0.6171875, 0.328125, -0.5859375], [-0.6171875, 0.328125, -0.5859375],
    [0.484375, 0.0234375, -0.546875], [-0.484375, 0.0234375, -0.546875],
    [0.8203125, 0.328125, -0.203125], [-0.8203125, 0.328125, -0.203125],
    [0.40625, -0.171875, 0.1484375], [-0.40625, -0.171875, 0.1484375],
    [0.4296875, -0.1953125, -0.2109375], [-0.4296875, -0.1953125, -0.2109375],
    [0.890625, 0.40625, -0.234375], [-0.890625, 0.40625, -0.234375],
    [0.7734375, -0.140625, -0.125], [-0.7734375, -0.140625, -0.125],
    [1.0390625, -0.1015625, -0.328125], [-1.0390625, -0.1015625, -0.328125],
    [1.28125, 0.0546875, -0.4296875], [-1.28125, 0.0546875, -0.4296875],
    [1.3515625, 0.3203125, -0.421875], [-1.3515625, 0.3203125, -0.421875],
    [1.234375, 0.5078125, -0.421875], [-1.234375, 0.5078125, -0.421875],
    [1.0234375, 0.4765625, -0.3125], [-1.0234375, 0.4765625, -0.3125],
    [1.015625, 0.4140625, -0.2890625], [-1.015625, 0.4140625, -0.2890625],
    [1.1875, 0.4375, -0.390625], [-1.1875, 0.4375, -0.390625],
    [1.265625, 0.2890625, -0.40625], [-1.265625, 0.2890625, -0.40625],
    [1.2109375, 0.078125, -0.40625], [-1.2109375, 0.078125, -0.40625],
    [1.03125, -0.0390625, -0.3046875], [-1.03125, -0.0390625, -0.3046875],
    [0.828125, -0.0703125, -0.1328125], [-0.828125, -0.0703125, -0.1328125],
    [0.921875, 0.359375, -0.21875], [-0.921875, 0.359375, -0.21875],
    [0.9453125, 0.3046875, -0.2890625], [-0.9453125, 0.3046875, -0.2890625],
    [0.8828125, -0.0234375, -0.2109375], [-0.8828125, -0.0234375, -0.2109375],
    [1.0390625, 0.0, -0.3671875], [-1.0390625, 0.0, -0.3671875],
    [1.1875, 0.09375, -0.4453125], [-1.1875, 0.09375, -0.4453125],
    [1.234375, 0.25, -0.4453125], [-1.234375, 0.25, -0.4453125],
    [1.171875, 0.359375, -0.4375], [-1.171875, 0.359375, -0.4375],
    [1.0234375, 0.34375, -0.359375], [-1.0234375, 0.34375, -0.359375],
    [0.84375, 0.2890625, -0.2109375], [-0.84375, 0.2890625, -0.2109375],
    [0.8359375, 0.171875, -0.2734375], [-0.8359375, 0.171875, -0.2734375],
    [0.7578125, 0.09375, -0.2734375], [-0.7578125, 0.09375, -0.2734375],
    [0.8203125, 0.0859375, -0.2734375], [-0.8203125, 0.0859375, -0.2734375],
    [0.84375, 0.015625, -0.2734375], [-0.84375, 0.015625, -0.2734375],
    [0.8125, -0.015625, -0.2734375], [-0.8125, -0.015625, -0.2734375],
    [0.7265625, 0.0, -0.0703125], [-0.7265625, 0.0, -0.0703125],
    [0.71875, -0.0234375, -0.171875], [-0.71875, -0.0234375, -0.171875],
    [0.71875, 0.0390625, -0.1875], [-0.71875, 0.0390625, -0.1875],
    [0.796875, 0.203125, -0.2109375], [-0.796875, 0.203125, -0.2109375],
    [0.890625, 0.2421875, -0.265625], [-0.890625, 0.2421875, -0.265625],
    [0.890625, 0.234375, -0.3203125], [-0.890625, 0.234375, -0.3203125],
    [0.8125, -0.015625, -0.3203125], [-0.8125, -0.015625, -0.3203125],
    [0.8515625, 0.015625, -0.3203125], [-0.8515625, 0.015625, -0.3203125],
    [0.828125, 0.078125, -0.3203125], [-0.828125, 0.078125, -0.3203125],
    [0.765625, 0.09375, -0.3203125], [-0.765625, 0.09375, -0.3203125],
    [0.84375, 0.171875, -0.3203125], [-0.84375, 0.171875, -0.3203125],
    [1.0390625, 0.328125, -0.4140625], [-1.0390625, 0.328125, -0.4140625],
    [1.1875, 0.34375, -0.484375], [-1.1875, 0.34375, -0.484375],
    [1.2578125, 0.2421875, -0.4921875], [-1.2578125, 0.2421875, -0.4921875],
    [1.2109375, 0.0859375, -0.484375], [-1.2109375, 0.0859375, -0.484375],
    [1.046875, 0.0, -0.421875], [-1.046875, 0.0, -0.421875],
    [0.8828125, -0.015625, -0.265625], [-0.8828125, -0.015625, -0.265625],
    [0.953125, 0.2890625, -0.34375], [-0.953125, 0.2890625, -0.34375],
    [0.890625, 0.109375, -0.328125], [-0.890625, 0.109375, -0.328125],
    [0.9375, 0.0625, -0.3359375], [-0.9375, 0.0625, -0.3359375],
    [1.0, 0.125, -0.3671875], [-1.0, 0.125, -0.3671875],
    [0.9609375, 0.171875, -0.3515625], [-0.9609375, 0.171875, -0.3515625],
    [1.015625, 0.234375, -0.375], [-1.015625, 0.234375, -0.375],
    [1.0546875, 0.1875, -0.3828125], [-1.0546875, 0.1875, -0.3828125],
    [1.109375, 0.2109375, -0.390625], [-1.109375, 0.2109375, -0.390625],
    [1.0859375, 0.2734375, -0.390625], [-1.0859375, 0.2734375, -0.390625],
    [1.0234375, 0.4375, -0.484375], [-1.0234375, 0.4375, -0.484375],
    [1.25, 0.46875, -0.546875], [-1.25, 0.46875, -0.546875],
    [1.3671875, 0.296875, -0.5], [-1.3671875, 0.296875, -0.5],
    [1.3125, 0.0546875, -0.53125], [-1.3125, 0.0546875, -0.53125],
    [1.0390625, -0.0859375, -0.4921875], [-1.0390625, -0.0859375, -0.4921875],
    [0.7890625, -0.125, -0.328125], [-0.7890625, -0.125, -0.328125],
    [0.859375, 0.3828125, -0.3828125], [-0.859375, 0.3828125, -0.3828125]]

let suzanne_quads: [vec4i] = [
    [46, 0, 2, 44], [3, 1, 47, 45],
    [44, 2, 4, 42], [5, 3, 45, 43], [2, 8, 6, 4], [7, 9, 3, 5], [0, 10, 8, 2],
    [9, 11, 1, 3], [10, 12, 14, 8], [15, 13, 11, 9], [8, 14, 16, 6],
    [17, 15, 9, 7], [14, 20, 18, 16], [19, 21, 15, 17], [12, 22, 20, 14],
    [21, 23, 13, 15], [22, 24, 26, 20], [27, 25, 23, 21], [20, 26, 28, 18],
    [29, 27, 21, 19], [26, 32, 30, 28], [31, 33, 27, 29], [24, 34, 32, 26],
    [33, 35, 25, 27], [34, 36, 38, 32], [39, 37, 35, 33], [32, 38, 40, 30],
    [41, 39, 33, 31], [38, 44, 42, 40], [43, 45, 39, 41], [36, 46, 44, 38],
    [45, 47, 37, 39], [46, 36, 50, 48], [51, 37, 47, 49], [36, 34, 52, 50],
    [53, 35, 37, 51], [34, 24, 54, 52], [55, 25, 35, 53], [24, 22, 56, 54],
    [57, 23, 25, 55], [22, 12, 58, 56], [59, 13, 23, 57], [12, 10, 62, 58],
    [63, 11, 13, 59], [10, 0, 64, 62], [65, 1, 11, 63], [0, 46, 48, 64],
    [49, 47, 1, 65], [88, 173, 175, 90], [175, 174, 89, 90], [86, 171, 173, 88],
    [174, 172, 87, 89], [84, 169, 171, 86], [172, 170, 85, 87],
    [82, 167, 169, 84], [170, 168, 83, 85], [80, 165, 167, 82],
    [168, 166, 81, 83], [78, 91, 145, 163], [146, 92, 79, 164],
    [91, 93, 147, 145], [148, 94, 92, 146], [93, 95, 149, 147],
    [150, 96, 94, 148], [95, 97, 151, 149], [152, 98, 96, 150],
    [97, 99, 153, 151], [154, 100, 98, 152], [99, 101, 155, 153],
    [156, 102, 100, 154], [101, 103, 157, 155], [158, 104, 102, 156],
    [103, 105, 159, 157], [160, 106, 104, 158], [105, 107, 161, 159],
    [162, 108, 106, 160], [107, 66, 67, 161], [67, 66, 108, 162],
    [109, 127, 159, 161], [160, 128, 110, 162], [127, 178, 157, 159],
    [158, 179, 128, 160], [125, 155, 157, 178], [158, 156, 126, 179],
    [123, 153, 155, 125], [156, 154, 124, 126], [121, 151, 153, 123],
    [154, 152, 122, 124], [119, 149, 151, 121], [152, 150, 120, 122],
    [117, 147, 149, 119], [150, 148, 118, 120], [115, 145, 147, 117],
    [148, 146, 116, 118], [113, 163, 145, 115], [146, 164, 114, 116],
    [113, 180, 176, 163], [176, 181, 114, 164], [109, 161, 67, 111],
    [67, 162, 110, 112], [111, 67, 177, 182], [177, 67, 112, 183],
    [176, 180, 182, 177], [183, 181, 176, 177], [134, 136, 175, 173],
    [175, 136, 135, 174], [132, 134, 173, 171], [174, 135, 133, 172],
    [130, 132, 171, 169], [172, 133, 131, 170], [165, 186, 184, 167],
    [185, 187, 166, 168], [130, 169, 167, 184], [168, 170, 131, 185],
    [143, 189, 188, 186], [188, 189, 144, 187], [184, 186, 188, 68],
    [188, 187, 185, 68], [129, 130, 184, 68], [185, 131, 129, 68],
    [141, 192, 190, 143], [191, 193, 142, 144], [139, 194, 192, 141],
    [193, 195, 140, 142], [138, 196, 194, 139], [195, 197, 138, 140],
    [137, 70, 196, 138], [197, 70, 137, 138], [189, 143, 190, 69],
    [191, 144, 189, 69], [69, 190, 205, 207], [206, 191, 69, 207],
    [70, 198, 199, 196], [200, 198, 70, 197], [196, 199, 201, 194],
    [202, 200, 197, 195], [194, 201, 203, 192], [204, 202, 195, 193],
    [192, 203, 205, 190], [206, 204, 193, 191], [198, 203, 201, 199],
    [202, 204, 198, 200], [198, 207, 205, 203], [206, 207, 198, 204],
    [138, 139, 163, 176], [164, 140, 138, 176], [139, 141, 210, 163],
    [211, 142, 140, 164], [141, 143, 212, 210], [213, 144, 142, 211],
    [143, 186, 165, 212], [166, 187, 144, 213], [80, 208, 212, 165],
    [213, 209, 81, 166], [208, 214, 210, 212], [211, 215, 209, 213],
    [78, 163, 210, 214], [211, 164, 79, 215], [130, 129, 71, 221],
    [71, 129, 131, 222], [132, 130, 221, 219], [222, 131, 133, 220],
    [134, 132, 219, 217], [220, 133, 135, 218], [136, 134, 217, 216],
    [218, 135, 136, 216], [216, 217, 228, 230], [229, 218, 216, 230],
    [217, 219, 226, 228], [227, 220, 218, 229], [219, 221, 224, 226],
    [225, 222, 220, 227], [221, 71, 223, 224], [223, 71, 222, 225],
    [223, 230, 228, 224], [229, 230, 223, 225], [182, 180, 233, 231],
    [234, 181, 183, 232], [111, 182, 231, 253], [232, 183, 112, 254],
    [109, 111, 253, 255], [254, 112, 110, 256], [180, 113, 251, 233],
    [252, 114, 181, 234], [113, 115, 249, 251], [250, 116, 114, 252],
    [115, 117, 247, 249], [248, 118, 116, 250], [117, 119, 245, 247],
    [246, 120, 118, 248], [119, 121, 243, 245], [244, 122, 120, 246],
    [121, 123, 241, 243], [242, 124, 122, 244], [123, 125, 239, 241],
    [240, 126, 124, 242], [125, 178, 235, 239], [236, 179, 126, 240],
    [178, 127, 237, 235], [238, 128, 179, 236], [127, 109, 255, 237],
    [256, 110, 128, 238], [237, 255, 257, 275], [258, 256, 238, 276],
    [235, 237, 275, 277], [276, 238, 236, 278], [239, 235, 277, 273],
    [278, 236, 240, 274], [241, 239, 273, 271], [274, 240, 242, 272],
    [243, 241, 271, 269], [272, 242, 244, 270], [245, 243, 269, 267],
    [270, 244, 246, 268], [247, 245, 267, 265], [268, 246, 248, 266],
    [249, 247, 265, 263], [266, 248, 250, 264], [251, 249, 263, 261],
    [264, 250, 252, 262], [233, 251, 261, 279], [262, 252, 234, 280],
    [255, 253, 259, 257], [260, 254, 256, 258], [253, 231, 281, 259],
    [282, 232, 254, 260], [231, 233, 279, 281], [280, 234, 232, 282],
    [66, 107, 283, 72], [284, 108, 66, 72], [107, 105, 285, 283],
    [286, 106, 108, 284], [105, 103, 287, 285], [288, 104, 106, 286],
    [103, 101, 289, 287], [290, 102, 104, 288], [101, 99, 291, 289],
    [292, 100, 102, 290], [99, 97, 293, 291], [294, 98, 100, 292],
    [97, 95, 295, 293], [296, 96, 98, 294], [95, 93, 297, 295],
    [298, 94, 96, 296], [93, 91, 299, 297], [300, 92, 94, 298],
    [307, 308, 327, 337], [328, 308, 307, 338], [306, 307, 337, 335],
    [338, 307, 306, 336], [305, 306, 335, 339], [336, 306, 305, 340],
    [88, 90, 305, 339], [305, 90, 89, 340], [86, 88, 339, 333],
    [340, 89, 87, 334], [84, 86, 333, 329], [334, 87, 85, 330],
    [82, 84, 329, 331], [330, 85, 83, 332], [329, 335, 337, 331],
    [338, 336, 330, 332], [329, 333, 339, 335], [340, 334, 330, 336],
    [325, 331, 337, 327], [338, 332, 326, 328], [80, 82, 331, 325],
    [332, 83, 81, 326], [208, 341, 343, 214], [344, 342, 209, 215],
    [80, 325, 341, 208], [342, 326, 81, 209], [78, 214, 343, 345],
    [344, 215, 79, 346], [78, 345, 299, 91], [300, 346, 79, 92],
    [76, 323, 351, 303], [352, 324, 76, 303], [303, 351, 349, 77],
    [350, 352, 303, 77], [77, 349, 347, 304], [348, 350, 77, 304],
    [304, 347, 327, 308], [328, 348, 304, 308], [325, 327, 347, 341],
    [348, 328, 326, 342], [295, 297, 317, 309], [318, 298, 296, 310],
    [75, 315, 323, 76], [324, 316, 75, 76], [301, 357, 355, 302],
    [356, 358, 301, 302], [302, 355, 353, 74], [354, 356, 302, 74],
    [74, 353, 315, 75], [316, 354, 74, 75], [291, 293, 361, 363],
    [362, 294, 292, 364], [363, 361, 367, 365], [368, 362, 364, 366],
    [365, 367, 369, 371], [370, 368, 366, 372], [371, 369, 375, 373],
    [376, 370, 372, 374], [313, 377, 373, 375], [374, 378, 314, 376],
    [315, 353, 373, 377], [374, 354, 316, 378], [353, 355, 371, 373],
    [372, 356, 354, 374], [355, 357, 365, 371], [366, 358, 356, 372],
    [357, 359, 363, 365], [364, 360, 358, 366], [289, 291, 363, 359],
    [364, 292, 290, 360], [73, 359, 357, 301], [358, 360, 73, 301],
    [283, 285, 287, 289], [288, 286, 284, 290], [283, 289, 359, 73],
    [360, 290, 284, 73], [293, 295, 309, 361], [310, 296, 294, 362],
    [309, 311, 367, 361], [368, 312, 310, 362], [311, 381, 369, 367],
    [370, 382, 312, 368], [313, 375, 369, 381], [370, 376, 314, 382],
    [347, 349, 385, 383], [386, 350, 348, 384], [317, 383, 385, 319],
    [386, 384, 318, 320], [297, 299, 383, 317], [384, 300, 298, 318],
    [299, 343, 341, 383], [342, 344, 300, 384], [313, 321, 379, 377],
    [380, 322, 314, 378], [315, 377, 379, 323], [380, 378, 316, 324],
    [319, 385, 379, 321], [380, 386, 320, 322], [349, 351, 379, 385],
    [380, 352, 350, 386], [399, 387, 413, 401], [414, 388, 400, 402],
    [399, 401, 403, 397], [404, 402, 400, 398], [397, 403, 405, 395],
    [406, 404, 398, 396], [395, 405, 407, 393], [408, 406, 396, 394],
    [393, 407, 409, 391], [410, 408, 394, 392], [391, 409, 411, 389],
    [412, 410, 392, 390], [409, 419, 417, 411], [418, 420, 410, 412],
    [407, 421, 419, 409], [420, 422, 408, 410], [405, 423, 421, 407],
    [422, 424, 406, 408], [403, 425, 423, 405], [424, 426, 404, 406],
    [401, 427, 425, 403], [426, 428, 402, 404], [401, 413, 415, 427],
    [416, 414, 402, 428], [317, 319, 443, 441], [444, 320, 318, 442],
    [319, 389, 411, 443], [412, 390, 320, 444], [309, 317, 441, 311],
    [442, 318, 310, 312], [381, 429, 413, 387], [414, 430, 382, 388],
    [411, 417, 439, 443], [440, 418, 412, 444], [437, 445, 443, 439],
    [444, 446, 438, 440], [433, 445, 437, 435], [438, 446, 434, 436],
    [431, 447, 445, 433], [446, 448, 432, 434], [429, 447, 431, 449],
    [432, 448, 430, 450], [413, 429, 449, 415], [450, 430, 414, 416],
    [311, 447, 429, 381], [430, 448, 312, 382], [311, 441, 445, 447],
    [446, 442, 312, 448], [415, 449, 451, 475], [452, 450, 416, 476],
    [449, 431, 461, 451], [462, 432, 450, 452], [431, 433, 459, 461],
    [460, 434, 432, 462], [433, 435, 457, 459], [458, 436, 434, 460],
    [435, 437, 455, 457], [456, 438, 436, 458], [437, 439, 453, 455],
    [454, 440, 438, 456], [439, 417, 473, 453], [474, 418, 440, 454],
    [427, 415, 475, 463], [476, 416, 428, 464], [425, 427, 463, 465],
    [464, 428, 426, 466], [423, 425, 465, 467], [466, 426, 424, 468],
    [421, 423, 467, 469], [468, 424, 422, 470], [419, 421, 469, 471],
    [470, 422, 420, 472], [417, 419, 471, 473], [472, 420, 418, 474],
    [457, 455, 479, 477], [480, 456, 458, 478], [477, 479, 481, 483],
    [482, 480, 478, 484], [483, 481, 487, 485], [488, 482, 484, 486],
    [485, 487, 489, 491], [490, 488, 486, 492], [463, 475, 485, 491],
    [486, 476, 464, 492], [451, 483, 485, 475], [486, 484, 452, 476],
    [451, 461, 477, 483], [478, 462, 452, 484], [457, 477, 461, 459],
    [462, 478, 458, 460], [453, 473, 479, 455], [480, 474, 454, 456],
    [471, 481, 479, 473], [480, 482, 472, 474], [469, 487, 481, 471],
    [482, 488, 470, 472], [467, 489, 487, 469], [488, 490, 468, 470],
    [465, 491, 489, 467], [490, 492, 466, 468], [391, 389, 503, 501],
    [504, 390, 392, 502], [393, 391, 501, 499], [502, 392, 394, 500],
    [395, 393, 499, 497], [500, 394, 396, 498], [397, 395, 497, 495],
    [498, 396, 398, 496], [399, 397, 495, 493], [496, 398, 400, 494],
    [387, 399, 493, 505], [494, 400, 388, 506], [493, 501, 503, 505],
    [504, 502, 494, 506], [493, 495, 499, 501], [500, 496, 494, 502],
    [313, 381, 387, 505], [388, 382, 314, 506], [313, 505, 503, 321],
    [504, 506, 314, 322], [319, 321, 503, 389], [504, 322, 320, 390],
    // ttriangles
    [60, 64, 48, 48], [49, 65, 61, 61], [62, 64, 60, 60], [61, 65, 63, 63],
    [60, 58, 62, 62], [63, 59, 61, 61], [60, 56, 58, 58], [59, 57, 61, 61],
    [60, 54, 56, 56], [57, 55, 61, 61], [60, 52, 54, 54], [55, 53, 61, 61],
    [60, 50, 52, 52], [53, 51, 61, 61], [60, 48, 50, 50], [51, 49, 61, 61],
    [224, 228, 226, 226], [227, 229, 225, 255], [72, 283, 73, 73],
    [73, 284, 72, 72], [341, 347, 383, 383], [384, 348, 342, 342],
    [299, 345, 343, 343], [344, 346, 300, 300], [323, 379, 351, 351],
    [352, 380, 324, 324], [441, 443, 445, 445], [446, 444, 442, 442],
    [463, 491, 465, 465], [466, 492, 464, 464], [495, 497, 499, 499],
    [500, 498, 496, 496]]


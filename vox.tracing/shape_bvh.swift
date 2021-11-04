//
//  shape_bvh.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/3.
//

import Foundation

// BVH tree node containing its bounds, indices to the BVH arrays of either
// primitives or internal nodes, the node element type,
// and the split axis. Leaf and internal nodes are identical, except that
// indices refer to primitives for leaf nodes or other nodes for internal nodes.
struct shape_bvh_node {
    var bbox: bbox3f = invalidb3f
    var start: Int = 0
    var num: Int16 = 0
    var axis: Int8 = 0
    var internal_: Bool = false
}

// BVH tree stored as a node array with the tree structure is encoded using
// array indices. BVH nodes indices refer to either the node array,
// for internal nodes, or the primitive arrays, for leaf nodes.
// Application data is not stored explicitly.
struct shape_bvh {
    var nodes: [shape_bvh_node] = []
    var primitives: [Int] = []
}

// Results of intersect_xxx and overlap_xxx functions that include hit flag,
// instance id, shape element id, shape element uv and intersection distance.
// The values are all set for scene intersection. Shape intersection does not
// set the instance id and element intersections do not set shape element id
// and the instance id. Results values are set only if hit is true.
struct shape_intersection {
    var element: Int = -1
    var uv: vec2f = [0, 0]
    var distance: Float = 0
    var hit: Bool = false
}

// Splits a BVH node using the middle heuristic. Returns split position and
// axis.
func split_middle(_ primitives: inout [Int],
                  _ bboxes: [bbox3f], _ centers: [vec3f],
                  _ start: Int, _ end: Int) -> (Int, Int) {
    // initialize split axis and position
    var axis = 0
    var mid = (start + end) / 2

    // compute primitive bounds and size
    var cbbox = invalidb3f
    for i in start..<end {
        cbbox = merge(cbbox, centers[primitives[i]])
    }
    let csize = cbbox.max - cbbox.min
    if (csize == vec3f(0, 0, 0)) {
        return (mid, axis)
    }

    // split along largest
    if (csize.x >= csize.y && csize.x >= csize.z) {
        axis = 0
    }
    if (csize.y >= csize.x && csize.y >= csize.z) {
        axis = 1
    }
    if (csize.z >= csize.x && csize.z >= csize.y) {
        axis = 2
    }

    // split the space in the middle along the largest axis
    let cmiddle = (cbbox.max + cbbox.min) / 2
    let middle = cmiddle[axis]
    mid = primitives[start..<end].partition { a in
        centers[a][axis] < middle
    }

    // if we were not able to split, just break the primitives in half
    if (mid == start || mid == end) {
        axis = 0
        mid = (start + end) / 2
        // throw std::runtime_error("bad bvh split")
    }

    return (mid, axis)
}

// Maximum number of primitives per BVH node.
let bvh_max_prims = 4

// Build BVH nodes
func build_bvh(_ bvh: inout shape_bvh, _ bboxes: [bbox3f]) {
    // prepare to build nodes
    bvh.nodes = []
    bvh.nodes.reserveCapacity(bboxes.count * 2)

    // prepare primitives
    bvh.primitives = .init(repeating: 0, count: bboxes.count)
    for idx in 0..<bboxes.count {
        bvh.primitives[idx] = idx
    }

    // prepare centers
    var centers = [vec3f](repeating: vec3f(), count: bboxes.count)
    for idx in 0..<bboxes.count {
        centers[idx] = center(bboxes[idx])
    }

    // queue up first node
    var queue = [vec3i(0, 0, bboxes.count)]
    bvh.nodes.append(shape_bvh_node())

    // create nodes until the queue is empty
    while (!queue.isEmpty) {
        // grab node to work on
        let next = queue.removeFirst()
        let nodeid = next.x, start = next.y, end = next.z

        // grab node
        var node = bvh.nodes[nodeid]

        // compute bounds
        node.bbox = invalidb3f
        for i in start..<end {
            node.bbox = merge(node.bbox, bboxes[bvh.primitives[i]])
        }

        // split into two children
        if (end - start > bvh_max_prims) {
            // get split
            let (mid, axis) = split_middle(&bvh.primitives, bboxes, centers, start, end)

            // make an internal node
            node.internal_ = true
            node.axis = Int8(axis)
            node.num = 2
            node.start = bvh.nodes.count
            bvh.nodes.append(shape_bvh_node())
            bvh.nodes.append(shape_bvh_node())
            queue.append([node.start + 0, start, mid])
            queue.append([node.start + 1, mid, end])
        } else {
            // Make a leaf node
            node.internal_ = false
            node.num = Int16(end - start)
            node.start = start
        }
        bvh.nodes[nodeid] = node
    }
}

// Update bvh
func update_bvh(_ bvh: inout shape_bvh, _ bboxes: [bbox3f]) {
    for nodeid in stride(from: bvh.nodes.count - 1, to: -1, by: -1) {
        var node = bvh.nodes[nodeid]
        node.bbox = invalidb3f
        if (node.internal_) {
            for idx in 0..<2 {
                node.bbox = merge(node.bbox, bvh.nodes[node.start + idx].bbox)
            }
        } else {
            for idx in 0..<node.num {
                node.bbox = merge(node.bbox, bboxes[bvh.primitives[node.start + Int(idx)]])
            }
        }
        bvh.nodes[nodeid] = node
    }
}

// Make shape bvh
func make_points_bvh(_ points: [Int], _ positions: [vec3f], _ radius: [Float]) -> shape_bvh {
    // build primitives
    let bboxes = points.map { p in
        point_bounds(positions[p], radius[p])
    }

    // build nodes
    var bvh = shape_bvh()
    build_bvh(&bvh, bboxes)
    return bvh
}

func make_lines_bvh(_ lines: [vec2i], _ positions: [vec3f], _ radius: [Float]) -> shape_bvh {
    // build primitives
    let bboxes = lines.map { l in
        line_bounds(positions[l.x], positions[l.y], radius[l.x], radius[l.y])
    }

    // build nodes
    var bvh = shape_bvh()
    build_bvh(&bvh, bboxes)
    return bvh
}

func make_triangles_bvh(_ triangles: [vec3i], _ positions: [vec3f], _ radius: [Float]) -> shape_bvh {
    // build primitives
    let bboxes = triangles.map { t in
        triangle_bounds(positions[t.x], positions[t.y], positions[t.z])
    }

    // build nodes
    var bvh = shape_bvh()
    build_bvh(&bvh, bboxes)
    return bvh
}

func make_quads_bvh(_ quads: [vec4i], _ positions: [vec3f], _ radius: [Float]) -> shape_bvh {
    // build primitives
    let bboxes = quads.map { q in
        quad_bounds(positions[q.x], positions[q.y], positions[q.z], positions[q.w])
    }

    // build nodes
    var bvh = shape_bvh()
    build_bvh(&bvh, bboxes)
    return bvh
}

// Updates shape bvh for changes in positions and radia
func update_points_bvh(_ bvh: inout shape_bvh, _ points: [Int], _ positions: [vec3f], _ radius: [Float]) {
    // build primitives
    let bboxes = points.map { p in
        point_bounds(positions[p], radius[p])
    }

    // update nodes
    update_bvh(&bvh, bboxes)
}

func update_lines_bvh(_ bvh: inout shape_bvh, _ lines: [vec2i], _ positions: [vec3f], _ radius: [Float]) {
    // build primitives
    let bboxes = lines.map { l in
        line_bounds(positions[l.x], positions[l.y], radius[l.x], radius[l.y])
    }

    // update nodes
    update_bvh(&bvh, bboxes)
}

func update_triangles_bvh(_ bvh: inout shape_bvh, _ triangles: [vec3i], _ positions: [vec3f]) {
    // build primitives
    let bboxes = triangles.map { t in
        triangle_bounds(positions[t.x], positions[t.y], positions[t.z])
    }

    // update nodes
    update_bvh(&bvh, bboxes)
}

func update_quads_bvh(_ bvh: inout shape_bvh, _ quads: [vec4i], _ positions: [vec3f]) {
    // build primitives
    let bboxes = quads.map { q in
        quad_bounds(positions[q.x], positions[q.y], positions[q.z], positions[q.w])
    }

    // update nodes
    update_bvh(&bvh, bboxes)
}

// Intersect ray with a bvh.
func intersect_elements_bvh(_ bvh: shape_bvh, _ intersect_element: (Int, ray3f, inout vec2f, inout Float) -> Bool,
                            _ ray_: ray3f, _ element: inout Int, _ uv: inout vec2f,
                            _ distance: inout Float, _ find_any: Bool) -> Bool {
    // check empty
    if (bvh.nodes.isEmpty) {
        return false
    }

    // node stack
    var node_stack = [Int](repeating: 0, count: 128)
    var node_cur = 0
    node_stack[node_cur] = 0
    node_cur += 1

    // shared variables
    var hit = false

    // copy ray to modify it
    var ray = ray_

    // prepare ray for fast queries
    let ray_dinv = vec3f(1 / ray.d.x, 1 / ray.d.y, 1 / ray.d.z)
    let ray_dsign = vec3i((ray_dinv.x < 0) ? 1 : 0,
            (ray_dinv.y < 0) ? 1 : 0,
            (ray_dinv.z < 0) ? 1 : 0)

    // walking stack
    while ((node_cur) != 0) {
        // grab node
        node_cur -= 1
        let node = bvh.nodes[node_stack[node_cur]]

        // intersect bbox
        // if (!intersect_bbox(ray, ray_dinv, ray_dsign, node.bbox)) continue
        if (!intersect_bbox(ray, ray_dinv, node.bbox)) {
            continue
        }

        // intersect node, switching based on node type
        // for each type, iterate over the the primitive list
        if (node.internal_) {
            // for internal nodes, attempts to proceed along the
            // split axis from smallest to largest nodes
            if ((ray_dsign[Int(node.axis)]) != 0) {
                node_stack[node_cur] = node.start + 0
                node_cur += 1
                node_stack[node_cur] = node.start + 1
                node_cur += 1
            } else {
                node_stack[node_cur] = node.start + 1
                node_cur += 1
                node_stack[node_cur] = node.start + 0
                node_cur += 1
            }
        } else {
            for idx in 0..<node.num {
                let primitive = bvh.primitives[node.start + Int(idx)]
                if (intersect_element(primitive, ray, &uv, &distance)) {
                    hit = true
                    element = primitive
                    ray.tmax = distance
                }
            }
        }

        // check for early exit
        if (find_any && hit) {
            return hit
        }
    }

    return hit
}

// Find a shape element or scene instances that intersects a ray,
// returning either the closest or any overlap depending on `find_any`.
// Returns the point distance, the instance id, the shape element index and
// the element barycentric coordinates.
func intersect_points_bvh(_ bvh: shape_bvh, _ points: [Int], _ positions: [vec3f],
                          _ radius: [Float], _ ray: ray3f, _ find_any: Bool = false) -> shape_intersection {
    var intersection = shape_intersection()
    intersection.hit = intersect_elements_bvh(
            bvh, { (idx, ray, uv, distance) in
        let p = points[idx]
        return intersect_point(ray, positions[p], radius[p], &uv, &distance)
    }, ray, &intersection.element, &intersection.uv, &intersection.distance, find_any)
    return intersection
}

func intersect_lines_bvh(_ bvh: shape_bvh,
                         _ lines: [vec2i], _ positions: [vec3f],
                         _ radius: [Float], _ ray: ray3f, _ find_any: Bool = false) -> shape_intersection {
    var intersection = shape_intersection()
    intersection.hit = intersect_elements_bvh(
            bvh, { (idx, ray, uv, distance) in
        let l = lines[idx]
        return intersect_line(ray, positions[l.x], positions[l.y], radius[l.x],
                radius[l.y], &uv, &distance)
    }, ray, &intersection.element, &intersection.uv, &intersection.distance, find_any)
    return intersection
}

func intersect_triangles_bvh(_ bvh: shape_bvh,
                             _ triangles: [vec3i], _ positions: [vec3f],
                             _ ray: ray3f, _ find_any: Bool = false) -> shape_intersection {
    var intersection = shape_intersection()
    intersection.hit = intersect_elements_bvh(
            bvh, { (idx, ray, uv, distance) in
        let t = triangles[idx]
        return intersect_triangle(ray, positions[t.x], positions[t.y], positions[t.z], &uv, &distance)
    }, ray, &intersection.element, &intersection.uv, &intersection.distance, find_any)
    return intersection
}

func intersect_quads_bvh(_ bvh: shape_bvh,
                         _ quads: [vec4i], _ positions: [vec3f],
                         _ ray: ray3f, _ find_any: Bool = true) -> shape_intersection {
    var intersection = shape_intersection()
    intersection.hit = intersect_elements_bvh(
            bvh, { (idx, ray, uv, distance) in
        let t = quads[idx]
        return intersect_quad(ray, positions[t.x], positions[t.y],
                positions[t.z], positions[t.w], &uv, &distance)
    }, ray, &intersection.element, &intersection.uv, &intersection.distance, find_any)
    return intersection
}

// Intersect ray with a bvh.
func overlap_elements_bvh(_ bvh: shape_bvh, _ overlap_element: (Int, vec3f, Float, inout vec2f, inout Float) -> Bool,
                          _ pos: vec3f, _ max_distance: Float,
                          _ element: inout Int, _ uv: inout vec2f, _ distance: inout Float, _ find_any: Bool) -> Bool {
    // check if empty
    if (bvh.nodes.isEmpty) {
        return false
    }

    var max_distance = max_distance
    // node stack
    var node_stack = [Int](repeating: 0, count: 128)
    var node_cur = 0
    node_stack[node_cur] = 0
    node_cur += 1

    // hit
    var hit = false

    // walking stack
    while ((node_cur) != 0) {
        // grab node
        node_cur -= 1
        let node = bvh.nodes[node_stack[node_cur]]

        // intersect bbox
        if (!overlap_bbox(pos, max_distance, node.bbox)) {
            continue
        }

        // intersect node, switching based on node type
        // for each type, iterate over the the primitive list
        if (node.internal_) {
            // internal node
            node_stack[node_cur] = node.start + 0
            node_cur += 1
            node_stack[node_cur] = node.start + 1
            node_cur += 1
        } else {
            for idx in 0..<node.num {
                let primitive = bvh.primitives[node.start + Int(idx)]
                if (overlap_element(primitive, pos, max_distance, &uv, &distance)) {
                    hit = true
                    element = primitive
                    max_distance = distance
                }
            }
        }

        // check for early exit
        if (find_any && hit) {
            return hit
        }
    }

    return hit
}

// Find a shape element that overlaps a point within a given distance
// max distance, returning either the closest or any overlap depending on
// `find_any`. Returns the point distance, the instance id, the shape element
// index and the element barycentric coordinates.
func overlap_points_bvh(_ bvh: shape_bvh, _ points: [Int], _ positions: [vec3f],
                        _  radius: [Float], _ pos: vec3f, _ max_distance: Float,
                        _ find_any: Bool = false) -> shape_intersection {
    var intersection = shape_intersection()
    intersection.hit = overlap_elements_bvh(
            bvh, { (idx, pos, max_distance, uv, distance) in
        let p = points[idx]
        return overlap_point(pos, max_distance, positions[p], radius[p], &uv, &distance)
    }, pos, max_distance, &intersection.element, &intersection.uv, &intersection.distance, find_any)
    return intersection
}

func overlap_lines_bvh(_ bvh: shape_bvh,
                       _ lines: [vec2i], _ positions: [vec3f],
                       _ radius: [Float], _ pos: vec3f, _ max_distance: Float,
                       _ find_any: Bool = false) -> shape_intersection {
    var intersection = shape_intersection()
    intersection.hit = overlap_elements_bvh(
            bvh, { (idx, pos, max_distance, uv, distance) in
        let l = lines[idx]
        return overlap_line(pos, max_distance, positions[l.x], positions[l.y],
                radius[l.x], radius[l.y], &uv, &distance)
    }, pos, max_distance, &intersection.element, &intersection.uv,
            &intersection.distance, find_any)
    return intersection
}

func overlap_triangles_bvh(_ bvh: shape_bvh,
                           _ triangles: [vec3i], _ positions: [vec3f],
                           _ radius: [Float], _ pos: vec3f, _ max_distance: Float,
                           _ find_any: Bool = false) -> shape_intersection {
    var intersection = shape_intersection()
    intersection.hit = overlap_elements_bvh(
            bvh, { (idx, pos, max_distance, uv, distance) in
        let t = triangles[idx]
        return overlap_triangle(pos, max_distance, positions[t.x],
                positions[t.y], positions[t.z], radius[t.x], radius[t.y],
                radius[t.z], &uv, &distance)
    }, pos, max_distance, &intersection.element, &intersection.uv,
            &intersection.distance, find_any)
    return intersection
}

func overlap_quads_bvh(_ bvh: shape_bvh,
                       _ quads: [vec4i], _ positions: [vec3f],
                       _ radius: [Float], _ pos: vec3f, _ max_distance: Float,
                       _ find_any: Bool = false) -> shape_intersection {
    var intersection = shape_intersection()
    intersection.hit = overlap_elements_bvh(
            bvh, { (idx, pos, max_distance, uv, distance) in
        let q = quads[idx]
        return overlap_quad(pos, max_distance, positions[q.x], positions[q.y],
                positions[q.z], positions[q.w], radius[q.x], radius[q.y],
                radius[q.z], radius[q.w], &uv, &distance)
    }, pos, max_distance, &intersection.element, &intersection.uv,
            &intersection.distance, find_any)
    return intersection
}

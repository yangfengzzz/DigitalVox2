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
    var bbox: bbox3f = invalidb3f;
    var start: Int32 = 0;
    var num: Int16 = 0;
    var axis: Int8 = 0;
    var internal_: Bool = false;
};

// BVH tree stored as a node array with the tree structure is encoded using
// array indices. BVH nodes indices refer to either the node array,
// for internal nodes, or the primitive arrays, for leaf nodes.
// Application data is not stored explicitly.
struct shape_bvh {
    var nodes: [shape_bvh_node] = []
    var primitives: [Int] = []
};

// Results of intersect_xxx and overlap_xxx functions that include hit flag,
// instance id, shape element id, shape element uv and intersection distance.
// The values are all set for scene intersection. Shape intersection does not
// set the instance id and element intersections do not set shape element id
// and the instance id. Results values are set only if hit is true.
struct shape_intersection {
    var element: Int = -1;
    var uv: vec2f = [0, 0]
    var distance: Float = 0;
    var hit: Bool = false;
};

// Make shape bvh
func make_points_bvh(points: [Int], positions: [vec3f], radius: [Float]) -> shape_bvh {
    fatalError()
}

func make_lines_bvh(lines: [vec2i], positions: [vec3f], radius: [Float]) -> shape_bvh {
    fatalError()
}

func make_triangles_bvh(triangles: [vec3i], positions: [vec3f], radius: [Float]) -> shape_bvh {
    fatalError()
}

func make_quads_bvh(quads: [vec4i], positions: [vec3f], radius: [Float]) -> shape_bvh {
    fatalError()
}

// Updates shape bvh for changes in positions and radia
func update_points_bvh(bvh: inout shape_bvh, points: [Int], positions: [vec3f], radius: [Float]) {
    fatalError()
}

func update_lines_bvh(bvh: inout shape_bvh, lines: [vec2i], positions: [vec3f], radius: [Float]) {
    fatalError()
}

func update_triangles_bvh(bvh: inout shape_bvh, triangles: [vec3i], positions: [vec3f]) {
    fatalError()
}

func update_quads_bvh(bvh: inout shape_bvh, quads: [vec4i], positions: [vec3f]) {
    fatalError()
}

// Find a shape element or scene instances that intersects a ray,
// returning either the closest or any overlap depending on `find_any`.
// Returns the point distance, the instance id, the shape element index and
// the element barycentric coordinates.
func intersect_points_bvh(bvh: shape_bvh, points: [Int], positions: [vec3f],
                          radius: [Float], ray: ray3f, find_any: Bool = false) -> shape_intersection {
    fatalError()
}

func intersect_lines_bvh(bvh: shape_bvh,
                         lines: [vec2i], positions: [vec3f],
                         radius: [Float], ray: ray3f, find_any: Bool = false) -> shape_intersection {
    fatalError()
}

func intersect_triangles_bvh(bvh: shape_bvh,
                             triangles: [vec3i], positions: [vec3f],
                             ray: ray3f, find_any: Bool = false) -> shape_intersection {
    fatalError()
}

func intersect_quads_bvh(bvh: shape_bvh,
                         quads: [vec4i], positions: [vec3f],
                         ray: ray3f, find_any: Bool = true) -> shape_intersection {
    fatalError()
}

// Find a shape element that overlaps a point within a given distance
// max distance, returning either the closest or any overlap depending on
// `find_any`. Returns the point distance, the instance id, the shape element
// index and the element barycentric coordinates.
func overlap_points_bvh(bvh: shape_bvh, points: [Int], positions: [vec3f],
                        radius: [Float], pos: vec3f, max_distance: Float,
                        find_any: Bool = false) -> shape_intersection {
    fatalError()
}

func overlap_lines_bvh(bvh: shape_bvh,
                       lines: [vec2i], positions: [vec3f],
                       radius: [Float], pos: vec3f, max_distance: Float,
                       find_any: Bool = false) -> shape_intersection {
    fatalError()
}

func overlap_triangles_bvh(bvh: shape_bvh,
                           triangles: [vec3i], positions: [vec3f],
                           radius: [Float], pos: vec3f, max_distance: Float,
                           find_any: Bool = false) -> shape_intersection {
    fatalError()
}

func overlap_quads_bvh(bvh: shape_bvh,
                       quads: [vec4i], positions: [vec3f],
                       radius: [Float], pos: vec3f, max_distance: Float,
                       find_any: Bool = false) -> shape_intersection {
    fatalError()
}

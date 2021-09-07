//
//  bvh.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

// BVH tree node containing its bounds, indices to the BVH arrays of either
// primitives or internal nodes, the node element type,
// and the split axis. Leaf and internal nodes are identical, except that
// indices refer to primitives for leaf nodes or other nodes for internal nodes.
struct bvh_node {
    var bbox: bbox3f = invalidb3f
    var start: Int32 = 0
    var num: Int16 = 0
    var axis: Int8 = 0
    var internal_: Bool = false
}

// BVH tree stored as a node array with the tree structure is encoded using
// array indices. BVH nodes indices refer to either the node array,
// for internal nodes, or the primitive arrays, for leaf nodes.
// For instance BVHs, we also store the BVH of the contained shapes.
// Application data is not stored explicitly.
// Additionally, we support the use of Intel Embree.
struct bvh_data {
    var nodes: [bvh_node] = []
    var primitives: [Int] = []
    var shapes: [bvh_data] = []             // shapes
}

// Build the bvh acceleration structure.
func make_bvh(_ shape: shape_data, _ highquality: Bool = false) -> bvh_data {
    fatalError()
}

func make_bvh(_ scene: scene_data, _ highquality: Bool = false, _ noparallel: Bool = false) -> bvh_data {
    fatalError()
}

// Refit bvh data
func update_bvh(_ bvh: inout bvh_data, _ shape: shape_data) {
    fatalError()
}

func update_bvh(_ bvh: inout bvh_data, _ scene: scene_data,
                _ updated_instances: [Int], _ updated_shapes: [Int]) {
    fatalError()
}

// Results of intersect_xxx and overlap_xxx functions that include hit flag,
// instance id, shape element id, shape element uv and intersection distance.
// The values are all set for scene intersection. Shape intersection does not
// set the instance id and element intersections do not set shape element id
// and the instance id. Results values are set only if hit is true.
struct bvh_intersection {
    var instance: Int = -1
    var element: Int = -1
    var uv: vec2f = [0, 0]
    var distance: Float = 0
    var hit: Bool = false
}

// Intersect ray with a bvh returning either the first or any intersection
// depending on `find_any`. Returns the ray distance , the instance id,
// the shape element index and the element barycentric coordinates.
func intersect_bvh(_ bvh: bvh_data, _ shape: shape_data,
                   _ ray: ray3f, _ find_any: Bool = false, _ non_rigid_frames: Bool = true) -> bvh_intersection {
    fatalError()
}

func intersect_bvh(_ bvh: bvh_data, _ scene: scene_data,
                   _ ray: ray3f, _ find_any: Bool = false, _ non_rigid_frames: Bool = true) -> bvh_intersection {
    fatalError()
}

func intersect_bvh(_ bvh: bvh_data, _ scene: scene_data,
                   _ instance: Int, _ ray: ray3f, _ find_any: Bool = false,
                   _ non_rigid_frames: Bool = true) -> bvh_intersection {
    fatalError()
}

// Find a shape element that overlaps a point within a given distance
// max distance, returning either the closest or any overlap depending on
// `find_any`. Returns the point distance, the instance id, the shape element
// index and the element barycentric coordinates.
func overlap_bvh(_ bvh: bvh_data, _ shape: shape_data,
                 _ pos: vec3f, _ max_distance: Float, _ find_any: Bool = false) -> bvh_intersection {
    fatalError()
}

func overlap_bvh(_ bvh: bvh_data, _ scene: scene_data,
                 _ pos: vec3f, _ max_distance: Float, _ find_any: Bool = false,
                 _ non_rigid_frames: Bool = true) -> bvh_intersection {
    fatalError()
}

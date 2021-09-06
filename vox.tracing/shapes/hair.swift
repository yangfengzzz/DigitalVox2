//
//  hair.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/6.
//

import Foundation

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

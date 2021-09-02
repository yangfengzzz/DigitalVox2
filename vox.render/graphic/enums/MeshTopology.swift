//
//  MeshTopology.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

enum MeshTopology: Int {
    /// Draws a single dot
    case Points = 0
    /// Draws a line between a pair of vertices
    case Lines = 1
    /// Draws a straight line to the next vertex, and connects the last vertex back to the first
    case LineLoop = 2
    /// Draws a straight line to the next vertex.
    case LineStrip = 3
    /// Draws a triangle for a group of three vertices
    case Triangles = 4
    /// Draws a triangle strip
    case TriangleStrip = 5
    /// Draws a triangle fan
    case TriangleFan = 6
}

//
//  BlendShapeFrame.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// BlendShapeFrame.
class BlendShapeFrame {
    /// Weight of BlendShapeFrame.
    var weight: Float
    /// Delta positions for the frame being added.
    var deltaPositions: [Vector3]
    /// Delta normals for the frame being added.
    var deltaNormals: [Vector3]
    /// Delta tangents for the frame being added.
    var deltaTangents: [Vector3]


    /// Create a BlendShapeFrame.
    /// - Parameters:
    ///   - weight:  Weight of BlendShapeFrame
    ///   - deltaPositions: Delta positions for the frame being added
    ///   - deltaNormals: Delta normals for the frame being added
    ///   - deltaTangents: Delta tangents for the frame being added
    init(_ weight: Float,
         _ deltaPositions: [Vector3],
         _ deltaNormals: [Vector3] = [],
         _ deltaTangents: [Vector3] = []) {
        if (!deltaNormals.isEmpty && deltaNormals.count != deltaPositions.count) {
            fatalError("deltaNormals length must same with deltaPositions length.")
        }

        if (!deltaTangents.isEmpty && deltaTangents.count != deltaPositions.count) {
            fatalError("deltaTangents length must same with deltaPositions length.")
        }

        self.weight = weight
        self.deltaPositions = deltaPositions
        self.deltaNormals = deltaNormals
        self.deltaTangents = deltaTangents
    }
}

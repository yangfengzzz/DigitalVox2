//
//  BlendShape.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// BlendShape.
class BlendShape {
    /// Name of BlendShape. 
    var name: String

    internal var _useBlendShapeNormal: Bool = false
    internal var _useBlendShapeTangent: Bool = false

    private var _frames: [BlendShapeFrame] = []
    private var _updateFlagManager: UpdateFlagManager = UpdateFlagManager()

    /// Frames of BlendShape.
    var frames: [BlendShapeFrame] {
        get {
            _frames
        }
    }

    /// Create a BlendShape.
    /// - Parameter name: BlendShape name.
    init(name: String) {
        self.name = name
    }

    /// Add a BlendShapeFrame by weight, deltaPositions, deltaNormals and deltaTangents.
    /// - Parameters:
    ///   - weight: Weight of BlendShapeFrame
    ///   - deltaPositions: Delta positions for the frame being added
    ///   - deltaNormals: Delta normals for the frame being added
    ///   - deltaTangents: Delta tangents for the frame being added
    /// - Returns: frame
    func addFrame(weight: Float,
                  deltaPositions: [Vector3],
                  deltaNormals: [Vector3] = [],
                  deltaTangents: [Vector3] = []) -> BlendShapeFrame {
        let frame = BlendShapeFrame(weight, deltaPositions, deltaNormals, deltaTangents)
        _addFrame(frame)
        return frame
    }

    /// Add a BlendShapeFrame.
    /// - Parameter frame: The BlendShapeFrame.
    func addFrame(frame: BlendShapeFrame) {
        _addFrame(frame)
        _updateFlagManager.distribute()
    }


    /// Clear all frames.
    func clearFrames() {
        _frames = []
        _updateFlagManager.distribute()
        _useBlendShapeNormal = false
        _useBlendShapeTangent = false
    }

    internal func _registerChangeFlag() -> UpdateFlag {
        _updateFlagManager.register()
    }

    private func _addFrame(_ frame: BlendShapeFrame) {
        let frames = _frames
        let frameCount = frames.count
        if (frameCount > 0 && frame.deltaPositions.count != frames[frameCount - 1].deltaPositions.count) {
            fatalError("Frame's deltaPositions length must same with before frame deltaPositions length.")
        }

        _useBlendShapeNormal = _useBlendShapeNormal || !frame.deltaNormals.isEmpty
        _useBlendShapeTangent = _useBlendShapeTangent || !frame.deltaTangents.isEmpty
        _frames.append(frame)
    }
}

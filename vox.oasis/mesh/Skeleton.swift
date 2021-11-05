//
//  Skeleton.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/3.
//

import MetalKit

struct Skeleton {
    let parentIndices: [Int]
    let jointPaths: [String]
    let bindTransforms: [float4x4]
    let restTransforms: [float4x4]
    let jointMatrixPaletteBuffer: MTLBuffer?

    static func getParentIndices(jointPaths: [String]) -> [Int] {
        var parentIndices = [Int](repeating: SoaSkeleton.Constants.kNoParent.rawValue, count: jointPaths.count)
        for (jointIndex, jointPath) in jointPaths.enumerated() {
            let url = URL(fileURLWithPath: jointPath)
            let parentPath = url.deletingLastPathComponent().relativePath
            let parentIndex = jointPaths.firstIndex {
                $0 == parentPath
            }
            
            if parentIndex != nil {
                parentIndices[jointIndex] = parentIndex!
            }
        }
        return parentIndices
    }

    init?(_ engine: Engine, animationBindComponent: MDLAnimationBindComponent?) {
        guard let skeleton = animationBindComponent?.skeleton else {
            return nil
        }
        jointPaths = skeleton.jointPaths
        bindTransforms = skeleton.jointBindTransforms.float4x4Array
        restTransforms = skeleton.jointRestTransforms.float4x4Array
        parentIndices = Skeleton.getParentIndices(jointPaths: jointPaths)

        let bufferSize = jointPaths.count * MemoryLayout<float4x4>.stride
        jointMatrixPaletteBuffer = engine._hardwareRenderer.device.makeBuffer(length: bufferSize, options: [])
    }

    func updatePose(animationClip: AnimationClip,
                    at time: Float) {
        guard let paletteBuffer = jointMatrixPaletteBuffer else {
            return
        }
        var palettePointer =
                paletteBuffer.contents().bindMemory(to: float4x4.self,
                        capacity: jointPaths.count)
        palettePointer.initialize(repeating: .identity(),
                count: jointPaths.count)
        var poses = [float4x4](repeatElement(.identity(),
                count: jointPaths.count))
        for (jointIndex, jointPath) in jointPaths.enumerated() {
            let pose =
                    animationClip.getPose(at: time * animationClip.speed,
                            jointPath: jointPath)
                            ?? restTransforms[jointIndex]

            let parentPose: float4x4
            
            if parentIndices[jointIndex] != SoaSkeleton.Constants.kNoParent.rawValue {
                parentPose = poses[parentIndices[jointIndex]]
            } else {
                parentPose = .identity()
            }
            poses[jointIndex] = parentPose * pose
            palettePointer.pointee =
                    poses[jointIndex] * bindTransforms[jointIndex].inverse
            palettePointer = palettePointer.advanced(by: 1)
        }
    }
}

//
//  Skeleton.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/3.
//

import MetalKit

struct Skeleton {
    let parentIndices: [Int?]
    let jointPaths: [String]
    let bindTransforms: [float4x4]
    let restTransforms: [float4x4]
    let jointMatrixPaletteBuffer: MTLBuffer?

    static func getParentIndices(jointPaths: [String]) -> [Int?] {
        var parentIndices = [Int?](repeating: nil, count: jointPaths.count)
        for (jointIndex, jointPath) in jointPaths.enumerated() {
            let url = URL(fileURLWithPath: jointPath)
            let parentPath = url.deletingLastPathComponent().relativePath
            parentIndices[jointIndex] = jointPaths.firstIndex {
                $0 == parentPath
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

    func updatePose() {
        guard
                let paletteBuffer = jointMatrixPaletteBuffer else {
            return
        }
        var palettePointer =
                paletteBuffer.contents().bindMemory(to: float4x4.self,
                        capacity: jointPaths.count)
        palettePointer.initialize(repeating: simd_float4x4(1),
                count: jointPaths.count)
        var poses = [float4x4](repeatElement(simd_float4x4(1),
                count: jointPaths.count))
        for (jointIndex, jointPath) in jointPaths.enumerated() {
            let pose = restTransforms[jointIndex]

            let parentPose: float4x4
            if let parentIndex = parentIndices[jointIndex] {
                parentPose = poses[parentIndex]
            } else {
                parentPose = simd_float4x4(1)
            }
            poses[jointIndex] = parentPose * pose
            palettePointer.pointee =
                    poses[jointIndex] * bindTransforms[jointIndex].inverse
            palettePointer = palettePointer.advanced(by: 1)
        }
    }
}

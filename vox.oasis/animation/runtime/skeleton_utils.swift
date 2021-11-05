//
//  skeleton_utils.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Get bind-pose of a skeleton joint.
func getJointLocalBindPose(_ _skeleton: SoaSkeleton, _ _joint: Int) -> VecTransform {
    guard _joint >= 0 && _joint < _skeleton.num_joints() else {
        fatalError("Joint index out of range.")
    }

    let soa_transform = _skeleton.joint_bind_poses()[_joint / 4]

    // Transpose SoA data to AoS.
    var translations = [SimdFloat4](repeating: SimdFloat4(), count: 4)
    transpose3x4(soa_transform.translation, &translations)
    var rotations = [SimdFloat4](repeating: SimdFloat4(), count: 4)
    transpose4x4(soa_transform.rotation, &rotations)
    var scales = [SimdFloat4](repeating: SimdFloat4(), count: 4)
    transpose3x4(soa_transform.scale, &scales)

    // Stores to the Transform object.
    var bind_pose = VecTransform.identity()
    let offset = _joint % 4
    var result: [Float] = [0, 0, 0, 0]
    store3PtrU(translations[offset], &result)
    bind_pose.translation = VecFloat3(result[0], result[1], result[2])
    storePtrU(rotations[offset], &result)
    bind_pose.rotation = VecQuaternion(result[0], result[1], result[2], result[3])
    store3PtrU(scales[offset], &result)
    bind_pose.scale = VecFloat3(result[0], result[1], result[2])

    return bind_pose
}

// Test if a joint is a leaf. _joint number must be in range [0, num joints].
// "_joint" is a leaf if it's the last joint, or next joint's parent isn't
// "_joint".
func isLeaf(_ _skeleton: SoaSkeleton, _ _joint: Int) -> Bool {
    let num_joints = _skeleton.num_joints()
    guard _joint >= 0 && _joint < num_joints else {
        fatalError("_joint index out of range")
    }
    let parents = _skeleton.joint_parents()
    let next = _joint + 1
    return next == num_joints || parents[next] != _joint
}

// Applies a specified functor to each joint in a depth-first order.
// _Fct is of type void(int _current, int _parent) where the first argument is
// the child of the second argument. _parent is kNoParent if the
// _current joint is a root. _from indicates the joint from which the joint
// hierarchy traversal begins. Use Skeleton::kNoParent to traverse the
// whole hierarchy, in case there are multiple roots.
func iterateJointsDF(_ _skeleton: SoaSkeleton, _ _fct: (Int, Int) -> Void,
                     _ _from: Int = SoaSkeleton.Constants.kNoParent.rawValue) {
    let parents = _skeleton.joint_parents()
    let num_joints = _skeleton.num_joints()

    var i = _from < 0 ? 0 : _from
    var process = i < num_joints
    while process {
        _fct(i, parents[i])
        i += 1
        process = i < num_joints && parents[i] >= _from
    }
}

// Applies a specified functor to each joint in a reverse (from leaves to root)
// depth-first order. _Fct is of type void(int _current, int _parent) where the
// first argument is the child of the second argument. _parent is kNoParent if
// the _current joint is a root.
func iterateJointsDFReverse(_ _skeleton: SoaSkeleton, _ _fct: (Int, Int) -> Void) {
    let parents = _skeleton.joint_parents()
    for i in stride(from: _skeleton.num_joints() - 1, through: 0, by: -1) {
        _fct(i, parents[i])
    }
}

//MARK: - Render Utility
func fillPostureUniforms(_ _skeleton: SoaSkeleton,
                         _ _matrices: [matrix_float4x4],
                         _ _uniforms: inout [matrix_float4x4]) {
    // Prepares computation constants.
    let num_joints = _skeleton.num_joints()
    let parents = _skeleton.joint_parents()

    var instances = 0
    for i in 0..<num_joints {
        // Root isn't rendered.
        let parent_id = parents[i]
        if (parent_id == SoaSkeleton.Constants.kNoParent.rawValue) {
            continue
        }

        // Selects joint matrices.
        let parent = _matrices[parent_id]
        let current = _matrices[i]

        // Copy parent joint's raw matrix, to render a bone between the parent and current matrix.
        _uniforms.append(parent)

        // Set bone direction (bone_dir). The shader expects to find it at index
        // [3,7,11] of the matrix.
        // Index 15 is used to store whether a bone should be rendered,
        // otherwise it's a leaf.
        var bone_dir: [Float] = [0, 0, 0, 0]
        storePtrU(current.columns.3 - parent.columns.3, &bone_dir)
        _uniforms[instances].columns.0.w = bone_dir[0]
        _uniforms[instances].columns.1.w = bone_dir[1]
        _uniforms[instances].columns.2.w = bone_dir[2]
        _uniforms[instances].columns.3.w = 1.0 // Enables bone rendering.

        // Next instance.
        instances += 1

        // Only the joint is rendered for leaves, the bone model isn't.
        if (isLeaf(_skeleton, i)) {
            // Copy current joint's raw matrix.
            _uniforms.append(current)

            // Re-use bone_dir to fix the size of the leaf (same as previous bone).
            // The shader expects to find it at index [3,7,11] of the matrix.
            _uniforms[instances].columns.0.w = bone_dir[0]
            _uniforms[instances].columns.1.w = bone_dir[1]
            _uniforms[instances].columns.2.w = bone_dir[2]
            _uniforms[instances].columns.3.w = 0.0  // Disables bone rendering.
            instances += 1
        }
    }
}

func createBoneMesh(_ engine: Engine) -> ModelMesh {
    let kInter: Float = 0.2
    let mesh = ModelMesh(engine)
    var positions: [Vector3] = [Vector3](repeating: Vector3(), count: 6)
    positions[0] = Vector3(1.0, 0.0, 0.0)
    positions[1] = Vector3(kInter, 0.1, 0.1)
    positions[2] = Vector3(kInter, 0.1, -0.1)
    positions[3] = Vector3(kInter, -0.1, -0.1)
    positions[4] = Vector3(kInter, -0.1, 0.1)
    positions[5] = Vector3(0.0, 0.0, 0.0)

    let pos: [VecFloat3] = [
        VecFloat3(1.0, 0.0, 0.0), VecFloat3(kInter, 0.1, 0.1),
        VecFloat3(kInter, 0.1, -0.1), VecFloat3(kInter, -0.1, -0.1),
        VecFloat3(kInter, -0.1, 0.1), VecFloat3(0.0, 0.0, 0.0)
    ]

    let n: [VecFloat3] = [
        normalize(cross(pos[2] - pos[1], pos[2] - pos[0])),
        normalize(cross(pos[1] - pos[2], pos[1] - pos[5])),
        normalize(cross(pos[3] - pos[2], pos[3] - pos[0])),
        normalize(cross(pos[2] - pos[3], pos[2] - pos[5])),
        normalize(cross(pos[4] - pos[3], pos[4] - pos[0])),
        normalize(cross(pos[3] - pos[4], pos[3] - pos[5])),
        normalize(cross(pos[1] - pos[4], pos[1] - pos[0])),
        normalize(cross(pos[4] - pos[1], pos[4] - pos[5]))
    ]
    let vertex_n = [
        (n[0] + n[2] + n[4] + n[6]) * 0.25,
        (n[0] + n[1] + n[6] + n[7]) * 0.25,
        (n[0] + n[1] + n[2] + n[3]) * 0.25,
        (n[2] + n[3] + n[4] + n[5]) * 0.25,
        (n[4] + n[5] + n[6] + n[7]) * 0.25,
        (n[1] + n[3] + n[5] + n[7]) * 0.25,
    ]

    let normals: [Vector3] = [
        Vector3(vertex_n[0].x, vertex_n[0].y, vertex_n[0].z),
        Vector3(vertex_n[1].x, vertex_n[1].y, vertex_n[1].z),
        Vector3(vertex_n[2].x, vertex_n[2].y, vertex_n[2].z),
        Vector3(vertex_n[3].x, vertex_n[3].y, vertex_n[3].z),
        Vector3(vertex_n[4].x, vertex_n[4].y, vertex_n[4].z),
        Vector3(vertex_n[5].x, vertex_n[5].y, vertex_n[5].z),
    ]

    let white = Color(1, 1, 1, 1)
    let colors: [Color] = [
        white,
        white,
        white,
        white,
        white,
        white
    ]

    var indices = [UInt32](repeating: 0, count: 24)
    indices[0] = 0
    indices[1] = 2
    indices[2] = 1
    indices[3] = 5
    indices[4] = 1
    indices[5] = 2

    indices[6] = 0
    indices[7] = 3
    indices[8] = 2
    indices[9] = 5
    indices[10] = 2
    indices[11] = 3

    indices[12] = 0
    indices[13] = 4
    indices[14] = 3
    indices[15] = 5
    indices[16] = 3
    indices[17] = 4

    indices[18] = 0
    indices[19] = 1
    indices[20] = 4
    indices[21] = 5
    indices[22] = 4
    indices[23] = 1

    mesh.setPositions(positions: positions)
    mesh.setNormals(normals: normals)
    mesh.setColors(colors: colors)
    mesh.uploadData(true)
    let indexBuffer = engine._hardwareRenderer.device.makeBuffer(bytes: indices,
            length: indices.count * MemoryLayout<UInt32>.stride,
            options: .storageModeShared)
    _ = mesh.addSubMesh(MeshBuffer(indexBuffer!, indices.count * MemoryLayout<UInt32>.stride, .index),
            .uint32, indices.count, .triangle)

    return mesh
}

func createJointMesh(_ engine: Engine) -> ModelMesh {
    let kNumSlices = 20
    let kNumPointsPerCircle = kNumSlices + 1
    let kNumPointsYZ = kNumPointsPerCircle
    let kNumPointsXY = kNumPointsPerCircle + kNumPointsPerCircle / 4
    let kNumPointsXZ = kNumPointsPerCircle
    let kRadius: Float = 0.2  // Radius multiplier.
    let red = Color(1, 0, 0, 1)
    let green = Color(0, 1, 0, 1)
    let blue = Color(0, 0, 1, 1)

    var positions: [Vector3] = []
    var normals: [Vector3] = []
    var colors: [Color] = []
    var indices: [UInt32] = []

    var index: UInt32 = 0
    for j in 0..<kNumPointsYZ { // YZ plan.
        indices.append(index)
        let angle = Float(j) * k2Pi / Float(kNumSlices)
        let s = sinf(angle), c = cosf(angle)
        positions.append(Vector3(0.0, c * kRadius, s * kRadius))
        normals.append(Vector3(0.0, c, s))
        colors.append(red)
        index += 1
        indices.append(index)
    }
    indices[indices.count - 1] = 0

    for j in 0..<kNumPointsXY { // XY plan.
        indices.append(index)
        let angle = Float(j) * k2Pi / Float(kNumSlices)
        let s = sinf(angle), c = cosf(angle)
        positions.append(Vector3(s * kRadius, c * kRadius, 0.0))
        normals.append(Vector3(s, c, 0.0))
        colors.append(blue)
        index += 1
        indices.append(index)
    }
    indices[indices.count - 1] = UInt32(kNumPointsYZ)

    for j in 0..<kNumPointsXZ { // XZ plan.
        indices.append(index)
        let angle = Float(j) * k2Pi / Float(kNumSlices)
        let s = sinf(angle), c = cosf(angle)
        positions.append(Vector3(c * kRadius, 0.0, -s * kRadius))
        normals.append(Vector3(c, 0.0, -s))
        colors.append(green)
        index += 1
        indices.append(index)
    }
    indices[indices.count - 1] = UInt32(kNumPointsYZ + kNumPointsXY)

    let mesh = ModelMesh(engine)
    mesh.setPositions(positions: positions)
    mesh.setNormals(normals: normals)
    mesh.setColors(colors: colors)
    mesh.uploadData(true)
    let indexBuffer = engine._hardwareRenderer.device.makeBuffer(bytes: indices,
            length: indices.count * MemoryLayout<UInt32>.stride,
            options: .storageModeShared)
    _ = mesh.addSubMesh(MeshBuffer(indexBuffer!, indices.count * MemoryLayout<UInt32>.stride, .index),
            .uint32, indices.count, .line)
    return mesh
}


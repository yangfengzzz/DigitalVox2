//
//  SkeletonView.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/5.
//

import SwiftUI

// A millipede slice is 2 legs and a spine.
// Each slice is made of 7 joints, organized as follows.
//          * root
//             |
//           spine                                   spine
//         |       |                                   |
//     left_up    right_up        left_down - left_u - . - right_u - right_down
//       |           |                  |                                    |
//   left_down     right_down     left_foot         * root            right_foot
//     |               |
// left_foot        right_foot

// The following constants are used to define the millipede skeleton and
// animation.
// Skeleton constants.
let kTransUp = VecFloat3(0.0, 0.0, 0.0)
let kTransDown = VecFloat3(0.0, 0.0, 1.0)
let kTransFoot = VecFloat3(1.0, 0.0, 0.0)

let kRotLeftUp = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), -kPi_2)
let kRotLeftDown = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), kPi_2) * VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), -kPi_2)
let kRotRightUp = VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), kPi_2)
let kRotRightDown = VecQuaternion.fromAxisAngle(VecFloat3.x_axis(), kPi_2) * VecQuaternion.fromAxisAngle(VecFloat3.y_axis(), -kPi_2)
// Animation constants.
let kDuration: Float = 6.0
let kSpinLength: Float = 0.5
let kWalkCycleLength: Float = 2.0
let kWalkCycleCount: Int = 4
let kSpinLoop: Float = 2 * Float(kWalkCycleCount) * kWalkCycleLength / kSpinLength

let slice_count_ = 2

func createSkeleton(_ _skeleton: inout RawSkeleton) {
    _skeleton.roots = [RawSkeleton.Joint()]
    var root = _skeleton.roots[0]
    root.name = "root"
    root.transform.translation = VecFloat3(0.0, 1.0, -Float(slice_count_) * kSpinLength)
    root.transform.rotation = VecQuaternion.identity()
    root.transform.scale = VecFloat3.one()

    for i in 0..<slice_count_ {
        root.children = [RawSkeleton.Joint(), RawSkeleton.Joint(), RawSkeleton.Joint()]

        // Left leg.
        let lu = root.children[0]
        lu.name = "lu\(i)"
        lu.transform.translation = kTransUp
        lu.transform.rotation = kRotLeftUp
        lu.transform.scale = VecFloat3.one()

        lu.children = [RawSkeleton.Joint()]
        let ld = lu.children[0]
        ld.name = "ld\(i)"
        ld.transform.translation = kTransDown
        ld.transform.rotation = kRotLeftDown
        ld.transform.scale = VecFloat3.one()

        ld.children = [RawSkeleton.Joint()]
        let lf = ld.children[0]
        lf.name = "lf\(i)"
        lf.transform.translation = VecFloat3.x_axis()
        lf.transform.rotation = VecQuaternion.identity()
        lf.transform.scale = VecFloat3.one()

        // Right leg.
        let ru = root.children[1]
        ru.name = "ru\(i)"
        ru.transform.translation = kTransUp
        ru.transform.rotation = kRotRightUp
        ru.transform.scale = VecFloat3.one()

        ru.children = [RawSkeleton.Joint()]
        let rd = ru.children[0]
        rd.name = "rd\(i)"
        rd.transform.translation = kTransDown
        rd.transform.rotation = kRotRightDown
        rd.transform.scale = VecFloat3.one()

        rd.children = [RawSkeleton.Joint()]
        let rf = rd.children[0]
        rf.name = "rf\(i)"
        rf.transform.translation = VecFloat3.x_axis()
        rf.transform.rotation = VecQuaternion.identity()
        rf.transform.scale = VecFloat3.one()

        // Spine.
        let sp = root.children[2]
        sp.name = "sp\(i)"
        sp.transform.translation = VecFloat3(0.0, 0.0, kSpinLength)
        sp.transform.rotation = VecQuaternion.identity()
        sp.transform.scale = VecFloat3.one()

        root = sp
    }
}

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
    }
}

func createBone(_ engine: Engine) -> ModelMesh {
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
    mesh.uploadData(true)
    let indexBuffer = engine._hardwareRenderer.device.makeBuffer(bytes: indices,
            length: indices.count * MemoryLayout<UInt32>.stride,
            options: .storageModeShared)
    _ = mesh.addSubMesh(MeshBuffer(indexBuffer!, indices.count * MemoryLayout<UInt32>.stride, .index),
            .uint32, indices.count, .triangle)

    return mesh
}

class BoneMaterial: BaseMaterial {
    private static var _jointProp = Shader.getPropertyByName("u_joint")

    /// Tiling and offset of main textures.
    var joint: Matrix {
        get {
            shaderData.getBytes(BoneMaterial._jointProp) as! Matrix
        }
        set {
            let joint = shaderData.getBytes(BoneMaterial._jointProp) as! Matrix
            if (newValue !== joint) {
                newValue.cloneTo(target: joint)
            }
        }
    }


    /// Create a pbr base material instance.
    /// - Parameter engine: Engine to which the material belongs
    init(_ engine: Engine) {
        super.init(engine, Shader.find("bone")!)

        shaderData.setBytes(BoneMaterial._jointProp, Matrix())
    }
}

//MARK: - View
struct SkeletonView: View {
    let canvas: Canvas
    let engine: Engine

    init() {
        canvas = Canvas()
        engine = Engine(canvas, MetalRenderer())
        _ = Shader.create("bone", "bone_vertex", "bone_fragment")

        let scene = engine.sceneManager.activeScene
        let rootEntity = scene!.createRootEntity()

        let directLightNode = rootEntity.createChild("dir_light")
        let _: DirectLight = directLightNode.addComponent()
        directLightNode.transform.setPosition(x: 0, y: 0, z: 3)
        directLightNode.transform.lookAt(worldPosition: Vector3(0, 0, 0), worldUp: nil)

        // init camera
        let cameraEntity = rootEntity.createChild("camera")
        let _: Camera = cameraEntity.addComponent()
        cameraEntity.transform.setPosition(x: 10, y: 0, z: 0)
        cameraEntity.transform.lookAt(worldPosition: Vector3(0, 0, 0), worldUp: nil)
        let _: OrbitControl = cameraEntity.addComponent()

        // init skeleton
        var raw_skeleton = RawSkeleton()
        createSkeleton(&raw_skeleton)

        let builder = SkeletonBuilder()
        let skeleton = builder.eval(raw_skeleton)
        guard let skeleton = skeleton else {
            return
        }

        // local to model
        let num_joints = skeleton.num_joints()
        if (num_joints == 0) {
            return
        }

        // Reallocate matrix array if necessary.
        var prealloc_models_ = [simd_float4x4](repeating: simd_float4x4(), count: num_joints)

        // Compute model space bind pose.
        let job = LocalToModelJob()
        job.input = skeleton.joint_bind_poses()
        job.skeleton = skeleton
        if (!job.run(&prealloc_models_[...])) {
            return
        }

        var joints: [matrix_float4x4] = []
        fillPostureUniforms(skeleton, prealloc_models_, &joints)

        // add bone renderer
        let bone = createBone(engine)
        let joint = Matrix()
        for i in 0..<joints.count {
            let boneEntity = rootEntity.createChild("bone\(i)")
            let renderer: MeshRenderer = boneEntity.addComponent()
            let mtl = BoneMaterial(engine)
            joint.elements = joints[i]
            mtl.joint = joint
            renderer.mesh = bone
            renderer.setMaterial(mtl)
        }
    }

    var body: some View {
        EngineView(view: canvas)
    }
}

struct SkeletonView_Previews: PreviewProvider {
    static var previews: some View {
        SkeletonView()
    }
}

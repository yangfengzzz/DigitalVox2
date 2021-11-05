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

//MARK: - View
struct SkeletonView: View {
    let canvas: Canvas
    let engine: Engine

    init() {
        canvas = Canvas()
        engine = Engine(canvas, MetalRenderer())
        _ = Shader.create("bone", "bone_vertex", "bone_fragment")
        _ = Shader.create("joint", "joint_vertex", "bone_fragment")

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
        let boneMesh = createBoneMesh(engine)
        let jointMesh = createJointMesh(engine)
        let joint = Matrix()
        for i in 0..<joints.count {
            let boneEntity = rootEntity.createChild("bone\(i)")
            let renderer: MeshRenderer = boneEntity.addComponent()
            let mtl = BoneMaterial(engine)
            joint.elements = joints[i]
            mtl.joint = joint
            renderer.mesh = boneMesh
            renderer.setMaterial(mtl)
        }
        for i in 0..<joints.count {
            let boneEntity = rootEntity.createChild("joint\(i)")
            let renderer: MeshRenderer = boneEntity.addComponent()
            let mtl = JointMaterial(engine)
            joint.elements = joints[i]
            mtl.joint = joint
            renderer.mesh = jointMesh
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

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

let kPrecomputedKeys = [
    RawAnimation.TranslationKey(0.0 * kDuration, VecFloat3(0.25 * kWalkCycleLength, 0.0, 0.0)),
    RawAnimation.TranslationKey(0.125 * kDuration, VecFloat3(-0.25 * kWalkCycleLength, 0.0, 0.0)),
    RawAnimation.TranslationKey(0.145 * kDuration, VecFloat3(-0.17 * kWalkCycleLength, 0.3, 0.0)),
    RawAnimation.TranslationKey(0.23 * kDuration, VecFloat3(0.17 * kWalkCycleLength, 0.3, 0.0)),
    RawAnimation.TranslationKey(0.25 * kDuration, VecFloat3(0.25 * kWalkCycleLength, 0.0, 0.0)),
    RawAnimation.TranslationKey(0.375 * kDuration, VecFloat3(-0.25 * kWalkCycleLength, 0.0, 0.0)),
    RawAnimation.TranslationKey(0.395 * kDuration, VecFloat3(-0.17 * kWalkCycleLength, 0.3, 0.0)),
    RawAnimation.TranslationKey(0.48 * kDuration, VecFloat3(0.17 * kWalkCycleLength, 0.3, 0.0)),
    RawAnimation.TranslationKey(0.5 * kDuration, VecFloat3(0.25 * kWalkCycleLength, 0.0, 0.0)),
    RawAnimation.TranslationKey(0.625 * kDuration, VecFloat3(-0.25 * kWalkCycleLength, 0.0, 0.0)),
    RawAnimation.TranslationKey(0.645 * kDuration, VecFloat3(-0.17 * kWalkCycleLength, 0.3, 0.0)),
    RawAnimation.TranslationKey(0.73 * kDuration, VecFloat3(0.17 * kWalkCycleLength, 0.3, 0.0)),
    RawAnimation.TranslationKey(0.75 * kDuration, VecFloat3(0.25 * kWalkCycleLength, 0.0, 0.0)),
    RawAnimation.TranslationKey(0.875 * kDuration, VecFloat3(-0.25 * kWalkCycleLength, 0.0, 0.0)),
    RawAnimation.TranslationKey(0.895 * kDuration, VecFloat3(-0.17 * kWalkCycleLength, 0.3, 0.0)),
    RawAnimation.TranslationKey(0.98 * kDuration, VecFloat3(0.17 * kWalkCycleLength, 0.3, 0.0))
]

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

func createAnimation(_ skeleton_: SoaSkeleton, _ _animation: inout RawAnimation) {
    let kPrecomputedKeyCount = kPrecomputedKeys.count
    _animation.duration = kDuration
    _animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: skeleton_.num_joints())

    for i in 0..<_animation.num_tracks() {
        let joint_name = skeleton_.joint_names()[i]

        if (joint_name.contains("ld") || joint_name.contains("rd")) {
            let left = joint_name.contains("ld")  // First letter of "ld".

            // Copy original keys while taking into consideration the spine number
            // as a phase.
            let spine_number = Int(String(joint_name.dropFirst(2)))!
            let offset = kDuration * Float(slice_count_ - spine_number) / kSpinLoop
            let phase = fmod(offset, kDuration)

            // Loop to find animation start.
            var i_offset = 0
            while (i_offset < kPrecomputedKeyCount && kPrecomputedKeys[i_offset].time < phase) {
                i_offset += 1
            }

            // Push key with their corrected time.
            _animation.tracks[i].translations.reserveCapacity(kPrecomputedKeyCount)
            for j in i_offset..<(i_offset + kPrecomputedKeyCount) {
                let rkey = kPrecomputedKeys[j % kPrecomputedKeyCount]
                var new_time = rkey.time - phase
                if (new_time < 0.0) {
                    new_time = kDuration - phase + rkey.time
                }

                if (left) {
                    let tkey = RawAnimation.TranslationKey(new_time, kTransDown + rkey.value)
                    _animation.tracks[i].translations.append(tkey)
                } else {
                    let tkey = RawAnimation.TranslationKey(new_time, VecFloat3(kTransDown.x - rkey.value.x,
                            kTransDown.y + rkey.value.y, kTransDown.z + rkey.value.z))
                    _animation.tracks[i].translations.append(tkey)
                }
            }

            // Pushes rotation key-frame.
            if (left) {
                let rkey = RawAnimation.RotationKey(0.0, kRotLeftDown)
                _animation.tracks[i].rotations.append(rkey)
            } else {
                let rkey = RawAnimation.RotationKey(0.0, kRotRightDown)
                _animation.tracks[i].rotations.append(rkey)
            }
        } else if (joint_name.contains("lu")) {
            let tkey = RawAnimation.TranslationKey(0.0, kTransUp)
            _animation.tracks[i].translations.append(tkey)

            let rkey = RawAnimation.RotationKey(0.0, kRotLeftUp)
            _animation.tracks[i].rotations.append(rkey)

        } else if (joint_name.contains("ru")) {
            let tkey0 = RawAnimation.TranslationKey(0.0, kTransUp)
            _animation.tracks[i].translations.append(tkey0)

            let rkey0 = RawAnimation.RotationKey(0.0, kRotRightUp)
            _animation.tracks[i].rotations.append(rkey0)
        } else if (joint_name.contains("lf")) {
            let tkey = RawAnimation.TranslationKey(0.0, kTransFoot)
            _animation.tracks[i].translations.append(tkey)
        } else if (joint_name.contains("rf")) {
            let tkey0 = RawAnimation.TranslationKey(0.0, kTransFoot)
            _animation.tracks[i].translations.append(tkey0)
        } else if (joint_name.contains("sp")) {
            let skey = RawAnimation.TranslationKey(0.0, VecFloat3(0.0, 0.0, kSpinLength))
            _animation.tracks[i].translations.append(skey)

            let rkey = RawAnimation.RotationKey(0.0, VecQuaternion.identity())
            _animation.tracks[i].rotations.append(rkey)
        } else if (joint_name.contains("root")) {
            let tkey0 = RawAnimation.TranslationKey(0.0, VecFloat3(0.0, 1.0, -Float(slice_count_) * kSpinLength))
            _animation.tracks[i].translations.append(tkey0)
            let tkey1 = RawAnimation.TranslationKey(kDuration, VecFloat3(0.0, 1.0, Float(kWalkCycleCount) * kWalkCycleLength + tkey0.value.z))
            _animation.tracks[i].translations.append(tkey1)
        }

        // Make sure begin and end keys are looping.
        if (_animation.tracks[i].translations.first!.time != 0.0) {
            let front = _animation.tracks[i].translations.first!
            let back = _animation.tracks[i].translations.last!
            let lerp_time = front.time / (front.time + kDuration - back.time)
            let tkey = RawAnimation.TranslationKey(0.0, lerp(front.value, back.value, lerp_time))
            _animation.tracks[i].translations.insert(tkey, at: 0)
        }
        if (_animation.tracks[i].translations.last!.time != kDuration) {
            let front = _animation.tracks[i].translations.first!
            let back = _animation.tracks[i].translations.last!
            let lerp_time = (kDuration - back.time) / (front.time + kDuration - back.time)
            let tkey = RawAnimation.TranslationKey(kDuration, lerp(back.value, front.value, lerp_time))
            _animation.tracks[i].translations.append(tkey)
        }
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

        // Build a walk animation.
        var raw_animation = RawAnimation()
        createAnimation(skeleton, &raw_animation)

        // Build the run time animation from the raw animation.
        let animation_builder = AnimationBuilder()
        let animation_ = animation_builder.eval(raw_animation)
        guard let animation_ = animation_ else {
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

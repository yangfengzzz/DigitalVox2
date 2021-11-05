//
//  SkeletonLoaderView.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/5.
//

import SwiftUI

struct SkeletonLoaderView: View {
    let canvas: Canvas
    let engine: Engine
    let gltfLoader: GLTFAssetsLoader
    let usdzLoader: USDZAssetsLoader

    init() {
        canvas = Canvas()
        engine = Engine(canvas, MetalRenderer())
        gltfLoader = GLTFAssetsLoader(engine)
        usdzLoader = USDZAssetsLoader(engine)
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

        usdzLoader.load(with: "skeleton.usda") { [self] entities in
            rootEntity.addChild(entities[0])

            let renderer: SkinnedMeshRenderer = entities[0].getComponent()
            let skeleton = renderer.skeleton!
            let soa_skeleton = SoaSkeleton()
            soa_skeleton.allocate(skeleton.jointPaths.count)
            soa_skeleton.joint_names_ = skeleton.jointPaths[...]
            soa_skeleton.joint_parents_ = skeleton.parentIndices[...]

            let w_axis = simd_float4.w_axis()
            let zero = simd_float4.zero()
            let one = simd_float4.one()
            var translations = [SimdFloat4](repeating: SimdFloat4(), count: 4)
            var scales = [SimdFloat4](repeating: SimdFloat4(), count: 4)
            var rotations = [SimdFloat4](repeating: SimdFloat4(), count: 4)
            var i = 0
            while i < skeleton.restTransforms.count {
                for j in 0..<4 {
                    if i < skeleton.restTransforms.count {
                        let result = toAffine(skeleton.restTransforms[i], &translations[j], &rotations[j], &scales[j])
                        assert(result)
                        i += 1
                    } else {
                        translations[j] = zero
                        rotations[j] = w_axis
                        scales[j] = one
                    }
                }

                // Fills the SoaTransform structure.
                let soa_index = i / 4 - 1
                transpose4x3(translations, &soa_skeleton.joint_bind_poses_[soa_index].translation)
                transpose4x4(rotations, &soa_skeleton.joint_bind_poses_[soa_index].rotation)
                transpose4x3(scales, &soa_skeleton.joint_bind_poses_[soa_index].scale)
            }

            // local to model
            let num_joints = soa_skeleton.num_joints()
            if (num_joints == 0) {
                return
            }

            // Reallocate matrix array if necessary.
            var prealloc_models_ = [simd_float4x4](repeating: simd_float4x4(), count: num_joints)

            // Compute model space bind pose.
            let job = LocalToModelJob()
            job.input = soa_skeleton.joint_bind_poses()
            job.skeleton = soa_skeleton
            if (!job.run(&prealloc_models_[...])) {
                return
            }

            var joints: [matrix_float4x4] = []
            fillPostureUniforms(soa_skeleton, prealloc_models_, &joints)

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
    }

    var body: some View {
        EngineView(view: canvas)
    }
}

struct SkeletonLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        SceneLoaderView()
    }
}

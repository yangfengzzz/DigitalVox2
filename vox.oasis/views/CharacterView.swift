//
//  CharacterView.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/14.
//

import SwiftUI

class CharacterScript: Script {
    // Playback animation controller. This is a utility class that helps with
    // controlling animation playback time.
    let controller_ = PlaybackController()
    // The millipede skeleton.
    var skeleton_: SoaSkeleton!

    // The millipede procedural walk animation.
    var animation_: SoaAnimation!

    // Sampling cache, as used by SamplingJob.
    var cache_ = SamplingCache()

    // Buffer of local transforms as sampled from animation_.
    // These are shared between sampling output and local-to-model input.
    var locals_: [SoaTransform] = []

    // Buffer of model matrices (local-to-model output).
    var models_: [matrix_float4x4] = []

    var camera_: Entity!
    var boundingBox: Box = Box()

    var skinRenderer:[SkinnedMeshRenderer] = []

    required init(_ entity: Entity) {
        super.init(entity)
        _ = entity.getComponents(&skinRenderer)
    }

    func load(_ skeleton_: SoaSkeleton, _ animation_: SoaAnimation, _ camera_: Entity) {
        self.skeleton_ = skeleton_
        self.animation_ = animation_
        self.camera_ = camera_

        // Allocates runtime buffers.
        let num_soa_joints = skeleton_.num_soa_joints()
        let num_joints = skeleton_.num_joints()
        locals_ = [SoaTransform](repeating: SoaTransform.identity(), count: num_soa_joints)
        models_ = [matrix_float4x4](repeating: matrix_float4x4.identity(), count: num_joints)
        
        let bufferSize = num_joints * MemoryLayout<float4x4>.stride
        skinRenderer.forEach { renderer in
            renderer.jointMatrixPaletteBuffer = engine._hardwareRenderer.device.makeBuffer(length: bufferSize, options: [])
        }

        // Allocates a cache that matches new animation requirements.
        cache_.resize(num_joints)
    }

    override func onUpdate(_ deltaTime: Float) {
        // Updates current animation time
        controller_.update(animation_, deltaTime)

        // Samples animation at t = animation_time_.
        let sampling_job = SamplingJob()
        sampling_job.animation = animation_
        sampling_job.cache = cache_
        sampling_job.ratio = controller_.time_ratio()
        if (!sampling_job.run(&locals_[...])) {
            return
        }

        // Converts from local space to model space matrices.
        let ltm_job = LocalToModelJob()
        ltm_job.skeleton = skeleton_
        ltm_job.input = locals_[...]
        _ = ltm_job.run(&models_[...])
        
        skinRenderer.forEach { renderer in
            renderer.updateJoint(models_)
        }
//
//        // update camera position
//        computePostureBounds(models_[...], &boundingBox)
//        camera_.transform.setPosition(x: boundingBox.max.x + 2, y: boundingBox.max.y, z: boundingBox.max.z + 2)
//        let center = (boundingBox.max + boundingBox.min) * 0.5
//        camera_.transform.lookAt(worldPosition: Vector3(center.x, center.y, center.z), worldUp: nil)
    }

    // Loop through matrices and collect min and max bounds.
    func computePostureBounds(_ _matrices: ArraySlice<matrix_float4x4>,
                              _ _bound: inout Box) {
        if (_matrices.isEmpty) {
            return
        }

        // Loops through matrices and stores min/max.
        // Matrices array cannot be empty, it was checked at the beginning of the
        // function.
        let current = _matrices.first!
        var min = current.columns.3
        var max = current.columns.3
        _matrices.forEach { current in
            min = vox_oasis.min(min, current.columns.3)
            max = vox_oasis.max(max, current.columns.3)
        }

        // Stores in math::Box structure.
        var vec: [Float] = [0, 0, 0]
        store3PtrU(min, &vec)
        _bound.min.x = vec[0]
        _bound.min.y = vec[1]
        _bound.min.z = vec[2]
        store3PtrU(max, &vec)
        _bound.max.x = vec[0]
        _bound.max.y = vec[1]
        _bound.max.z = vec[2]
        return
    }
}


struct CharacterView: View {
    let canvas: Canvas
    let engine: Engine
    let usdzLoader: USDZAssetsLoader

    init() {
        canvas = Canvas()
        engine = Engine(canvas, MetalRenderer())
        usdzLoader = USDZAssetsLoader(engine)

        let scene = engine.sceneManager.activeScene
        let rootEntity = scene!.createRootEntity()

        let directLightNode = rootEntity.createChild("dir_light")
        let _: DirectLight = directLightNode.addComponent()
        directLightNode.transform.setPosition(x: 0, y: 0, z: 3)
        directLightNode.transform.lookAt(worldPosition: Vector3(0, 0, 0), worldUp: nil)

        // init camera
        let cameraEntity = rootEntity.createChild("camera")
        let _: Camera = cameraEntity.addComponent()
        cameraEntity.transform.setPosition(x: 0, y: 0, z: 15)
        cameraEntity.transform.lookAt(worldPosition: Vector3(0, 0, 0), worldUp: nil)
        let _: OrbitControl = cameraEntity.addComponent()

        usdzLoader.load(with: "Doggy.usdz") { entities in
            let character = entities[0]
            character.transform.setScale(x: 0.1, y: 0.1, z: 0.1)
            character.transform.setPosition(x: 0, y: -3, z: 0)
            
            let s = SoaSkeleton()
            s.load("doggy_skeleton.ozz")

            let a = SoaAnimation()
            a.load("Run.ozz")
            
            let script: CharacterScript = character.addComponent()
            script.load(s, a, cameraEntity)
            
            rootEntity.addChild(character)
        }
    }

    var body: some View {
        EngineView(view: canvas)
    }
}

struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterView()
    }
}

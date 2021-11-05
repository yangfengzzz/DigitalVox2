//
//  SkeletonView.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/5.
//

import SwiftUI

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
        raw_skeleton.roots = [RawSkeleton.Joint()]
        let root = raw_skeleton.roots[0]
        root.name = "j0"
        root.transform = VecTransform.identity()
        root.transform.translation = VecFloat3(1.0, 2.0, 3.0)
        root.transform.rotation = VecQuaternion(1.0, 0.0, 0.0, 0.0)

        root.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        root.children[0].name = "j1"
        root.children[0].transform = VecTransform.identity()
        root.children[0].transform.rotation = VecQuaternion(0.0, 1.0, 0.0, 0.0)
        root.children[0].transform.translation = VecFloat3(4.0, 5.0, 6.0)
        root.children[1].name = "j2"
        root.children[1].transform = VecTransform.identity()
        root.children[1].transform.translation = VecFloat3(7.0, 8.0, 9.0)
        root.children[1].transform.scale = VecFloat3(-27.0, 46.0, 9.0)

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

        // uniform builder
        // Prepares computation constants.
        let parents = skeleton.joint_parents()
        var _uniforms:[simd_float4x4] = []
        var instances = 0
        for i in 0..<num_joints {
            // Root isn't rendered.
            let parent_id = parents[i]
            if (parent_id == SoaSkeleton.Constants.kNoParent.rawValue) {
                continue
            }

            // Selects joint matrices.
            let parent = prealloc_models_[parent_id]
            let current = prealloc_models_[i]

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

        // add bone renderer
        let boneEntity = rootEntity.createChild("bone")
        let renderer: MeshRenderer = boneEntity.addComponent()
        let mtl = BoneMaterial(engine)
        let joint = Matrix()
        joint.elements = _uniforms[0]
        mtl.joint = joint
        renderer.mesh = createBone(engine)
        renderer.setMaterial(mtl)
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

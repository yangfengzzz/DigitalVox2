//
//  PhysXDynamicView.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/11.
//

import SwiftUI

struct PhysXDynamicView: View {
    let canvas: Canvas
    let engine: Engine
    let rootEntity: Entity

    func addPlane(_ size: Vector3, _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = BlinnPhongMaterial(engine)
        _ = mtl.baseColor.setValue(r: 0.03179807202597362, g: 0.3939682161541871, b: 0.41177952549087604, a: 1.0)
        let planeEntity = rootEntity.createChild()
        planeEntity.layer = Layer.Layer1

        let renderer: MeshRenderer = planeEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createCuboid(engine, size.x, size.y, size.z)
        renderer.setMaterial(mtl)
        planeEntity.transform.position = position
        planeEntity.transform.rotationQuaternion = rotation

        let physicsPlane = PlaneColliderShape()
        let planeCollider: StaticCollider = planeEntity.addComponent()
        planeCollider.addShape(physicsPlane)

        return planeEntity
    }

    func addBox(_ size: Vector3, _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = BlinnPhongMaterial(engine)
        _ = mtl.baseColor.setValue(r: Float.random(in: 0..<1), g: Float.random(in: 0..<1), b: Float.random(in: 0..<1), a: 1.0)
        let boxEntity = rootEntity.createChild()
        let renderer: MeshRenderer = boxEntity.addComponent()

        renderer.mesh = PrimitiveMesh.createCuboid(engine, size.x, size.y, size.z)
        renderer.setMaterial(mtl)
        boxEntity.transform.position = position
        boxEntity.transform.rotationQuaternion = rotation

        let physicsBox = BoxColliderShape()
        physicsBox.size = size
        physicsBox.material.staticFriction = 1
        physicsBox.material.dynamicFriction = 2
        physicsBox.material.bounciness = 0.1
        physicsBox.isTrigger = false

        let boxCollider: DynamicCollider = boxEntity.addComponent()
        boxCollider.addShape(physicsBox)

        return boxEntity
    }

    func addSphere(_ radius: Float, _ position: Vector3, _ rotation: Quaternion, _ velocity: Vector3) -> Entity {
        let mtl = BlinnPhongMaterial(engine)
        _ = mtl.baseColor.setValue(r: Float.random(in: 0..<1), g: Float.random(in: 0..<1), b: Float.random(in: 0..<1), a: 1.0)
        let sphereEntity = rootEntity.createChild()
        let renderer: MeshRenderer = sphereEntity.addComponent()

        renderer.mesh = PrimitiveMesh.createSphere(engine, radius)
        renderer.setMaterial(mtl)
        sphereEntity.transform.position = position
        sphereEntity.transform.rotationQuaternion = rotation

        let physicsSphere = SphereColliderShape()
        physicsSphere.radius = radius
        physicsSphere.material.staticFriction = 0.1
        physicsSphere.material.dynamicFriction = 0.2
        physicsSphere.material.bounciness = 1
        physicsSphere.material.bounceCombine = PhysicsMaterialCombineMode.Minimum

        let sphereCollider: DynamicCollider = sphereEntity.addComponent()
        sphereCollider.addShape(physicsSphere)
        sphereCollider.linearVelocity = velocity
        sphereCollider.angularDamping = 0.5

        return sphereEntity
    }

    func addCapsule(_ radius: Float, _ height: Float, _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = BlinnPhongMaterial(engine)
        _ = mtl.baseColor.setValue(r: Float.random(in: 0..<1), g: Float.random(in: 0..<1), b: Float.random(in: 0..<1), a: 1.0)
        let capsuleEntity = rootEntity.createChild()
        let renderer: MeshRenderer = capsuleEntity.addComponent()

        renderer.mesh = PrimitiveMesh.createCapsule(engine, radius, height)
        renderer.setMaterial(mtl)
        capsuleEntity.transform.position = position
        capsuleEntity.transform.rotationQuaternion = rotation

        let physicsCapsule = CapsuleColliderShape()
        physicsCapsule.radius = radius
        physicsCapsule.height = height

        let capsuleCollider: DynamicCollider = capsuleEntity.addComponent()
        capsuleCollider.addShape(physicsCapsule)

        return capsuleEntity
    }

    func addPlayer(_ radius: Float, _ height: Float, _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = BlinnPhongMaterial(engine)
        _ = mtl.baseColor.setValue(r: Float.random(in: 0..<1), g: Float.random(in: 0..<1), b: Float.random(in: 0..<1), a: 1.0)
        let capsuleEntity = rootEntity.createChild()
        let renderer: MeshRenderer = capsuleEntity.addComponent()

        renderer.mesh = PrimitiveMesh.createCapsule(engine, radius, height, 20)
        renderer.setMaterial(mtl)
        capsuleEntity.transform.position = position
        capsuleEntity.transform.rotationQuaternion = rotation

        let physicsCapsule = CapsuleColliderShape()
        physicsCapsule.radius = radius
        physicsCapsule.height = height

        let characterController: CapsuleCharacterController = capsuleEntity.addComponent()
        let characterControllerDesc = CapsuleCharacterControllerDesc()
        characterControllerDesc.radius = radius
        characterControllerDesc.height = height
        characterController.setDesc(characterControllerDesc)

        return capsuleEntity
    }

    class ControllerScript: Script {
        var character: CharacterController
        var displacement = Vector3()

        required init(_ entity: Entity) {
            character = entity.getComponent()
            super.init(entity)
        }

        func targetCamera(_ camera: Entity) {
            engine.canvas.registerKeyDown { [self] key in
                var forward = Vector3()
                Vector3.subtract(left: entity.transform.position, right: camera.transform.position, out: forward)
                forward.y = 0
                forward = forward.normalize()
                let cross = Vector3(forward.z, 0, -forward.x)

                switch key {
                case .w:
                    displacement = forward.scale(s: 0.3)
                    break
                case .s:
                    displacement = forward.negate().scale(s: 0.3)
                    break
                case .a:
                    displacement = cross.scale(s: 0.3)
                    break
                case .d:
                    displacement = cross.negate().scale(s: 0.3)
                    break
                case .space:
                    displacement.x = 0
                    displacement.y = 2
                    displacement.z = 0
                    break
                default:
                    return
                }
            }
        }

        override func onUpdate(_ deltaTime: Float) {
            let flags = character.move(displacement, 0.1, deltaTime)
            displacement.x = 0
            displacement.y = 0
            displacement.z = 0
            if !character.isSetControllerCollisionFlag(flags, .COLLISION_DOWN) {
                _ = character.move(Vector3(0, -0.2, 0), 0.1, deltaTime)
            }
        }
    }

    func transform(_ position: Vector3, _ rotation: Quaternion, _ outPosition: Vector3, _ outRotation: Quaternion) {
        Quaternion.multiply(left: rotation, right: outRotation, out: outRotation)
        Vector3.transformByQuat(v: outPosition, quaternion: rotation, out: outPosition)
        Vector3.add(left: outPosition, right: position, out: outPosition)
    }

    func createChain(_ position: Vector3, _ rotation: Quaternion, _ length: Int, _ separation: Float) {
        let offset = Vector3(0, -separation / 2, 0)
        var prevCollider: DynamicCollider? = nil
        for i in 0..<length {
            let localTm_pos = Vector3(0, -separation / 2 * (2 * Float(i) + 1), 0)
            let localTm_quat = Quaternion()
            transform(position, rotation, localTm_pos, localTm_quat)

            let currentEntity = addBox(Vector3(2.0, 2.0, 0.5), localTm_pos, localTm_quat)
            let currentCollider: DynamicCollider = currentEntity.getComponent()

            let joint = FixedJoint(prevCollider, currentCollider)
            joint.localPosition0 = prevCollider != nil ? offset : position
            joint.localRotation0 = prevCollider != nil ? Quaternion() : rotation
            joint.localPosition1 = Vector3(0, separation / 2, 0)
            joint.localRotation1 = Quaternion()

            prevCollider = currentCollider
        }
    }

    init() {
        canvas = Canvas()
        PhysXPhysics.initialization()
        engine = Engine(canvas, MetalRenderer(), physics: PhysXPhysics.self)
        let scene = engine.sceneManager.activeScene
        rootEntity = scene!.createRootEntity()

        _ = scene!.ambientLight.diffuseSolidColor.setValue(x: 1, y: 1, z: 1)

        // init camera
        let cameraEntity = rootEntity.createChild("camera")
        let _: Camera = cameraEntity.addComponent()
        cameraEntity.transform.setPosition(x: 10, y: 10, z: 10)
        cameraEntity.transform.lookAt(worldPosition: Vector3(), worldUp: nil)
        let _: OrbitControl = cameraEntity.addComponent()

        // init point light
        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 0, y: 3, z: 0)
        let pointLight: PointLight = light.addComponent()
        pointLight.intensity = 0.3

        let player = addPlayer(1, 3, Vector3(0, 6.5, 0), Quaternion())
        let controller: ControllerScript = player.addComponent()
        controller.targetCamera(cameraEntity)

        _ = addPlane(Vector3(30, 0.1, 30), Vector3(), Quaternion())
        for i in 0..<5 {
            let i = Float(i)
            for j in 0..<5 {
                let j = Float(j)
                _ = addBox(Vector3(1, 1, 1),
                        Vector3(-2.5 + i + 0.1 * i, floor(Float.random(in: 0..<1) * 6) + 1, -2.5 + j + 0.1 * j),
                        Quaternion(0, 0, 0.3, 0.7))
            }
        }
        createChain(Vector3(0.0, 25.0, -10.0), Quaternion(), 10, 2.0)

        canvas.registerMouseDown { [self](event) in
            let ray = Ray()
            let camera: Camera = cameraEntity.getComponent()

            var mousePoint = event.locationInWindow
            mousePoint = canvas.convert(mousePoint, to: nil)
            mousePoint = NSMakePoint(mousePoint.x, canvas.bounds.size.height - mousePoint.y)
            _ = camera.screenPointToRay(Vector2(Float(mousePoint.x), Float(mousePoint.y)), ray)

            let hit = HitResult()
            let result = engine.physicsManager!.raycast(ray, Float.greatestFiniteMagnitude, Layer.Layer0, hit)
            if (result) {
                let mtl = BlinnPhongMaterial(engine)
                let color = mtl.baseColor
                color.r = Float.random(in: 0..<1)
                color.g = Float.random(in: 0..<1)
                color.b = Float.random(in: 0..<1)
                color.a = 1.0

                var meshes: [MeshRenderer] = []
                _ = hit.entity!.getComponentsIncludeChildren(&meshes)
                meshes.forEach { mesh in
                    mesh.setMaterial(mtl)
                }
            }
        }

        canvas.registerKeyDown { [self] key in
            let dir = Vector3()
            _ = cameraEntity.transform.getWorldForward(forward: dir)
            Vector3.scale(left: dir, s: 50, out: dir)
            switch (key) {
            case .space:
                _ = addSphere(0.5, cameraEntity.transform.position,
                        cameraEntity.transform.rotationQuaternion, dir)
                break
            default:
                return
            }
        }
    }

    var body: some View {
        EngineView(view: canvas)
    }
}

struct PhysXDynamicView_Previews: PreviewProvider {
    static var previews: some View {
        SceneLoaderView()
    }
}

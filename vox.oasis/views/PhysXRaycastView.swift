//
//  PhysXRaycastView.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import SwiftUI

struct PhysXRaycastView: View {
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
        let color = mtl.baseColor
        color.r = Float.random(in: 0..<1)
        color.g = Float.random(in: 0..<1)
        color.b = Float.random(in: 0..<1)
        color.a = 1.0
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

        let boxCollider: StaticCollider = boxEntity.addComponent()
        boxCollider.addShape(physicsBox)

        return boxEntity
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
        let _: OrbitControl = cameraEntity.addComponent()

        // init point light
        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 0, y: 3, z: 0)
        let pointLight: PointLight = light.addComponent()
        pointLight.intensity = 0.3


        // create box test entity
        let cubeSize: Float = 2.0
        let boxEntity = rootEntity.createChild("BoxEntity")

        let boxMtl = BlinnPhongMaterial(engine)
        let boxRenderer: MeshRenderer = boxEntity.addComponent()
        _ = boxMtl.baseColor.setValue(r: 0.8, g: 0.3, b: 0.3, a: 1.0)
        boxRenderer.mesh = PrimitiveMesh.createCuboid(engine, cubeSize, cubeSize, cubeSize)
        boxRenderer.setMaterial(boxMtl)

        let boxCollider: StaticCollider = boxEntity.addComponent()
        let boxColliderShape = BoxColliderShape()
        boxColliderShape.setSize(cubeSize, cubeSize, cubeSize)
        boxCollider.addShape(boxColliderShape)

        // create sphere test entity
        let radius: Float = 1.25
        let sphereEntity = rootEntity.createChild("SphereEntity")
        sphereEntity.transform.setPosition(x: -5, y: 0, z: 0)

        let sphereMtl = BlinnPhongMaterial(engine)
        let sphereRenderer: MeshRenderer = sphereEntity.addComponent()
        _ = sphereMtl.baseColor.setValue(
                r: Float.random(in: 0..<1),
                g: Float.random(in: 0..<1),
                b: Float.random(in: 0..<1), a: 1.0)
        sphereRenderer.mesh = PrimitiveMesh.createSphere(engine, radius)
        sphereRenderer.setMaterial(sphereMtl)

        let sphereCollider: DynamicCollider = sphereEntity.addComponent()
        let sphereColliderShape = SphereColliderShape()
        sphereColliderShape.radius = radius
        sphereColliderShape.isTrigger = true
        sphereCollider.addShape(sphereColliderShape)

        class MoveScript: Script {
            var pos: Vector3 = Vector3(-5, 0, 0)
            var vel: Float = 4
            var velSign: Int = -1

            override func onUpdate(_ deltaTime: Float) {
                super.onUpdate(deltaTime)
                if (pos.x >= 5) {
                    velSign = -1
                }
                if (pos.x <= -5) {
                    velSign = 1
                }
                pos.x += deltaTime * vel * Float(velSign)

                entity.transform.position = pos
            }
        }

        // Collision Detection
        class CollisionScript: Script {
            var sphereRenderer: MeshRenderer?

            override func onTriggerExit(_ other: ColliderShape) {
                _ = (sphereRenderer!.getMaterial() as! BlinnPhongMaterial).baseColor.setValue(
                        r: Float.random(in: 0..<1),
                        g: Float.random(in: 0..<1),
                        b: Float.random(in: 0..<1), a: 1.0)
            }

            override func onTriggerStay(_ other: ColliderShape) {
            }

            override func onTriggerEnter(_ other: ColliderShape) {
                _ = (sphereRenderer!.getMaterial() as! BlinnPhongMaterial).baseColor.setValue(
                        r: Float.random(in: 0..<1),
                        g: Float.random(in: 0..<1),
                        b: Float.random(in: 0..<1), a: 1.0)
            }
        }

        let collisionScript: CollisionScript = sphereEntity.addComponent()
        collisionScript.sphereRenderer = sphereRenderer
        let _: MoveScript = sphereEntity.addComponent()
    }

    var body: some View {
        EngineView(view: canvas)
    }
}

struct PhysXRaycastView_Previews: PreviewProvider {
    static var previews: some View {
        SceneLoaderView()
    }
}

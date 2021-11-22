//
//  CharacterView.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/14.
//

import SwiftUI

class CharacterScript: Script {
    // last position
    let position = Vector3()
    // last rotation
    let rotMat = Matrix()
    let rotation = Quaternion()

    func targetCamera(_ camera: Entity) {
        engine.canvas.registerKeyDown { [self] key in
            var forward = Vector3()
            _ = camera.transform.getWorldForward(forward: forward)
            forward.y = 0
            forward = forward.normalize()
            let cross = Vector3(forward.z, 0, -forward.x)

            entity.transform.worldPosition.cloneTo(target: position)
            switch key {
            case .w:
                position.x += forward.x * 2;
                position.z += forward.z * 2;
                break
            case .s:
                position.x -= forward.x * 2;
                position.z -= forward.z * 2;
                break
            case .a:
                position.x += cross.x * 2;
                position.z += cross.z * 2;
                break
            case .d:
                position.x -= cross.x * 2;
                position.z -= cross.z * 2;
                break
            default:
                return
            }

            Matrix.lookAt(eye: position, target: entity.transform.worldPosition, up: Vector3(0, 1, 0), out: rotMat)
            _ = rotMat.getRotation(out: rotation).invert()
        }
    }

    override func onUpdate(_ deltaTime: Float) {
        let currentPosition = entity.transform.position
        Vector3.lerp(left: currentPosition, right: position, t: 0.1, out: currentPosition)
        entity.transform.position = currentPosition

        let currentRot = entity.transform.rotationQuaternion
        Quaternion.slerp(start: currentRot, end: rotation, t: 0.05, out: currentRot)
        entity.transform.rotationQuaternion = currentRot
    }
}

class AnimationBlending: Script {
    let cpuSkinning: CPUSkinning
    var animationWeightMap: [String: Float] = [
        "Idle": 1.0,
        "Walk": 0.0,
        "Run": 0.0,
        "Dash": 0.0,
        "Jump_In": 0.0,
        "Fall": 0.0,
        "Landing": 0.0,
        "Battle_Idle": 0.0,
        "Hit": 0.0,
        "Lose": 0.0,
        "Slide": 0.0,
    ]

    required init(_ entity: Entity) {
        cpuSkinning = entity.addComponent()
        super.init(entity)

        cpuSkinning.load("doggy_skeleton.ozz", "doggy.ozz")
        animationWeightMap.forEach { (key: String, value: Float) in
            cpuSkinning.loadAnimation(key + ".ozz")
        }

        //GUI
        let gui = engine.canvas.gui
        engine.canvas.registerGUI { [self]() in
            gui.begin("control panel")
            gui.text("animation blending")
            animationWeightMap.forEach { (key: String, value: Float) in
                gui.sliderFloat(key, &animationWeightMap[key]!, 0, 1)
            }
            gui.showFrameRate()
            engine.canvas.gui.end()
        }
    }

    override func onUpdate(_ deltaTime: Float) {
        animationWeightMap.enumerated().forEach { element in
            cpuSkinning.adjustWeight(element.offset, element.element.value)
        }
    }
}

struct CharacterView: View {
    let canvas: Canvas
    let engine: Engine
    let rootEntity: Entity
    var animationLists: [String: Float] = ["Run.ozz": 1, "Hit.ozz": 1]

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

    init() {
        canvas = Canvas()
        PhysXPhysics.initialization()
        engine = Engine(canvas, MetalRenderer(), physics: PhysXPhysics.self)
        let scene = engine.sceneManager.activeScene
        rootEntity = scene!.createRootEntity()

        let directLightNode = rootEntity.createChild("dir_light")
        let _: DirectLight = directLightNode.addComponent()
        directLightNode.transform.setPosition(x: 0, y: 0, z: 3)
        directLightNode.transform.lookAt(worldPosition: Vector3(0, 0, 0), worldUp: nil)

        // init camera
        let cameraEntity = rootEntity.createChild("camera")
        let _: Camera = cameraEntity.addComponent()
        cameraEntity.transform.setPosition(x: 0, y: 5, z: 15)
        cameraEntity.transform.lookAt(worldPosition: Vector3(0, 0, 0), worldUp: nil)
//        let _: OrbitControl = cameraEntity.addComponent()

        _ = addPlane(Vector3(30, 0.1, 30), Vector3(), Quaternion())

        let character = rootEntity.createChild("character");
        character.transform.setScale(x: 5, y: 5, z: 5)
        let _: AnimationBlending = character.addComponent()
        let characterController: CharacterScript = character.addComponent()
        characterController.targetCamera(cameraEntity)
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

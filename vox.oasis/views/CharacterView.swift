//
//  CharacterView.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/14.
//

import SwiftUI

class CharacterScript: Script {
    var displacement = Vector3()
    let worldPosition = Vector3()
    
    func targetCamera(_ camera: Entity) {
        engine.canvas.registerKeyDown { [self] key in
            var forward = Vector3()
            Vector3.subtract(left: entity.transform.position, right: camera.transform.position, out: forward)
            forward.y = 0
            forward = forward.normalize()
            let cross = Vector3(forward.z, 0, -forward.x)

            switch key {
            case .w:
                displacement = forward.negate().scale(s: 0.1)
                break
            case .s:
                displacement = forward.scale(s: 0.1)
                break
            case .a:
                displacement = cross.negate().scale(s: 0.1)
                break
            case .d:
                displacement = cross.scale(s: 0.1)
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
        let position = entity.transform.worldPosition
        
        position.cloneTo(target: worldPosition)
        worldPosition.elements += displacement.elements;
        entity.transform.lookAt(worldPosition: worldPosition, worldUp: nil)
        
        position.elements -= displacement.elements;
        entity.transform.worldPosition = position
        
        displacement.x = 0
        displacement.y = 0
        displacement.z = 0
    }
}

struct CharacterView: View {
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
        cameraEntity.transform.setPosition(x: 0, y: 15, z: 15)
        cameraEntity.transform.lookAt(worldPosition: Vector3(0, 0, 0), worldUp: nil)
        let _: OrbitControl = cameraEntity.addComponent()
        
        _ = addPlane(Vector3(30, 0.1, 30), Vector3(), Quaternion())

        let character = rootEntity.createChild("character");
        character.transform.setScale(x: 5, y: 5, z: 5)
        let cpuSkinning: CPUSkinning = character.addComponent()
        cpuSkinning.load("doggy_skeleton.ozz", "Run.ozz", "doggy.ozz")
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

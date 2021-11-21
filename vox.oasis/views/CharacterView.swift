//
//  CharacterView.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/14.
//

import SwiftUI

class CharacterScript: Script {
    // total
    let displacement = Vector3()
    // current frame
    let currentMove = Vector3()
    // new position
    let worldPosition = Vector3()
    
    func targetCamera(_ camera: Entity) {
        engine.canvas.registerKeyDown { [self] key in
            var forward = Vector3()
            _ = camera.transform.getWorldForward(forward: forward)
            forward.y = 0
            forward = forward.normalize()
            let cross = Vector3(forward.z, 0, -forward.x)

            switch key {
            case .w:
                displacement.x -= forward.x;
                displacement.z -= forward.z;
                break
            case .s:
                displacement.x += forward.x;
                displacement.z += forward.z;
                break
            case .a:
                displacement.x -= cross.x;
                displacement.z -= cross.z;
                break
            case .d:
                displacement.x += cross.x;
                displacement.z += cross.z;
                break
            case .space:
                displacement.y += 2
                break
            default:
                return
            }
        }
    }

    override func onUpdate(_ deltaTime: Float) {
        func movement(_ x: inout Float)->Float {
            var subStep:Float = 0.1
            if x < -subStep {
                x += subStep
                return -subStep
            } else if x < subStep && x >= -subStep {
                subStep = x
                x = 0
                return subStep
            } else {
                x -= subStep
                return subStep
            }
        }
        currentMove.x = movement(&displacement.x)
        currentMove.y = movement(&displacement.y)
        currentMove.z = movement(&displacement.z)
                
        let position = entity.transform.position
        
        position.cloneTo(target: worldPosition)
        worldPosition.elements += currentMove.elements;
        entity.transform.lookAt(worldPosition: worldPosition, worldUp: nil)
        
        position.elements -= currentMove.elements;
        entity.transform.position = position
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

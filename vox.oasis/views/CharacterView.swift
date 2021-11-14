//
//  CharacterView.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/14.
//

import SwiftUI

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

        usdzLoader.load(with: "Doggy.usdz") { [self] entities in
            let character = entities[0]
            character.transform.setScale(x: 0.1, y: 0.1, z: 0.1)
            character.transform.setPosition(x: 0, y: -3, z: 0)
            
//            let animator: Animator =  character.getComponent()
//            animator.runAnimation(name: "Anim_Idle")
            
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

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

    init() {
        canvas = Canvas()
        engine = Engine(canvas, MetalRenderer())

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

        let character = rootEntity.createChild("character");
        let cpuSkinning: CPUSkinning = character.addComponent()
        cpuSkinning.load("doggy_skeleton.ozz", "Run.ozz", "doggy.ozz")
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

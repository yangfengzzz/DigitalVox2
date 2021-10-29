//
//  ContentView.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import SwiftUI

struct SceneLoaderView: View {
    let canvas: Canvas
    let engine: Engine
    let gltfLoader: GLTFAssetsLoader
    let usdzLoader: USDZAssetsLoader

    class Rotation: Script {
        var angle: Float = 0

        override func onUpdate(_ deltaTime: Float) {
            angle += 0.5
            entity.transform.setRotation(x: 0, y: angle, z: 0)
        }
    }

    init() {
        canvas = Canvas()
        engine = Engine(canvas, MetalRenderer())
        gltfLoader = GLTFAssetsLoader(engine)
        usdzLoader = USDZAssetsLoader(engine)

        let scene = engine.sceneManager.activeScene
        scene?.background.mode = .Sky
        scene?.background.sky.load("sky")

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

        usdzLoader.load(with: "Mando_Helmet.usdz") { entities in
            entities[0].transform.setPosition(x: 0, y: -2, z: 0)
            entities[0].transform.setScale(x: 0.1, y: 0.1, z: 0.1)
            entities[0].transform.setRotation(x: 0, y: 90, z: 0)
            let _: Rotation = entities[0].addComponent()
            rootEntity.addChild(entities[0])
        }
    }

    var body: some View {
        EngineView(view: canvas)
    }
}

struct SceneLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        SceneLoaderView()
    }
}

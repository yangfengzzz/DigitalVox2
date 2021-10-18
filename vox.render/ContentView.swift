//
//  ContentView.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import SwiftUI

struct ContentView: View {
    let canvas: Canvas
    let engine: Engine
    let asset: Assets

    init() {
        canvas = Canvas()
        engine = Engine(canvas, MetalRenderer())
        asset = Assets(engine)

        let scene = engine.sceneManager.activeScene
        _ = scene?.background.solidColor.setValue(r: 0.7, g: 0.9, b: 1, a: 1)
        let rootEntity = scene!.createRootEntity()

        // init camera
        let cameraEntity = rootEntity.createChild("camera")
        let _: Camera = cameraEntity.addComponent()
        cameraEntity.transform.setPosition(x: 10, y: 0, z: 0)
        cameraEntity.transform.lookAt(worldPosition: Vector3(0, 0, 0), worldUp: nil)
        let _: OrbitControl = cameraEntity.addComponent()

        let simpleMtl = MetalMaterial(engine)

        let assetEntity = rootEntity.createChild()
        let assetRenderer: MeshRenderer = assetEntity.addComponent()
        asset.load(name: "cottage1.obj")
        simpleMtl.baseTexture = try? asset.loadTexture(imageName: "cottage-color")

        assetRenderer.mesh = asset.meshes[0]
        assetRenderer.setMaterial(0, simpleMtl)
        assetRenderer.setMaterial(1, simpleMtl)
        assetRenderer.setMaterial(2, simpleMtl)
        assetRenderer.setMaterial(3, simpleMtl)
    }

    var body: some View {
        EngineView(view: canvas)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

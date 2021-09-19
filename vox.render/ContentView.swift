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
        let rootEntity = scene!.createRootEntity()

        // init camera
        let cameraEntity = rootEntity.createChild("camera")
        let _: Camera = cameraEntity.addComponent()
        cameraEntity.transform.setPosition(x: 0, y: 0, z: 4)
        let _: OrbitControl = cameraEntity.addComponent()

        let simpleMtl = SimpleMaterial(engine)
        
        // let cubeEntity = rootEntity.createChild()
        // let cubeRenderer: MeshRenderer = cubeEntity.addComponent()
        // let box = PrimitiveMesh.createCuboid(engine)
        // cubeRenderer.mesh = box
        // cubeRenderer.setMaterial(material: simpleMtl)

        let assetEntity = rootEntity.createChild()
        let assetRenderer: MeshRenderer = assetEntity.addComponent()
        asset.load(name: "cottage1.obj")
        assetRenderer.mesh = asset.meshes[0]
        assetRenderer.setMaterial(index: 0, material: simpleMtl)
        assetRenderer.setMaterial(index: 1, material: simpleMtl)
        assetRenderer.setMaterial(index: 2, material: simpleMtl)
        assetRenderer.setMaterial(index: 3, material: simpleMtl)
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

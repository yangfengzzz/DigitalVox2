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

    init() {
        canvas = Canvas(frame: .zero, device: MTLCreateSystemDefaultDevice())
        engine = Engine(canvas, MetalGPURenderer())

        let scene = engine.sceneManager.activeScene
        let rootEntity = scene!.createRootEntity()

        // init camera
        let cameraEntity = rootEntity.createChild("camera")
        let _: Camera = cameraEntity.addComponent()
        cameraEntity.transform.setPosition(x: 0, y: 0, z: 3)
//        cameraEntity.transform.lookAt(worldPosition: Vector3(0, 0, 3), worldUp: nil)

        let cubeEntity = rootEntity.createChild()
        let _: MeshRenderer = cubeEntity.addComponent()
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

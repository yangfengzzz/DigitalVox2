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
        canvas.inputController?.player = cameraEntity

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

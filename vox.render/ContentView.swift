//
//  ContentView.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import SwiftUI

struct ContentView: View {
    let controllerView: ControllerView
    let engine: Engine

    init() {
        controllerView = ControllerView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        engine = Engine(controllerView, MetalGPURenderer()) { engine in
            // models
            let house = Model(name: "cube.obj")
            house.position = [0, 0, 0]
            engine.models.append(house)
        }
    }

    var body: some View {
        EngineView(view: controllerView)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

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

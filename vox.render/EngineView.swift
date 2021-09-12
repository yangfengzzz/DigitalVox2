//
//  EngineView.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit
import SwiftUI

struct EngineView: UIViewRepresentable {
    let view: Canvas

    func makeUIView(context: UIViewRepresentableContext<EngineView>) -> Canvas {
        view
    }

    func updateUIView(_ nsView: Canvas, context: UIViewRepresentableContext<EngineView>) {
    }
}

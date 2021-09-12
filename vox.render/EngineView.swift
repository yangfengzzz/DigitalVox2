//
//  EngineView.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit
import SwiftUI

struct EngineView: UIViewRepresentable {
    let view: ControllerView

    func makeUIView(context: UIViewRepresentableContext<EngineView>) -> ControllerView {
        view
    }

    func updateUIView(_ nsView: ControllerView, context: UIViewRepresentableContext<EngineView>) {
    }
}

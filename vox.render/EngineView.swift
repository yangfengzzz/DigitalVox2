//
//  EngineView.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit
import SwiftUI

struct EngineView: UIViewRepresentable {
    let view: Engine
    func makeUIView(context: UIViewRepresentableContext<EngineView>) -> Engine {
        return view
    }
    
    func updateUIView(_ nsView: Engine, context: UIViewRepresentableContext<EngineView>) {}
}

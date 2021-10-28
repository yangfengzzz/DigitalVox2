//
//  EngineView.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit
import SwiftUI

struct EngineView: NSViewRepresentable {
    typealias NSViewType = Canvas
    
    let view: Canvas
    
    func makeNSView(context: Context) -> Canvas {
        view
    }
    
    func updateNSView(_ nsView: Canvas, context: Context) {
        
    }
}

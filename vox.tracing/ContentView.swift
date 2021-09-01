//
//  ContentView.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/1.
//

import SwiftUI

struct ContentView: View {
    let rayrenderer = RayRenderer()

    var body: some View {
        MetalKitRayView(view: rayrenderer)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

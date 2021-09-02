//
//  ContentView.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import SwiftUI

struct ContentView: View {
    let engine = Engine() { engine in
        // models
        let house = Model(name: "cube.obj")
        house.position = [0, 0, 0]
        engine.models.append(house)
    }

    var body: some View {
        EngineView(view: engine)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

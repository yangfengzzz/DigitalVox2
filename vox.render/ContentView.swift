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
    let asset: Assets

    let simpleMtl: SimpleMaterial
    let color = Color()
    @State private var r: Float = 1.0
    @State private var g: Float = 1.0
    @State private var b: Float = 1.0

    class CubeScript: Script {
        let speed: Float = 60

        override func onUpdate(_ deltaTime: Float) {
            let rotation = entity.transform.rotation
            rotation.elements += deltaTime * speed
            entity.transform.rotation = rotation
        }
    }

    init() {
        canvas = Canvas()
        engine = Engine(canvas, MetalRenderer())
        asset = Assets(engine)

        let scene = engine.sceneManager.activeScene
        _ = scene?.background.solidColor.setValue(r: 0.7, g: 0.9, b: 1, a: 1)
        let rootEntity = scene!.createRootEntity()

        // init camera
        let cameraEntity = rootEntity.createChild("camera")
        let _: Camera = cameraEntity.addComponent()
        cameraEntity.transform.setPosition(x: 10, y: 0, z: 0)
        cameraEntity.transform.lookAt(worldPosition: Vector3(0, 0, 0), worldUp: nil)
        let _: OrbitControl = cameraEntity.addComponent()

        simpleMtl = SimpleMaterial(engine)

        let cubeEntity = rootEntity.createChild()
        cubeEntity.transform.setPosition(x: 5, y: 0, z: 0)
        let cubeRenderer: MeshRenderer = cubeEntity.addComponent()
        let box = PrimitiveMesh.createCuboid(engine)
        cubeRenderer.mesh = box
        cubeRenderer.setMaterial(simpleMtl)
        let _: CubeScript = cubeEntity.addComponent()

        let assetEntity = rootEntity.createChild()
        let assetRenderer: MeshRenderer = assetEntity.addComponent()
        asset.load(name: "cottage1.obj")
        assetRenderer.mesh = asset.meshes[0]
        assetRenderer.setMaterial(0, simpleMtl)
        assetRenderer.setMaterial(1, simpleMtl)
        assetRenderer.setMaterial(2, simpleMtl)
        assetRenderer.setMaterial(3, simpleMtl)
    }

    var body: some View {
        NavigationView {
            VStack {
                Slider(
                        value: $r,
                        in: 0...1,
                        onEditingChanged: { editing in
                            _ = color.setValue(r: r, g: g, b: b, a: 1)
                            simpleMtl.baseColor = color
                        }
                )
                Text("Red: \(r)")

                Slider(
                        value: $g,
                        in: 0...1,
                        onEditingChanged: { editing in
                            _ = color.setValue(r: r, g: g, b: b, a: 1)
                            simpleMtl.baseColor = color
                        }
                )
                Text("Green: \(g)")

                Slider(
                        value: $b,
                        in: 0...1,
                        onEditingChanged: { editing in
                            _ = color.setValue(r: r, g: g, b: b, a: 1)
                            simpleMtl.baseColor = color
                        }
                )
                Text("Blue: \(b)")
            }

            EngineView(view: canvas)
        }.frame(minWidth: 700, minHeight: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

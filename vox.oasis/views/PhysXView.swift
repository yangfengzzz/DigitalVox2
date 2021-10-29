//
//  PhysXView.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

import SwiftUI

struct PhysXView: View {
    let canvas: Canvas
    let engine: Engine

    init() {
        canvas = Canvas()
        engine = Engine(canvas, MetalRenderer(), physics: LitePhysics.self)
        let scene = engine.sceneManager.activeScene
        let rootEntity = scene!.createRootEntity()

        // init camera
        let cameraEntity = rootEntity.createChild("camera")
        let _: Camera = cameraEntity.addComponent()
        cameraEntity.transform.setPosition(x: 10, y: 10, z: 10)
        let _: OrbitControl = cameraEntity.addComponent()

        // init point light
        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 0, y: 3, z: 0)
        let pointLight: PointLight = light.addComponent()
        pointLight.intensity = 0.3

        // create box test entity
        let cubeSize: Float = 2.0
        let boxEntity = rootEntity.createChild("BoxEntity")

        let boxMtl = BlinnPhongMaterial(engine)
        let boxRenderer: MeshRenderer = boxEntity.addComponent()
        _ = boxMtl.baseColor.setValue(r: 1, g: 1, b: 1, a: 1.0)
        boxRenderer.mesh = PrimitiveMesh.createCuboid(engine, cubeSize, cubeSize, cubeSize)
        boxRenderer.setMaterial(boxMtl)

        let boxCollider: StaticCollider = boxEntity.addComponent()
        let boxColliderShape = BoxColliderShape()
        boxColliderShape.setSize(cubeSize, cubeSize, cubeSize)
        boxCollider.addShape(boxColliderShape)
    }

    var body: some View {
        EngineView(view: canvas)
    }
}

struct PhysXView_Previews: PreviewProvider {
    static var previews: some View {
        SceneLoaderView()
    }
}

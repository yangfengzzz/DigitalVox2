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
    let gltfLoader: GLTFAssetsLoader
    let usdzLoader: USDZAssetsLoader

    init() {
        canvas = Canvas()
        engine = Engine(canvas, MetalRenderer())
        gltfLoader = GLTFAssetsLoader(engine)
        usdzLoader = USDZAssetsLoader(engine)

        let scene = engine.sceneManager.activeScene
        scene?.background.mode = .Sky
        scene?.background.sky.load("sky")
        
        let rootEntity = scene!.createRootEntity()

        let ambientLight = scene!.ambientLight
        ambientLight!.diffuseMode = .SphericalHarmonics
        let sh = SphericalHarmonics3()
        sh.setValueByArray(array: [
            0.2990323305130005, 0.46782827377319336, 0.6490488052368164, -0.08325951546430588, -0.1739923506975174,
            -0.3481740653514862, 0.12110518664121628, 0.10342133790254593, 0.0647989809513092, 0.013654923066496849,
            0.019375042989850044, 0.019014855846762657, -0.010647064074873924, -0.0158681683242321, -0.01735353097319603,
            -0.06292672455310822, -0.06085652485489845, -0.04486454278230667, 0.19867956638336182, 0.21928717195987701,
            0.19299709796905518, 0.01943504437804222, 0.03246982768177986, 0.04340629279613495, 0.13364768028259277,
            0.19655625522136688, 0.21748234331607819
        ])
        ambientLight!.diffuseSphericalHarmonics = sh
        ambientLight!.specularTexture = engine._whiteTexture2D

        let directLightNode = rootEntity.createChild("dir_light")
        let _: DirectLight = directLightNode.addComponent()
        directLightNode.transform.setPosition(x: 0, y: 0, z: 3)
        directLightNode.transform.lookAt(worldPosition: Vector3(0, 0, 0), worldUp: nil)

        let spotLightNode = rootEntity.createChild("spot_light")
        let _: SpotLight = spotLightNode.addComponent()
        spotLightNode.transform.setPosition(x: 0, y: 0, z: -3)
        spotLightNode.transform.lookAt(worldPosition: Vector3(0, 0, 0), worldUp: nil)

        // init camera
        let cameraEntity = rootEntity.createChild("camera")
        let _: Camera = cameraEntity.addComponent()
        cameraEntity.transform.setPosition(x: 10, y: 0, z: 0)
        cameraEntity.transform.lookAt(worldPosition: Vector3(0, 0, 0), worldUp: nil)
        let _: OrbitControl = cameraEntity.addComponent()

        usdzLoader.load(with: "Mando_Helmet.usdz") { entities in
            entities[0].transform.setPosition(x: 0, y: -2, z: 0)
            entities[0].transform.setScale(x: 0.1, y: 0.1, z: 0.1)
            rootEntity.addChild(entities[0])
        }
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

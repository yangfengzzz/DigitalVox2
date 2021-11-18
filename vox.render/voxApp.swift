//
//  DigitalVox2App.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import SwiftUI

@main
struct DigitalVox2App: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            //SceneLoaderView()
            PhysXRaycastView()
            //PhysXDynamicView()
            //SkeletonView()
            //SkeletonLoaderView()
            //CharacterView()
        }
    }
}

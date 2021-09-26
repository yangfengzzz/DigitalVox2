//
//  SceneFeature.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/26.
//

import Foundation

/// Scene feature plug-in.
protocol SceneFeature : AnyObject {
    /// Callback before every scene update.
    func preUpdate(scene: Scene)

    /// Callback after every scene update.
    func postUpdate(scene: Scene)

    /// Callback before scene rendering.
    func preRender(scene: Scene, camera: Camera)

    /// Callback after scene rendering.
    func postRender(scene: Scene, camera: Camera)

    /// Callback after the scene is destroyed.
    func destroy(scene: Scene)
}

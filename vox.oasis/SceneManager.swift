//
//  SceneManager.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/9.
//

import Foundation

/// Scene manager.
class SceneManager {
    var _activeScene: Scene?

    /// The activated scene.
    var activeScene: Scene? {
        get {
            _activeScene
        }
        set {
            let oldScene = _activeScene
            if (oldScene !== newValue) {
                oldScene?._processActive(false)
                newValue!._processActive(true)
                _activeScene = newValue
            }
        }
    }
}

extension SceneManager {
    /// Merge the source scene into the target scene.
    /// - Parameters:
    ///   - sourceScene: source scene
    ///   - destScene: target scene
    /// - Remark: the global information of destScene will be used after the merge, and the lightingMap information will be merged.
    func mergeScenes(_ sourceScene: Scene, _ destScene: Scene) {
        let oldRootEntities = sourceScene.rootEntities
        for i in 0..<oldRootEntities.count {
            destScene.addRootEntity(oldRootEntities[i])
        }
    }
}

//
//  SceneFeatureManager.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/26.
//

import Foundation

/// Manage a set of feature objects.
class SceneFeatureManager {
    private var _features: Array<SceneFeature> = []

    private var _objects: [Scene] = []

    /// Register a feature.
    func registerFeature(_ IFeature: SceneFeature) {
        // Search by type, avoid adding
        for i in 0..<_features.count {
            if (_features[i] === IFeature) {
                return
            }
        }

        // Add to global array
        _features.append(IFeature)

        // Add to existing scene
        let objectArray = _objects
        for i in 0..<objectArray.count {
            objectArray[i].features.append(IFeature)
        }
    }

    /// Add an feature with functional characteristics.
    /// - Parameter obj: Scene
    func addObject(_ obj: Scene) {
        obj.features = []
        for i in 0..<_features.count {
            obj.features.append(_features[i])
        }
        _objects.append(obj)
    }

    /// Find feature.
    /// - Parameters:
    ///   - obj: Scene
    ///   - IFeature: plug-in
    /// - Returns: plug-in
    func findFeature<T: SceneFeature>(_ obj: Scene) -> T? {
        let features = obj.features
        let count = features.count

        for i in 0..<count {
            let feature = features[i]

            if (feature is T) {
                return (feature as! T)
            }
        }
        return nil
    }
}

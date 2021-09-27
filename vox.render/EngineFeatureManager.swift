//
//  EngineFeatureManager.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

/// Manage a set of feature objects.
class EngineFeatureManager {
    private var _features: Array<EngineFeature> = []

    private var _objects: [Engine] = []

    /// Register a feature.
    func registerFeature(_ IFeature: EngineFeature) {
        // Search by type, avoid adding
        for i in 0..<_features.count {
            if (_features[i] === IFeature) {
                return
            }
        }

        // Add to global array
        _features.append(IFeature)

        // Add to existing Engine
        let objectArray = _objects
        for i in 0..<objectArray.count {
            objectArray[i].features.append(IFeature)
        }
    }

    /// Add an feature with functional characteristics.
    /// - Parameter obj: Engine
    func addObject(_ obj: Engine) {
        obj.features = []
        for i in 0..<_features.count {
            obj.features.append(_features[i])
        }
        _objects.append(obj)
    }

    /// Find feature.
    /// - Parameters:
    ///   - obj: Engine
    ///   - IFeature: plug-in
    /// - Returns: plug-in
    func findFeature<T: EngineFeature>(_ obj: Engine) -> T? {
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

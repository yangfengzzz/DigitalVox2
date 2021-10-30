//
//  AnimatorController.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// Store the data for Animator playback.
class AnimatorController {
    private var _updateFlagManager: UpdateFlagManager = UpdateFlagManager()
    private var _layers: [AnimatorControllerLayer] = []
    private var _layersMap: [String: AnimatorControllerLayer] = [:]

    /// The layers in the controller.
    var layers: [AnimatorControllerLayer] {
        get {
            _layers
        }
    }

    /// Get the layer by name.
    /// - Parameter name: The layer's name.
    /// - Returns: The Layer
    func findLayerByName(name: String) -> AnimatorControllerLayer? {
        return self._layersMap[name]
    }

    /// Add a layer to the controller.
    /// - Parameter layer: The layer to add
    func addLayer(layer: AnimatorControllerLayer) {
        self._layers.append(layer)
        self._layersMap[layer.name] = layer
        self._distributeUpdateFlag()
    }

    /// Remove a layer from the controller.
    /// - Parameter layerIndex: The index of the AnimatorLayer
    func removeLayer(layerIndex: Int) {
        let theLayer = self.layers[layerIndex]
        _layers.remove(at: layerIndex)
        _layersMap.removeValue(forKey: theLayer.name)
        _distributeUpdateFlag()
    }

    /// Clear layers.
    func clearLayers() {
        _layers = []
        _layersMap = [:]
        _distributeUpdateFlag()
    }

    internal func _registerChangeFlag() -> UpdateFlag {
        return self._updateFlagManager.register()
    }

    private func _distributeUpdateFlag() {
        self._updateFlagManager.distribute()
    }
}

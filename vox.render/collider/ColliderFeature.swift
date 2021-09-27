//
//  ColliderFeature.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

class ColliderFeature {
    var colliders: [Collider] = []

    /// Add a collider component.
    /// - Parameter collider: The collider component to add
    func attachCollider(_ collider: Collider) {
        colliders.append(collider)
    }

    /// Remove a collider component.
    /// - Parameter collider: The collider component to remove
    func detachCollider(_ collider: Collider) {
        colliders.removeAll { c in
            c === collider
        }
    }
}

extension ColliderFeature: SceneFeature {
    func preUpdate(_ scene: Scene) {
        fatalError()
    }

    func postUpdate(_ scene: Scene) {
        fatalError()
    }

    func preRender(_ scene: Scene, _ camera: Camera) {
        fatalError()
    }

    func postRender(_ scene: Scene, _ camera: Camera) {
        fatalError()
    }

    func destroy(_ scene: Scene) {
        fatalError()
    }
}

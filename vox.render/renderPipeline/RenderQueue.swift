//
//  RenderQueue.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Foundation

typealias Item = RenderElement

/// Render queue.
class RenderQueue {
    var items: [Item] = []

    init(_ engine: Engine) {
    }

    internal static func _compareFromNearToFar(a: Item, b: Item) -> Bool {
        ((a.material.renderQueueType.rawValue - b.material.renderQueueType.rawValue) != 0) ||
                (a.component._distanceForSort - b.component._distanceForSort) != 0 ||
                ((b.component._renderSortId - a.component._renderSortId) != 0)
    }

    internal static func _compareFromFarToNear(a: Item, b: Item) -> Bool {
        ((a.material.renderQueueType.rawValue - b.material.renderQueueType.rawValue) != 0) ||
                (b.component._distanceForSort - a.component._distanceForSort) != 0 ||
                ((b.component._renderSortId - a.component._renderSortId) != 0)
    }
}

extension RenderQueue {
    /// Push a render element.
    func pushPrimitive(element: RenderElement) {
        items.append(element)
    }

    func render(camera: Camera, replaceMaterial: Material, mask: Layer) {
    }

    /// Clear collection.
    func clear() {
        items = []
    }

    /// Destroy internal resources.
    func destroy() {
    }

    /// Sort the elements.
    func sort(compareFunc: (RenderElement, RenderElement) -> Bool) {
        items.sort(by: compareFunc)
    }
}

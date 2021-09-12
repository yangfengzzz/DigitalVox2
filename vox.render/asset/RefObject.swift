//
//  RefObject.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

/// The base class of assets, with reference counting capability.
class RefObject: EngineObject {
    /// Whether to ignore the garbage collection check, if it is true, it will not be affected by ResourceManager.gc().
    var isGCIgnored: Bool = false

    private var _refCount: Int = 0
    private var _destroyed: Bool = false

    /// Counted by valid references.
    var refCount: Int {
        get {
            _refCount
        }
    }

    /// Whether it has been destroyed.
    var destroyed: Bool {
        get {
            _destroyed
        }
    }
}

extension RefObject: IRefObject {
    func _getRefCount() -> Int {
        _refCount
    }

    func _addRefCount(_ count: Int) {
        _refCount += count
    }
}

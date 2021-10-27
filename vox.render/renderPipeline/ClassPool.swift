//
//  ClassPool.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Foundation

protocol EmptyInit : AnyObject {
    init()
}

/// Class pool utils.
class ClassPool<T: EmptyInit> {
    private var _elementPoolIndex: Int = 0
    private var _elementPool: [T] = []

    /// Get element from pool.
    func getFromPool() -> T {
        let index = _elementPoolIndex
        _elementPoolIndex += 1
        if (_elementPool.count == index) {
            let element = T()
            _elementPool.append(element)
            return element
        } else {
            return _elementPool[index]
        }
    }

    /// Reset pool.
    func resetPool() {
        _elementPoolIndex = 0
    }
}

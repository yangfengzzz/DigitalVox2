//
//  DisorderedArray.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// High-performance unordered array, delete uses exchange method to improve performance, internal capacity only increases.
class DisorderedArray<T:AnyObject> {
    var _elements: [T?] = []

    var length: Int = 0

    init(_ count: Int = 0) {
        _elements = [T?](repeating: nil, count: count)
    }

    func add(_ element: T) {
        if (length == _elements.count) {
            _elements.append(element)
        } else {
            _elements[length] = element
        }
        length += 1
    }

    func delete(_ element: T) {
        _elements.removeAll { e in
            if e == nil {
                return false
            } else {
                return e! === element
            }
        }
    }

    func get(_ index: Int) -> T? {
        if (index >= length) {
            fatalError("Index is out of range.")
        }
        return _elements[index]
    }

    /// The replaced item is used to reset its index.
    /// - Parameter index: index
    /// - Returns: The replaced item is used to reset its index.
    func deleteByIndex(_ index: Int) -> T? {
        var end: T? = nil
        let lastIndex = length - 1
        if (index != lastIndex) {
            end = _elements[lastIndex]
            _elements[index] = end!
        }
        length -= 1
        return end
    }

    func garbageCollection() {
        _elements.removeLast(length - _elements.count)
    }
}

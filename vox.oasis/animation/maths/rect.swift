//
//  rect.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Defines a rectangle by the integer coordinates of its lower-left and
// width-height.
struct RectInt {
    // Constructs a uninitialized rectangle.
    init() {
        left = 0
        bottom = 0
        width = 0
        height = 0
    }

    // Constructs a rectangle with the specified arguments.
    init(_ _left: Int, _ _bottom: Int, _ _width: Int, _ _height: Int) {
        left = _left
        bottom = _bottom
        width = _width
        height = _height
    }

    // Tests whether _x and _y coordinates are within rectangle bounds.
    func is_inside(_ _x: Int, _ _y: Int) -> Bool {
        return _x >= left && _x < left + width && _y >= bottom &&
                _y < bottom + height
    }

    // Gets the rectangle x coordinate of the right rectangle side.
    func right() -> Int {
        return left + width
    }

    // Gets the rectangle y coordinate of the top rectangle side.
    func top() -> Int {
        return bottom + height
    }

    // Specifies the x-coordinate of the lower side.
    var left: Int
    // Specifies the x-coordinate of the left side.
    var bottom: Int
    // Specifies the width of the rectangle.
    var width: Int
    // Specifies the height of the rectangle..
    var height: Int
}

// Defines a rectangle by the floating point coordinates of its lower-left
// and width-height.
struct RectFloat {
    // Constructs a uninitialized rectangle.
    init() {
        left = 0
        bottom = 0
        width = 0
        height = 0
    }

    // Constructs a rectangle with the specified arguments.
    init(_ _left: Float, _ _bottom: Float, _ _width: Float, _ _height: Float) {
        left = _left
        bottom = _bottom
        width = _width
        height = _height
    }

    // Tests whether _x and _y coordinates are within rectangle bounds
    func is_inside(_ _x: Float, _ _y: Float) -> Bool {
        return _x >= left && _x < left + width && _y >= bottom &&
                _y < bottom + height
    }

    // Gets the rectangle x coordinate of the right rectangle side.
    func right() -> Float {
        return left + width
    }

    // Gets the rectangle y coordinate of the top rectangle side.
    func top() -> Float {
        return bottom + height
    }

    // Specifies the x-coordinate of the lower side.
    var left: Float
    // Specifies the x-coordinate of the left side.
    var bottom: Float
    // Specifies the width of the rectangle.
    var width: Float
    // Specifies the height of the rectangle.
    var height: Float
}

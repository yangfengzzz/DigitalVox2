//
//  OrbitControl.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/14.
//

import MetalKit

class OrbitControl: Script {
    var camera: Entity
    var fov: Float = 45
    /// Target position.
    var target: Vector3 = Vector3()
    /// Up vector
    var up: Vector3 = Vector3(0, 1, 0)
    /// The minimum distance, the default is 0.1, should be greater than 0.
    var minDistance: Float = 0.1
    /// The maximum distance, the default is infinite, should be greater than the minimum distance
    var maxDistance: Float = Float.greatestFiniteMagnitude
    /// Minimum zoom speed, the default is 0.0.
    var minZoom: Float = 0.0
    /// Maximum zoom speed, the default is positive infinity.
    var maxZoom: Float = Float.greatestFiniteMagnitude
    /// Whether to enable camera damping, the default is true.
    var enableDamping: Bool = true
    /// Zoom damping parameter, default is 0.2 .
    var zoomFactor: Float = 0.2
    /// Whether to enable rotation, the default is true.
    var enableRotate: Bool = true
    /// Keyboard translation speed, the default is 7.0 .
    var keyPanSpeed: Float = 7.0
    /// The minimum radian in the vertical direction, the default is 0 radian, the value range is 0 - Math.PI.
    var minPolarAngle: Float = 0
    /// The maximum radian in the vertical direction, the default is Math.PI, and the value range is 0 - Math.PI.
    var maxPolarAngle: Float = Float.pi
    /// The minimum radian in the horizontal direction, the default is negative infinity.
    var minAzimuthAngle: Float = -Float.greatestFiniteMagnitude
    /// The maximum radian in the horizontal direction, the default is positive infinity.
    var maxAzimuthAngle: Float = Float.greatestFiniteMagnitude
    /// Whether to enable zoom, the default is true.
    var enableZoom: Bool = true
    /// Rotation damping parameter, default is 0.1 .
    var dampingFactor: Float = 0.1
    /// Camera zoom speed, the default is 1.0.
    var zoomSpeed: Float = 1.0
    /// Whether to enable translation, the default is true.
    var enablePan: Bool = true
    /// Whether to automatically rotate the camera, the default is false.
    var autoRotate: Bool = false
    /// The radian of automatic rotation per second.
    var autoRotateSpeed: Float = Float.pi
    /// Rotation speed, default is 1.0 .
    var rotateSpeed: Float = 1.0
    /// Whether to enable keyboard.
    var enableKeys: Bool = false

    var touchFingers: (ORBIT: Int, ZOOM: Int, PAN: Int)
    var STATE: (
            TOUCH_ROTATE: Int,
            ROTATE: Int,
            TOUCH_PAN: Int,
            ZOOM: Int,
            NONE: Int,
            PAN: Int,
            TOUCH_ZOOM: Int
    )

    private var _position: Vector3 = Vector3()
    private var _offset: Vector3 = Vector3()
    private var _spherical: Spherical = Spherical()
    private var _sphericalDelta: Spherical = Spherical()
    private var _sphericalDump: Spherical = Spherical()
    private var _zoomFrag: Float = 0
    private var _scale: Float = 1
    private var _panOffset: Vector3 = Vector3()
    private var _isMouseUp: Bool = true
    private var _vPan: Vector3 = Vector3()
    private var _state: Int
    private var _rotateStart: Vector2 = Vector2()
    private var _rotateEnd: Vector2 = Vector2()
    private var _rotateDelta: Vector2 = Vector2()
    private var _panStart: Vector2 = Vector2()
    private var _panEnd: Vector2 = Vector2()
    private var _panDelta: Vector2 = Vector2()
    private var _zoomStart: Vector2 = Vector2()
    private var _zoomEnd: Vector2 = Vector2()
    private var _zoomDelta: Vector2 = Vector2()

    required init(_ entity: Entity) {
        camera = entity

        touchFingers = (
                ORBIT: 1,
                ZOOM: 2,
                PAN: 3
        )

        STATE = (
                TOUCH_ROTATE: 3,
                ROTATE: 0,
                TOUCH_PAN: 5,
                ZOOM: 1,
                NONE: -1,
                PAN: 2,
                TOUCH_ZOOM: 4
        )
        _state = STATE.NONE

        super.init(entity)
    }

    override func onUpdate(_ dtime: Float) {
        if (!enabled) {
            return
        }

        let position: Vector3 = camera.transform.position
        position.cloneTo(target: _offset)
        _ = _offset.subtract(right: target)
        _ = _spherical.setFromVec3(v3: _offset)

        if (autoRotate && _state == STATE.NONE) {
            rotateLeft(radian: getAutoRotationAngle(dtime: dtime))
        }

        _spherical.theta += _sphericalDelta.theta
        _spherical.phi += _sphericalDelta.phi

        _spherical.theta = max(minAzimuthAngle, min(maxAzimuthAngle, _spherical.theta))
        _spherical.phi = max(minPolarAngle, min(maxPolarAngle, _spherical.phi))
        _ = _spherical.makeSafe()

        if (_scale != 1) {
            _zoomFrag = _spherical.radius * (_scale - 1)
        }

        _spherical.radius += _zoomFrag
        _spherical.radius = max(minDistance, min(maxDistance, _spherical.radius))

        _ = target.add(right: _panOffset)
        _ = _spherical.setToVec3(v3: _offset)
        target.cloneTo(target: _position)
        _ = _position.add(right: _offset)

        camera.transform.position = _position
        camera.transform.lookAt(worldPosition: target, worldUp: up)

        if (enableDamping == true) {
            _sphericalDump.theta *= 1 - dampingFactor
            _sphericalDump.phi *= 1 - dampingFactor
            _zoomFrag *= 1 - zoomFactor

            if (_isMouseUp) {
                _sphericalDelta.theta = _sphericalDump.theta
                _sphericalDelta.phi = _sphericalDump.phi
            } else {
                _ = _sphericalDelta.set(radius: 0, phi: 0, theta: 0)
            }
        } else {
            _ = _sphericalDelta.set(radius: 0, phi: 0, theta: 0)
            _zoomFrag = 0
        }

        _scale = 1
        _ = _panOffset.setValue(x: 0, y: 0, z: 0)
    }

    /// Get the radian of automatic rotation.
    func getAutoRotationAngle(dtime: Float) -> Float {
        (autoRotateSpeed / 1000) * dtime
    }

    /// Get zoom value.
    func getZoomScale() -> Float {
        pow(0.95, zoomSpeed)
    }

    /// Rotate to the left by a certain radian.
    /// - Parameter radian: Radian value of rotation
    func rotateLeft(radian: Float) {
        _sphericalDelta.theta -= radian
        if (enableDamping) {
            _sphericalDump.theta = -radian
        }
    }

    /// Rotate to the right by a certain radian.
    /// - Parameter radian: Radian value of rotation
    func rotateUp(radian: Float) {
        _sphericalDelta.phi -= radian
        if (enableDamping) {
            _sphericalDump.phi = -radian
        }
    }

    /// Pan left.
    func panLeft(distance: Float, worldMatrix: Matrix) {
        let e = worldMatrix.elements
        _ = _vPan.setValue(x: e.columns.0[0], y: e.columns.0[1], z: e.columns.0[2])
        _ = _vPan.scale(s: distance)
        _ = _panOffset.add(right: _vPan)
    }

    /// Pan right.
    func panUp(distance: Float, worldMatrix: Matrix) {
        let e = worldMatrix.elements
        _ = _vPan.setValue(x: e.columns.1[0], y: e.columns.1[1], z: e.columns.1[2])
        _ = _vPan.scale(s: distance)
        _ = _panOffset.add(right: _vPan)
    }

    /// Pan.
    /// - Parameters:
    ///   - deltaX: The amount of translation from the screen distance in the x direction
    ///   - deltaY: The amount of translation from the screen distance in the y direction
    func pan(deltaX: Float, deltaY: Float) {
        // perspective only
        let position: Vector3 = camera.transform.position
        position.cloneTo(target: _vPan)
        _ = _vPan.subtract(right: target)
        var targetDistance = _vPan.length()

        targetDistance *= (fov / 2) * (Float.pi / 180)

        let clientWidth = Float(engine.canvas.bounds.width)
        let clientHeight = Float(engine.canvas.bounds.height)

        panLeft(distance: -2 * deltaX * (targetDistance / clientWidth), worldMatrix: camera.transform.worldMatrix)
        panUp(distance: 2 * deltaY * (targetDistance / clientHeight), worldMatrix: camera.transform.worldMatrix)
    }

    /// Zoom in.
    func zoomIn(zoomScale: Float) {
        // perspective only
        _scale *= zoomScale
    }

    /// Zoom out.
    func zoomOut(zoomScale: Float) {
        // perspective only
        _scale /= zoomScale
    }

    /// Rotation parameter update when touch is dropped.
    func handleTouchStartRotate(event: UITouch) {
        let loc = event.location(in: nil)
        _ = _rotateStart.setValue(x: Float(loc.x), y: Float(loc.y))
    }

    ///  Zoom parameter update when touch down.
    func handleTouchStartZoom(event: UITouch) {
        let loc = event.location(in: nil)
        let preLoc = event.previousLocation(in: nil)

        let dx = loc.x - preLoc.x
        let dy = loc.y - preLoc.y

        let distance = sqrt(dx * dx + dy * dy)

        _ = _zoomStart.setValue(x: 0, y: Float(distance))
    }

    /// Update the translation parameter when touch down.
    func handleTouchStartPan(event: UITouch) {
        let loc = event.location(in: nil)
        _ = _panStart.setValue(x: Float(loc.x), y: Float(loc.y))
    }

    /// Rotation parameter update when touch to move.
    func handleTouchMoveRotate(event: UITouch) {
        let loc = event.location(in: nil)
        _ = _rotateEnd.setValue(x: Float(loc.x), y: Float(loc.y))
        Vector2.subtract(left: _rotateEnd, right: _rotateStart, out: _rotateDelta)

        let clientWidth = Float(engine.canvas.bounds.width)
        let clientHeight = Float(engine.canvas.bounds.height)

        rotateLeft(radian: ((2 * Float.pi * _rotateDelta.x) / clientWidth) * rotateSpeed)
        rotateUp(radian: ((2 * Float.pi * _rotateDelta.y) / clientHeight) * rotateSpeed)

        _rotateEnd.cloneTo(target: _rotateStart)
    }

    /// Zoom parameter update when touch to move.
    func handleTouchMoveZoom(event: UITouch) {
        let loc = event.location(in: nil)
        let preLoc = event.previousLocation(in: nil)

        let dx = loc.x - preLoc.x
        let dy = loc.y - preLoc.y

        let distance = sqrt(dx * dx + dy * dy)

        _ = _zoomEnd.setValue(x: 0, y: Float(distance))

        Vector2.subtract(left: _zoomEnd, right: _zoomStart, out: _zoomDelta)

        if (_zoomDelta.y > 0) {
            zoomIn(zoomScale: getZoomScale())
        } else if (_zoomDelta.y < 0) {
            zoomOut(zoomScale: getZoomScale())
        }

        _zoomEnd.cloneTo(target: _zoomStart)
    }

    /// Pan parameter update when touch moves.
    func handleTouchMovePan(event: UITouch) {
        let loc = event.location(in: nil)
        _ = _panEnd.setValue(x: Float(loc.x), y: Float(loc.y))

        Vector2.subtract(left: _panEnd, right: _panStart, out: _panDelta)

        pan(deltaX: _panDelta.x, deltaY: _panDelta.y)

        _panEnd.cloneTo(target: _panStart)
    }

    /// Total handling of touch start events.
    func onTouchStart(event: UITouch) {
        if (enabled == false) {
            return
        }

        _isMouseUp = false

        switch (event.tapCount) {
        case touchFingers.ORBIT:
            if (enableRotate == false) {
                return
            }

            handleTouchStartRotate(event: event)
            _state = STATE.TOUCH_ROTATE

            break

        case touchFingers.ZOOM:
            if (enableZoom == false) {
                return
            }

            handleTouchStartZoom(event: event)
            _state = STATE.TOUCH_ZOOM

            break

        case touchFingers.PAN:
            if (enablePan == false) {
                return
            }

            handleTouchStartPan(event: event)
            _state = STATE.TOUCH_PAN

            break

        default:
            _state = STATE.NONE
        }
    }

    /// Total handling of touch movement events.
    func onTouchMove(event: UITouch) {
        if (enabled == false) {
            return
        }

        switch (event.tapCount) {
        case touchFingers.ORBIT:
            if (enableRotate == false) {
                return
            }
            if (_state != STATE.TOUCH_ROTATE) {
                return
            }
            handleTouchMoveRotate(event: event)

            break

        case touchFingers.ZOOM:
            if (enableZoom == false) {
                return
            }
            if (_state != STATE.TOUCH_ZOOM) {
                return
            }
            handleTouchMoveZoom(event: event)

            break

        case touchFingers.PAN:
            if (enablePan == false) {
                return
            }
            if (_state != STATE.TOUCH_PAN) {
                return
            }
            handleTouchMovePan(event: event)

            break

        default:
            _state = STATE.NONE
        }
    }

    /// Total handling of touch end events.
    func onTouchEnd() {
        if (enabled == false) {
            return
        }

        _isMouseUp = true
        _state = STATE.NONE
    }

}

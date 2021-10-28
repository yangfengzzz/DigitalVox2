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
    var enableKeys: Bool = true

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

    func bindEvent() {
        if !engine._inputManager.directionKeysDown.isEmpty {
            engine._inputManager.directionKeysDown.forEach { touch in
                onKeyDown(touch)
            }
        }

        if !engine._inputManager.beginEvent.isEmpty {
            engine._inputManager.beginEvent.forEach { touch in
                onMouseDown(touch)
            }
            engine._inputManager.beginEvent = []
        }

        if !engine._inputManager.movedEvent.isEmpty {
            engine._inputManager.movedEvent.forEach { touch in
                onMouseMove(touch)
            }
            engine._inputManager.movedEvent = []
        }

        if !engine._inputManager.endedEvent.isEmpty {
            engine._inputManager.endedEvent.forEach { touch in
                onMouseUp()
            }
            engine._inputManager.endedEvent = []
        }

        if !engine._inputManager.zoom.isEmpty {
            engine._inputManager.zoom.forEach { _zoomDelta in
                if (_zoomDelta > 0) {
                    zoomIn(getZoomScale())
                } else if (_zoomDelta < 0) {
                    zoomOut(getZoomScale())
                }
            }
            engine._inputManager.zoom = []
        }
    }

    override func onUpdate(_ dtime: Float) {
        if (!enabled) {
            return
        }

        bindEvent()

        let position: Vector3 = camera.transform.position
        position.cloneTo(target: _offset)
        _ = _offset.subtract(right: target)
        _ = _spherical.setFromVec3(v3: _offset)

        if (autoRotate && _state == STATE.NONE) {
            rotateLeft(getAutoRotationAngle(dtime))
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
    func getAutoRotationAngle(_ dtime: Float) -> Float {
        (autoRotateSpeed / 1000) * dtime
    }

    /// Get zoom value.
    func getZoomScale() -> Float {
        pow(0.95, zoomSpeed)
    }

    /// Rotate to the left by a certain radian.
    /// - Parameter radian: Radian value of rotation
    func rotateLeft(_ radian: Float) {
        _sphericalDelta.theta -= radian
        if (enableDamping) {
            _sphericalDump.theta = -radian
        }
    }

    /// Rotate to the right by a certain radian.
    /// - Parameter radian: Radian value of rotation
    func rotateUp(_ radian: Float) {
        _sphericalDelta.phi -= radian
        if (enableDamping) {
            _sphericalDump.phi = -radian
        }
    }

    /// Pan left.
    func panLeft(_ distance: Float, _ worldMatrix: Matrix) {
        let e = worldMatrix.elements
        _ = _vPan.setValue(x: e.columns.0[0], y: e.columns.0[1], z: e.columns.0[2])
        _ = _vPan.scale(s: distance)
        _ = _panOffset.add(right: _vPan)
    }

    /// Pan right.
    func panUp(_ distance: Float, _ worldMatrix: Matrix) {
        let e = worldMatrix.elements
        _ = _vPan.setValue(x: e.columns.1[0], y: e.columns.1[1], z: e.columns.1[2])
        _ = _vPan.scale(s: distance)
        _ = _panOffset.add(right: _vPan)
    }

    /// Pan.
    /// - Parameters:
    ///   - deltaX: The amount of translation from the screen distance in the x direction
    ///   - deltaY: The amount of translation from the screen distance in the y direction
    func pan(_ deltaX: Float, _ deltaY: Float) {
        // perspective only
        let position: Vector3 = camera.transform.position
        position.cloneTo(target: _vPan)
        _ = _vPan.subtract(right: target)
        var targetDistance = _vPan.length()

        targetDistance *= (fov / 2) * (Float.pi / 180)

        let clientWidth = Float(engine.canvas.bounds.width)
        let clientHeight = Float(engine.canvas.bounds.height)

        panLeft(-2 * deltaX * (targetDistance / clientWidth), camera.transform.worldMatrix)
        panUp(2 * deltaY * (targetDistance / clientHeight), camera.transform.worldMatrix)
    }

    /// Zoom in.
    func zoomIn(_ zoomScale: Float) {
        // perspective only
        _scale *= zoomScale
    }

    /// Zoom out.
    func zoomOut(_ zoomScale: Float) {
        // perspective only
        _scale /= zoomScale
    }
}

//MARK: - Mouse Event
extension OrbitControl {
    /// Rotation parameter update on mouse click.
    func handleMouseDownRotate(_ event: NSEvent) {
    }

    /// Zoom parameter update on mouse click.
    func handleMouseDownZoom(_ event: NSEvent) {
    }

    /// Pan parameter update on mouse click.
    func handleMouseDownPan(_ event: NSEvent) {
    }

    /// Rotation parameter update when the mouse moves.
    func handleMouseMoveRotate(_ event: NSEvent) {
        rotateLeft(2 * Float.pi * (Float(event.deltaX) / Float(event.window!.contentView!.bounds.width)) * rotateSpeed)
        rotateUp(2 * Float.pi * (Float(event.deltaY) / Float(event.window!.contentView!.bounds.height)) * rotateSpeed)
    }

    /// Zoom parameters update when the mouse moves.
    func handleMouseMoveZoom(_ event: NSEvent) {
        if (event.deltaY > 0) {
            zoomOut(getZoomScale())
        } else if (event.deltaY < 0) {
            zoomIn(getZoomScale())
        }
    }

    /// Pan parameters update when the mouse moves.
    func handleMouseMovePan(_ event: NSEvent) {
        pan(Float(event.deltaX), Float(event.deltaY))
    }

    /// Zoom parameter update when the mouse wheel is scrolled.
    func handleMouseWheel(_ event: NSEvent) {
        if (event.deltaY < 0) {
            zoomIn(getZoomScale())
        } else if (event.deltaY > 0) {
            zoomOut(getZoomScale())
        }
    }

    /// Pan parameter update when keyboard is pressed.
    func handleKeyDown(_ event: KeyboardControl) {
        switch (event) {
        case .up:
            pan(0, keyPanSpeed)
            break
        case .down:
            pan(0, -keyPanSpeed)
            break
        case .left:
            pan(keyPanSpeed, 0)
            break
        case .right:
            pan(-keyPanSpeed, 0)
            break
        default:
            break
        }
    }
}

extension OrbitControl {
    /// Total handling of mouse down events.
    func onMouseDown(_ event: NSEvent) {
        if (enabled == false) {
            return
        }

        _isMouseUp = false

        switch (event.type) {
        case .leftMouseDown:
            if (enableRotate == false) {
                return
            }

            handleMouseDownRotate(event)
            _state = STATE.ROTATE
            break

        case .scrollWheel:
            if (enableZoom == false) {
                return
            }

            handleMouseDownZoom(event)
            _state = STATE.ZOOM
            break

        case .rightMouseDown:
            if (enablePan == false) {
                return
            }

            handleMouseDownPan(event)
            _state = STATE.PAN
            break
        default:
            break
        }
    }

    // Total handling of mouse movement events.
    func onMouseMove(_ event: NSEvent) {
        if (enabled == false) {
            return
        }

        switch (_state) {
        case STATE.ROTATE:
            if (enableRotate == false) {
                return
            }

            handleMouseMoveRotate(event)
            break

        case STATE.ZOOM:
            if (enableZoom == false) {
                return
            }

            handleMouseMoveZoom(event)
            break

        case STATE.PAN:
            if (enablePan == false) {
                return
            }

            handleMouseMovePan(event)
            break
        default:
            break
        }
    }

    /// Total handling of mouse up events.
    func onMouseUp() {
        if (enabled == false) {
            return
        }

        _isMouseUp = true

        _state = STATE.NONE
    }

    /// Total handling of mouse wheel events.
    func onMouseWheel(_ event: NSEvent) {
        if (
                   enabled == false ||
                           enableZoom == false ||
                           (_state != STATE.NONE && _state != STATE.ROTATE)
           ) {
            return
        }
        handleMouseWheel(event)
    }

    /// Total handling of keyboard down events.
    func onKeyDown(_ event: KeyboardControl) {
        if (enabled == false || enableKeys == false || enablePan == false) {
            return
        }

        handleKeyDown(event)
    }

}

//MARK:- Mouse Event
extension OrbitControl {
}

//
//  Canvas.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit

class Canvas: MTKView {
    var inputManager: InputManager?
    // for mouse movement
    var trackingArea: NSTrackingArea?

    init() {
        super.init(frame: .zero, device: nil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Canvas {
    override func updateTrackingAreas() {
        guard let window = NSApplication.shared.mainWindow else {
            return
        }
        window.acceptsMouseMovedEvents = true
        CGDisplayHideCursor(CGMainDisplayID())

        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }

        let options: NSTrackingArea.Options = [.activeAlways, .inVisibleRect, .mouseMoved]
        trackingArea = NSTrackingArea(rect: self.bounds, options: options,
                owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func keyDown(with event: NSEvent) {
        guard let key = KeyboardControl(rawValue: event.keyCode) else {
          return
        }
        let state: InputState = event.isARepeat ? .continued : .began
        inputManager?.processEvent(key: key, state: state)
    }

    override func keyUp(with event: NSEvent) {
        guard let key = KeyboardControl(rawValue: event.keyCode) else {
          return
        }
        inputManager?.processEvent(key: key, state: .ended)
    }

    override func mouseDown(with event: NSEvent) {
        inputManager?.processEvent(state: .began, event: event)
    }

    override func mouseUp(with event: NSEvent) {
        inputManager?.processEvent(state: .ended, event: event)
    }

    override func mouseDragged(with event: NSEvent) {
        inputManager?.processEvent(state: .moved, event: event)
    }

    override func rightMouseDown(with event: NSEvent) {
        inputManager?.processEvent(state: .began, event: event)
    }

    override func rightMouseUp(with event: NSEvent) {
        inputManager?.processEvent(state: .ended, event: event)
    }

    override func rightMouseDragged(with event: NSEvent) {
        inputManager?.processEvent(state: .moved, event: event)
    }

    override func scrollWheel(with event: NSEvent) {
        inputManager?.zoomUsing(delta: event.deltaY)
    }
}

extension Canvas {
    func registerGesture() {
    }
}

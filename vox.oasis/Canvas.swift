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

    typealias EventHandler = (NSEvent) -> Void
    var mouseDownEvents: [EventHandler] = []
    var mouseUpEvents: [EventHandler] = []
    var rightMouseDownEvents: [EventHandler] = []
    var rightMouseUpEvents: [EventHandler] = []

    typealias KeyboardHandler = (KeyboardControl) -> Void
    var keyboardDownEvents: [KeyboardHandler] = []

    var gui = IMGUI()
    var guiEvents: [() -> Void] = []

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
//        CGDisplayHideCursor(CGMainDisplayID())

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

    //MARK: - KeyBoard
    func registerKeyDown(_ handler: @escaping KeyboardHandler) {
        keyboardDownEvents.append(handler)
    }

    override func keyDown(with event: NSEvent) {
        guard let key = KeyboardControl(rawValue: event.keyCode) else {
            return
        }

        keyboardDownEvents.forEach { handler in
            handler(key)
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

    //MARK: - Mouse
    func registerMouseDown(_ handler: @escaping EventHandler) {
        mouseDownEvents.append(handler)
    }

    override func mouseDown(with event: NSEvent) {
        mouseDownEvents.forEach { handler in
            handler(event)
        }
        gui.handle(event, self)
        inputManager?.processEvent(state: .began, event: event)
    }

    override func mouseUp(with event: NSEvent) {
        gui.handle(event, self)
        inputManager?.processEvent(state: .ended, event: event)
    }

    override func mouseDragged(with event: NSEvent) {
        gui.handle(event, self)
        inputManager?.processEvent(state: .moved, event: event)
    }

    override func mouseMoved(with event: NSEvent) {
        gui.handle(event, self)
    }

    override func rightMouseDown(with event: NSEvent) {
        gui.handle(event, self)
        inputManager?.processEvent(state: .began, event: event)
    }

    override func rightMouseUp(with event: NSEvent) {
        gui.handle(event, self)
        inputManager?.processEvent(state: .ended, event: event)
    }

    override func rightMouseDragged(with event: NSEvent) {
        gui.handle(event, self)
        inputManager?.processEvent(state: .moved, event: event)
    }

    override func otherMouseDown(with event: NSEvent) {
        gui.handle(event, self)
    }

    override func otherMouseUp(with event: NSEvent) {
        gui.handle(event, self)
    }

    override func otherMouseDragged(with event: NSEvent) {
        gui.handle(event, self)
    }

    override func scrollWheel(with event: NSEvent) {
        gui.handle(event, self)
        inputManager?.zoomUsing(delta: event.deltaY)
    }

    //MARK: - GUI
    func registerGUI(_ handler: @escaping () -> Void) {
        guiEvents.append(handler)
    }
}

extension Canvas {
    func registerGesture() {
    }
}

//
//  Canvas.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit

class Canvas: MTKView {
    var inputManager: InputManager?
    static var previousScale: CGFloat = 1

    init() {
        super.init(frame: .zero, device: nil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Canvas {
    override func didMoveToWindow() {
        super.didMoveToWindow()
    }

    func registerGesture() {
        let pinch = UIPinchGestureRecognizer(target: self,
                action: #selector(handlePinch(gesture:)))
        addGestureRecognizer(pinch);
    }

    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        inputManager?.zoomUsing(delta: gesture.scale - Canvas.previousScale)
        Canvas.previousScale = gesture.scale
        if gesture.state == .ended {
            Canvas.previousScale = 1
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        inputManager?.processEvent(touches: touches, state: .began, event: event)
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        inputManager?.processEvent(touches: touches, state: .moved, event: event)
        super.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        inputManager?.processEvent(touches: touches, state: .ended, event: event)
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>,
                                   with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
}

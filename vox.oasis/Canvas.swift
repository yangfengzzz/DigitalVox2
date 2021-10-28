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
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
    }

    func registerGesture() {
        let pinch = NSMagnificationGestureRecognizer(target: self,
                action: #selector(handlePinch(gesture:)))
        addGestureRecognizer(pinch);
    }

    @objc func handlePinch(gesture: NSMagnificationGestureRecognizer) {
        inputManager?.zoomUsing(delta: gesture.magnification - Canvas.previousScale)
        Canvas.previousScale = gesture.magnification
        if gesture.state == .ended {
            Canvas.previousScale = 1
        }
    }
    
    override func touchesBegan(with event: NSEvent) {
        inputManager?.processEvent(state: .began, event: event)
        super.touchesBegan(with: event)
    }
    
    override func touchesMoved(with event: NSEvent) {
        inputManager?.processEvent(state: .moved, event: event)
        super.touchesMoved(with: event)
    }
    
    override func touchesEnded(with event: NSEvent) {
        inputManager?.processEvent(state: .ended, event: event)
        super.touchesEnded(with: event)
    }
    
    override func touchesCancelled(with event: NSEvent) {
        super.touchesCancelled(with: event)
    }
}

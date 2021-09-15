//
//  Canvas.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit

class Canvas: MTKView {
    var inputMananger: InputMananger?
    var isTouched = false

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
        let pan = UIPanGestureRecognizer(target: self,
                action: #selector(handlePan(gesture:)))
        addGestureRecognizer(pan);

        let pinch = UIPinchGestureRecognizer(target: self,
                action: #selector(handlePinch(gesture:)))
        addGestureRecognizer(pinch);
    }

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let _ = float2(Float(gesture.translation(in: gesture.view).x),
                Float(gesture.translation(in: gesture.view).y))
        gesture.setTranslation(.zero, in: gesture.view)
    }

    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {}

    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        isTouched = true
        inputMananger?.processEvent(touches: touches, state: .began, event: event)
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        if isTouched {
            inputMananger?.processEvent(touches: touches, state: .moved, event: event)
        }
        super.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        if isTouched {
            inputMananger?.processEvent(touches: touches, state: .ended, event: event)
        }
        isTouched = false
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>,
                                   with event: UIEvent?) {
        isTouched = false
        super.touchesCancelled(touches, with: event)
    }
}

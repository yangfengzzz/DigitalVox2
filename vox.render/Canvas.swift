//
//  ControllerView.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit

class Canvas: MTKView {
    var inputController: InputController?
    var motionController = MotionController()
    var isTouched = false
    static var previousScale: CGFloat = 1
}

extension Canvas {
    override func didMoveToWindow() {
        super.didMoveToWindow()
        motionController.motionClosure = {
            motion, error in
            guard let motion = motion else {
                return
            }
            let gravityAngle = atan2(motion.gravity.y, motion.gravity.x)
            let sign: Float = abs(gravityAngle) <= 1 ? -1 : 1
            let sensitivity: Float = 60
            self.inputController?.currentTurnSpeed = sign * Float(motion.attitude.pitch) * sensitivity
            self.inputController?.currentPitch = sign * Float(motion.attitude.pitch)
        }
        motionController.setupCoreMotion()
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
        let translation = float2(Float(gesture.translation(in: gesture.view).x),
                Float(gesture.translation(in: gesture.view).y))
        inputController?.rotateUsing(translation: translation)
        gesture.setTranslation(.zero, in: gesture.view)
    }

    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        let sensitivity: Float = 0.8
        inputController?.zoomUsing(delta: gesture.scale - Canvas.previousScale,
                sensitivity: sensitivity)
        Canvas.previousScale = gesture.scale
        if gesture.state == .ended {
            Canvas.previousScale = 1
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        isTouched = true
        inputController?.processEvent(touches: touches, state: .began, event: event)
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        if isTouched {
            inputController?.processEvent(touches: touches, state: .moved, event: event)
        }
        super.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        if isTouched {
            inputController?.processEvent(touches: touches, state: .ended, event: event)
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

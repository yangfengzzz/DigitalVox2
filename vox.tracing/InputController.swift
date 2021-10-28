//
//  InputController.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit

class InputController {
//    var player: Node?
    var currentSpeed: Float = 0
    
    
    var rotationSpeed: Float = 4.0
    var translationSpeed: Float = 0.05 {
        didSet {
            if translationSpeed > maxSpeed {
                translationSpeed = maxSpeed
            }
        }
    }
    let maxSpeed: Float = 0.1
    var currentTurnSpeed: Float = 0
    var currentPitch: Float = 0
    var forward = false
    
    // conforming to macOS
    var keyboardDelegate: Any?
}

extension InputController {
    func zoomUsing(delta: CGFloat, sensitivity: Float) {
//        player?.position.z += Float(delta) * sensitivity
    }
    
    func rotateUsing(translation: SIMD2<Float>) {
//        let sensitivity: Float = 0.01
//        player?.rotation.x += Float(translation.y) * sensitivity
//        player?.rotation.y -= Float(translation.x) * sensitivity
    }
}

extension InputController {
    func processEvent(touches: Set<UITouch>, state: InputState, event: UIEvent?) {
        switch state {
        case .began, .moved:
            forward = false
        case .ended:
            forward = false
        default:
            break
        }
    }
    public func updatePlayer(deltaTime: Float) {
//        guard let player = player else { return }
//        let translationSpeed = deltaTime * self.translationSpeed
//        currentSpeed = forward ? currentSpeed + translationSpeed :
//            currentSpeed - translationSpeed * 2
//        if currentSpeed < 0 {
//            currentSpeed = 0
//        } else if currentSpeed > maxSpeed {
//            currentSpeed = maxSpeed
//        }
//        player.rotation.y += currentPitch * deltaTime * rotationSpeed
//        player.position.x += currentSpeed * sin(player.rotation.y)
//        player.position.z += currentSpeed * cos(player.rotation.y)
    }
}

enum InputState {
    case began, moved, ended, cancelled, continued
}

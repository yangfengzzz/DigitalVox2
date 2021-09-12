//
//  InputController.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit

class InputController {
    var player: Entity?
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
        let position = player!.transform.position
        position.z += Float(delta) * sensitivity
        player!.transform.position = position
    }

    func rotateUsing(translation: float2) {
        let sensitivity: Float = 0.01
        let rotation = player!.transform.rotation
        rotation.x += Float(translation.y) * sensitivity
        rotation.y -= Float(translation.x) * sensitivity
        player!.transform.rotation = rotation
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
        guard let player = player else {
            return
        }
        let translationSpeed = deltaTime * self.translationSpeed
        currentSpeed = forward ? currentSpeed + translationSpeed :
                currentSpeed - translationSpeed * 2
        if currentSpeed < 0 {
            currentSpeed = 0
        } else if currentSpeed > maxSpeed {
            currentSpeed = maxSpeed
        }
        let rotation = player.transform.rotation
        rotation.y += currentPitch * deltaTime * rotationSpeed
        player.transform.rotation = rotation
        
        let position = player.transform.position
        position.x += currentSpeed * sin(player.transform.rotation.y)
        position.z += currentSpeed * cos(player.transform.rotation.y)
        player.transform.position = position
    }
}

enum InputState {
    case began, moved, ended, cancelled, continued
}

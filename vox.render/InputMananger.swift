//
//  InputController.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit

class InputMananger {
    var beginEvent: Set<UITouch> = []
    var movedEvent: Set<UITouch> = []
    var endedEvent: Set<UITouch> = []
}

extension InputMananger {
    func processEvent(touches: Set<UITouch>, state: InputState, event: UIEvent?) {
        beginEvent = []
        movedEvent = []
        endedEvent = []

        switch state {
        case .began:
            beginEvent = beginEvent.union(touches)
        case .moved:
            movedEvent = movedEvent.union(touches)
        case .ended:
            endedEvent = endedEvent.union(touches)
        default:
            break
        }
    }
}

enum InputState {
    case began, moved, ended, cancelled, continued
}

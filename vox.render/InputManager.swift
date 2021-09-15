//
//  InputMananger.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit

class InputManager {
    var beginEvent: Set<UITouch> = []
    var movedEvent: Set<UITouch> = []
    var endedEvent: Set<UITouch> = []
    
    var zoom:[CGFloat] = []
}

extension InputManager {
    func processEvent(touches: Set<UITouch>, state: InputState, event: UIEvent?) {
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
    
    func zoomUsing(delta: CGFloat) {
        zoom.append(delta)
    }
}

enum InputState {
    case began, moved, ended, cancelled, continued
}

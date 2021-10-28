//
//  InputMananger.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit

class InputManager {
    var beginEvent: Set<NSEvent> = []
    var movedEvent: Set<NSEvent> = []
    var endedEvent: Set<NSEvent> = []
    
    var zoom:[CGFloat] = []
}

extension InputManager {
    func processEvent(state: InputState, event: NSEvent) {
        switch state {
        case .began:
            _ = beginEvent.insert(event)
        case .moved:
            _ = movedEvent.insert(event)
        case .ended:
            _ = endedEvent.insert(event)
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

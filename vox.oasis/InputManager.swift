//
//  InputMananger.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import MetalKit

class InputManager {
    var directionKeysDown: Set<KeyboardControl> = []
    
    var beginEvent: Set<NSEvent> = []
    var movedEvent: Set<NSEvent> = []
    var endedEvent: Set<NSEvent> = []
    
    var zoom:[CGFloat] = []
}

extension InputManager {
    func processEvent(key inKey: KeyboardControl, state: InputState) {
      if state == .began {
        directionKeysDown.insert(inKey)
      }
      if state == .ended {
        directionKeysDown.remove(inKey)
      }
    }
    
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

enum KeyboardControl: UInt16 {
  case a =      0
  case d =      2
  case w =      13
  case s =      1
  case down =   125
  case up =     126
  case right =  124
  case left =   123
  case q =      12
  case e =      14
  case key1 =   18
  case key2 =   19
  case key0 =   29
  case space =  49
  case c =      8
}

enum MouseControl {
  case leftDown, leftUp, leftDrag, rightDown, rightUp, rightDrag, scroll, mouseMoved
}

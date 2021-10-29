//
//  AnimationEventType.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// Animation event type.
enum AnimationEventType: Int {
    /// Triggered when the animation over if the wrapMode === WrapMode.ONCE
    case Finished = 0
    /// Triggered when the animation over if the wrapMode === WrapMode.LOOP
    case LoopEnd = 1
    /// Triggered when the animation plays to the frame
    case FrameEvent = 2
}

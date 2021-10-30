//
//  AnimationEventHandler.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

internal class AnimationEventHandler {
    var event: AnimationEvent!
    var handlers: [(AnyObject) -> Void] = []

    required init() {
    }
}

extension AnimationEventHandler: EmptyInit {
}

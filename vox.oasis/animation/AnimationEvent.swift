//
//  AnimationEvent.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// AnimationEvent lets you call a script function similar to SendMessage as part of playing back an animation.
class AnimationEvent {
    /// The time when the event be triggered.
    var time: Float = 0
    /// The name of the method called in the script.
    var functionName: String = ""
    /// The parameter that is stored in the event and will be sent to the function.
    var parameter: AnyObject?
}

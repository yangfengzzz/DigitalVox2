//
//  AnimationClip.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

/// Stores keyframe based animations.
class AnimationClip: Motion {
    internal var _curveBindings: [AnimationClipCurveBinding] = [];
    private var _length: Float = 0;
    private var _events: [AnimationEvent] = [];

    /// Animation events for this animation clip.
    var events: [AnimationEvent] {
        get {
            _events
        }
    }

    /// Animation curve bindings for this animation clip.
    var curveBindings: [AnimationClipCurveBinding] {
        get {
            _curveBindings
        }
    }

    /// Animation length in seconds.
    var length: Float {
        get {
            _length
        }
    }

    /// Adds an animation event to the clip.
    /// - Parameter event: The animation event
    func addEvent(_ event: AnimationEvent) {
        _events.append(event);
        _events.sort { a, b in
            a.time - b.time > 0
        }
    }

    /// Clears all events from the clip.
    func clearEvents() {
        _events = []
    }

    /// Add curve binding for the clip.
    /// - Parameters:
    ///   - relativePath: Path to the game object this curve applies to. The relativePath is formatted similar to a pathname, e.g. "/root/spine/leftArm"
    ///   - type: The class type of the component that is animated
    ///   - propertyName: The name to the property being animated
    ///   - curve: The animation curve
    func addCurveBinding<T: Component>(relativePath: String,
                                       type: T.Type,
                                       propertyName: String,
                                       curve: AnimationCurve) {
        let property: AnimationProperty;
        switch (propertyName) {
        case "position":
            property = AnimationProperty.Position;
            break;
        case "rotation":
            property = AnimationProperty.Rotation;
            break;
        case "scale":
            property = AnimationProperty.Scale;
            break;
        case "blendShapeWeights":
            property = AnimationProperty.BlendShapeWeights;
            break;
        default:
            fatalError()
        }
        let curveBinding = AnimationClipCurveBinding();
        curveBinding.relativePath = relativePath;
        curveBinding.type = type;
        curveBinding.property = property;
        curveBinding.curve = curve;
        if (curve.length > _length) {
            _length = curve.length;
        }
        _curveBindings.append(curveBinding);
    }
}
